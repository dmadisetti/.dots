# Fancy grub and networking
{ dev, ssid }:
{ pkgs, sensitive, lib, config, self, ... }:

lib.mkIf (config.networking.interfaces ? "${dev.ap}") {

  services = {
    hostapd = {
      inherit ssid;

      enable = !(
        sensitive.lib.networking.wireless or {
          enable = false;
        }
      ).enable;
      interface = "${dev.ap}";
      hwMode = "g";
      wpaPassphrase = (
        config.networking.wireless.networks."${ssid}" or
          { psk = ""; }
      ).psk;
      extraConfig = ''
        auth_algs=3
        beacon_int=100
        dtim_period=2
        eap_server=0
        eapol_key_index_workaround=0
        ignore_broadcast_ssid=0
        macaddr_acl=0
        max_num_sta=255
        own_ip_addr=127.0.0.1
        utf8_ssid=1
        wmm_ac_be_acm=0
        wmm_ac_be_aifs=3
        wmm_ac_be_cwmax=10
        wmm_ac_be_cwmin=4
        wmm_ac_be_txop_limit=0
        wmm_ac_bk_acm=0
        wmm_ac_bk_aifs=7
        wmm_ac_bk_cwmax=10
        wmm_ac_bk_cwmin=4
        wmm_ac_bk_txop_limit=0
        wmm_ac_vi_acm=0
        wmm_ac_vi_aifs=2
        wmm_ac_vi_cwmax=4
        wmm_ac_vi_cwmin=3
        wmm_ac_vi_txop_limit=94
        wmm_ac_vo_acm=0
        wmm_ac_vo_aifs=2
        wmm_ac_vo_cwmax=3
        wmm_ac_vo_cwmin=2
        wmm_ac_vo_txop_limit=47
        wmm_enabled=1
        wpa_key_mgmt=WPA-PSK
        wpa_pairwise=CCMP
      '';
    };

    dnsmasq = {
      enable = true;
      extraConfig = sensitive.lib.dnsmasq or "";
    };

    # Sometimes slow connection speeds are attributed to absence of haveged.
    haveged.enable = true;
  };

  systemd.services.wifi =
    let tables = "${pkgs.iptables}/bin/iptables";
    in
    {
      description = "post dnsmasq iptables rules for wifi";
      after = [ "dnsmasq.service" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${tables} --table nat --append POSTROUTING --out-interface ${dev.out} -j MASQUERADE
        ${tables} --append FORWARD --in-interface ${dev.ap} -j ACCEPT
        ${tables} -P FORWARD ACCEPT
      '';
    };
}
