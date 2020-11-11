{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.grafana-loki;

  # Pretty-print JSON to a file
  writePrettyJSON = name: x:
    pkgs.runCommandNoCCLocal name {} ''
      echo '${builtins.toJSON x}' | ${pkgs.jq}/bin/jq . > $out
    '';

  lokiConfig = {
    auth_enabled= cfg.authEnabled; 
    server= { http_listen_port= cfg.port;}; 
    ingester= {
      lifecycler= {
        address= "127.0.0.1";
        ring= {
          kvstore={
            store= "inmemory";
          };
          replication_factor= 1;
        };
        final_sleep= "0s";
      };
      chunk_idle_period= "5m";
      chunk_retain_period= "30s";
    };

    schema_config= {
      configs= [{
        from= "2020-05-15";
        store= "boltdb";
        object_store= "filesystem";
        schema= "v11";
        index= {
          prefix= "index_";
          period= "168h";
        };
      }];
    };

    storage_config= {
      boltdb= {
        directory= "/tmp/loki/index";
      };

      filesystem= {
        directory= "/tmp/loki/chunks";
      };
    };

    limits_config= {
      enforce_metric_name= false;
      reject_old_samples= true;
      reject_old_samples_max_age= "168h";
    };
  };

  lokiYml = writePrettyJSON "config.yml" lokiConfig;
in {
  options.services.grafana-loki = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the Grafana Loki logging daemon.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.grafana-loki;
      defaultText = "pkgs.grafana-loki";
      description = ''
        The loki package that should be used.
      '';
    };

    authEnabled = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the authentication on grafana-loki
      '';
    };

    port = mkOption {
      type = types.port;
      default = 3100;
      description = ''
        Port to listen on.
      '';
    };
  };

  config = mkIf cfg.enable {

    users.groups.grafana-loki.gid = config.ids.gids.grafana-loki;
    users.users.grafana-loki = {
      description = "Loki daemon user";
      uid = config.ids.uids.grafana-loki;
      group = "grafana-loki";
    };
    systemd.services.grafana-loki = {
      wantedBy = [ "multi-user.target" ];
      after    = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/loki -config.file=${lokiYml}";
        User = "grafana-loki";
        Restart  = "always";
      };
    };
  };
}
