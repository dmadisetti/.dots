# Fancy grub and networking
{ tld, proxies ? { }, cert ? { crt = null; key = null; } }:
{ lib, ... }:
let
  ssl = {
    forceSSL = cert.key != null;
    sslCertificate = cert.crt;
    sslCertificateKey = cert.key;
  };

  port_proxy =
    { port
    , host ? "127.0.0.1"
    }: {
      locations."/" = {
        proxyPass = "http://${host}:${port}";
        proxyWebsockets = true; # needed if you need to use WebSocket
      };
    };

  wrap_proxy = name: value@{ port
                     , host ? "127.0.0.1"
                     }: port_proxy value;
in
{

  services.nginx = {
    enable = true;
    virtualHosts = (if ssl.forceSSL then {
      "*.https.${tld}" = ssl;
      "~^(?<port>\\d+)?\\.https.${tld}$" = (port_proxy {
        port = "$port";
      }) // ssl;

      "~^(?<sub>.+)?\\.https.${tld}$" = {
        locations."/" = {
          proxyPass = "http://$sub.${tld}";
          proxyWebsockets = true;
        };
      } // ssl;
    } else { }) // (lib.mapAttrs wrap_proxy proxies);
  };
}
