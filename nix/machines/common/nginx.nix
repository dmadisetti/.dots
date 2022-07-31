# Fancy grub and networking
{ tld, proxies ? { }, cert ? null }:
{ lib, ... }:
let
  ssl =
    if cert != null then {
      forceSSL = cert ? key && cert.key != null;
      sslCertificate = cert.cert;
      sslCertificateKey = cert.key;
    } else { forceSSL = false; };

  port_proxy =
    { port
    , host ? "127.0.0.1"
    , extra ? ""
    }: {
      locations."/" = {
        proxyPass = "http://${host}:${port}$request_uri";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig = extra;
      };
    };

  wrap_proxy = name: value@{ port
                     , host ? "127.0.0.1"
                     , extra ? ""
                     }: port_proxy value;
in
{
  services.nginx = {
    enable = true;
    virtualHosts = (lib.mapAttrs wrap_proxy proxies) // (if ssl.forceSSL then {
      "~^(?<port>\\d+)?\\.https.${tld}$" = (port_proxy {
        port = "$port";
      }) // ssl;

      "~^(?<sub>.+)?\\.https.${tld}$" = {
        locations."/" = {
          proxyPass = "http://$sub.${tld}$request_uri";
          proxyWebsockets = true;
        };
      } // ssl;

      # fallback
      "https.${tld}" = {
        locations."/" = {
          priority = 10001;
          # some sort of page I reckon
        };
      } // ssl;
    } else { });
    resolver = {
      valid = "30s";
      addresses = [ "[::1]" "127.0.0.1:53" ];
    };
    proxyResolveWhileRunning = true;
  };
}
