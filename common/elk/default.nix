/*
 * The ELK Stack (Elasticsearch, Logstash, and Kibana)
 *
 * Ref: https://sheenobu.net/nixos-recipes/elk.html
 *
 * To enable remote access of Kibana via Nginx, add config like the following:
 *
 *   services.nginx.virtualHosts."kibana.example.com" = {
 *     enableACME = true;
 *     forceSSL = true;
 *     basicAuth = {
 *       username = "password"; # Set the username and password for basic auth here
 *     };
 *     locations."/" = {
 *       proxyPass = "http://127.0.0.1:5601";
 *     };
 *   };
 *
 */

{ pkgs, lib, ... }:

let
  logstashElasticsearchTemplateFile = pkgs.writeText "logstash-es-template.json" (builtins.readFile ./logstash-es-template.json);
in {
  # The elasticsearch package has an unfree license
  nixpkgs.config.allowUnfree = true;

  services.elasticsearch = {
    enable = true;
    package = pkgs.elasticsearch7;
    # listening on 127.0.0.1:9200 by default
  };

  services.logstash = {
    enable = true;
    package = pkgs.logstash7;
    plugins = [ pkgs.logstash-contrib ];
    inputConfig = ''
      pipe {
        command => "${pkgs.systemd}/bin/journalctl -f -o json"
        type => "syslog"
        codec => json {}
      }
      beats {
        host => "127.0.0.1"
        port => 5044
      }
    '';
    filterConfig = ""
      + (builtins.readFile ./logstash-filter-configs/syslog.conf)
      + (builtins.readFile ./logstash-filter-configs/syslog-daemons/elasticsearch.conf)
      + (builtins.readFile ./logstash-filter-configs/syslog-daemons/logstash.conf)
      + (builtins.readFile ./logstash-filter-configs/syslog-daemons/kibana.conf)
      + (builtins.readFile ./logstash-filter-configs/syslog-daemons/filebeat.conf)
      + (builtins.readFile ./logstash-filter-configs/syslog-daemons/metricbeat.conf)
      + (builtins.readFile ./logstash-filter-configs/syslog-daemons/apm-server.conf)
      + (builtins.readFile ./logstash-filter-configs/syslog-daemons/acme.conf)
      + (builtins.readFile ./logstash-filter-configs/syslog-daemons/nginx.conf)
      + (builtins.readFile ./logstash-filter-configs/nginx.conf)
      + (builtins.readFile ./logstash-filter-configs/passenger.conf)
      + (builtins.readFile ./logstash-filter-configs/after-all.conf);
    outputConfig = ''
      elasticsearch {
        hosts => ["127.0.0.1:9200"]
        template => "${logstashElasticsearchTemplateFile}"
        template_overwrite => true
      }
    '';
  };

  services.kibana = {
    enable = true;
    package = pkgs.kibana7;
    # listening on 127.0.0.1:5601 by default
  };

  # The "elasticsearch", "logstash" and "kibana" systemd service did not have
  # the "Restart" option setted, and therefore will not be automatically
  # restarted on failure or when exited. We manually set it here.
  # Ref:
  #  - nixpkgs/nixos/modules/services/search/kibana.nix
  #  - https://www.freedesktop.org/software/systemd/man/systemd.service.html#Restart=
  systemd.services.elasticsearch.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "10";
    TimeoutStartSec = "3600";
  };
  systemd.services.logstash.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "10";
    TimeoutStartSec = "3600";
  };
  systemd.services.kibana.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "10";
    TimeoutStartSec = "3600";
  };
}
