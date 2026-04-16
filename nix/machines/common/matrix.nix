# Matrix Synapse homeserver configuration
{ config, pkgs, lib, sensitive, ... }:
let
  # Domain configuration - can be overridden via sensitive
  tld = sensitive.lib.agave.tld or "ave";
  baseDomain = "matrix.${tld}";
  
  # Check if matrix is enabled via sensitive configuration
  matrixEnabled = sensitive.lib.agave.matrix.enable or false;
  
  # Conditionally access paths only if enabled
  registrationSecretPath = if matrixEnabled && sensitive.lib.agave.matrix ? registrationSecretPath 
                          then sensitive.lib.agave.matrix.registrationSecretPath 
                          else null;
  
  macaroonSecretPath = if matrixEnabled && sensitive.lib.agave.matrix ? macaroonSecretPath 
                      then sensitive.lib.agave.matrix.macaroonSecretPath 
                      else null;
in
{
  # Database for Synapse
  services.postgresql = lib.mkIf matrixEnabled {
    enable = true;
    ensureDatabases = [ "matrix-synapse" ];
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }
    ];
  };

  # Matrix Synapse homeserver
  services.matrix-synapse = lib.mkIf matrixEnabled {
    enable = true;
    
    # The server name is the public-facing domain used for MXIDs
    # Federation uses this for routing
    settings = {
      server_name = baseDomain;
      
      # Public base URL for client API
      public_baseurl = "https://${baseDomain}:8448";
      
      # Listener configuration
      listeners = [
        {
          # Client API port (for clients)
          port = 8008;
          tls = false;
          type = "http";
          x_forwarded = true;
          resources = [
            { names = [ "client" "federation" ]; compress = true; }
          ];
          bind_addresses = [ "127.0.0.1" ];
        }
      ];
      
      # Database configuration - using Postgresql
      database = {
        name = "psycopg2";
        args = {
          database = "matrix-synapse";
          user = "matrix-synapse";
          host = "/run/postgresql";
          cp_min = 5;
          cp_max = 10;
        };
      };
      
      # Media store
      media_store_path = "/var/lib/matrix-synapse/media";
      
      # Registration settings
      enable_registration = false;
      
      # Federation settings
      federation_domain_whitelist = [];
      allow_public_rooms_over_federation = false;
      
      # Rate limiting
      rc_registration = {
        per_second = 0.17;
        burst_count = 3;
      };
      
      # Admin contact
      admin_contact = "mailto:admin@${baseDomain}";
      
      # URL preview settings
      url_preview_enabled = true;
      url_preview_ip_range_blacklist = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "100.64.0.0/10"
        "0.0.0.0/8"
        "169.254.0.0/16"
      ];
      
      # Retention settings
      retention = {
        enabled = true;
        default_policy = {
          min_lifetime = "1d";
          max_lifetime = "1y";
        };
      };
    };
    
    # Secret files (via agenix)
    extraConfigFiles = lib.optional (registrationSecretPath != null) registrationSecretPath
                       ++ lib.optional (macaroonSecretPath != null) macaroonSecretPath;
    
    # Explicitly don't use localhost sqlite
    dataDir = "/var/lib/matrix-synapse";
  };

  # Ensure directories exist
  systemd.tmpfiles.rules = lib.mkIf matrixEnabled [
    "d /var/lib/matrix-synapse 0750 matrix-synapse matrix-synapse -"
    "d /var/lib/matrix-synapse/media 0750 matrix-synapse matrix-synapse -"
  ];

  # Nginx reverse proxy configuration for Matrix
  # This extends the existing nginx config pattern used by other services
  services.nginx.virtualHosts = lib.mkIf matrixEnabled {
    # Client API endpoint
    "${baseDomain}" = {
      enableACME = false; # Using sensitive-provided certs or self-signed
      forceSSL = true;
      sslCertificate = "/run/agenix/matrix-cert";
      sslCertificateKey = "/run/agenix/matrix-key";
      
      locations."/_matrix" = {
        proxyPass = "http://127.0.0.1:8008";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          client_max_body_size 50M;
        '';
      };
      
      locations."/_synapse" = {
        proxyPass = "http://127.0.0.1:8008";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
    
    # Federation endpoint (port 8448 separate virtual host or same)
    # Matrix federation uses SRV records or .well-known to discover the endpoint
  };

  # Firewall rules
  networking.firewall.allowedTCPPorts = lib.mkIf matrixEnabled [ 8448 8008 ];
  
  # Ensure PostgreSQL starts before Synapse
  systemd.services.matrix-synapse = lib.mkIf matrixEnabled {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };
}
