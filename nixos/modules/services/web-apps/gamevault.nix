{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.gamevault;
in {
  options = {
    services.gamevault = {
      enable = mkEnableOption (lib.mdDoc "gamevault Media Server");

      user = mkOption {
        type = types.str;
        default = "gamevault";
        description = lib.mdDoc "User account under which gamevault runs.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.gamevault;
        defaultText = "pkgs.gamevault";
        description = lib.mdDoc ''
          gamevault package to use.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "gamevault";
        description = lib.mdDoc "Group under which gamevault runs.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Open Gamevaults default ports in the firewall.
        '';
      };

      adminUsername = mkOption {
        type = types.str;
        default = "admin";
        description = lib.mdDoc "User to grant admin rights to after registration";
      };
      # rawgKeyFile = 
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gamevault = {
      description = "Backend for the self-hosted gaming platform for alternatively obtained games";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      environment = {
        SERVER_ADMIN_USERNAME = cfg.adminUsername;
        DB_HOST = "localhost";
        DB_USERNAME = "gamevault";
        # DB_PASSWORD = ""
        # RAWG_API_KEY = lib.mkIf cfg.rawg
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        RuntimeDirectory = "gamevault";
        StateDirectory = "gamevault";
        CacheDirectory = "gamevault";
        ExecStart = "${cfg.package}/bin/gamevault";
        Restart = "on-failure";
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "gamevault" ];
      ensureUsers = [{
        name = "gamevault";
        ensurePermissions = { "DATABASE " = "ALL PRIVILEGES"; };
      }];
    };

    users.users = mkIf (cfg.user == "gamevault") {
      gamevault = {
        group = cfg.group;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "gamevault") {
      gamevault = {};
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [8080];
    };
  };

  meta.maintainers = with lib.maintainers; [michaelBelsanti];
}
