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
      + (builtins.readFile ./filter-config-syslog.conf)
      + (builtins.readFile ./filter-config-nginx.conf)
      + (builtins.readFile ./filter-config-passenger.conf);
    outputConfig = ''
      elasticsearch {
        hosts => ["127.0.0.1:9200"]
        template => "${logstashElasticsearchTemplateFile}"
        template_overwrite => true
      }
    '';
  };
  services.elasticsearch = {
    enable = true;
    package = pkgs.elasticsearch7;
    # listening on 127.0.0.1:9200 by default
  };
  services.kibana = {
    enable = true;
    package = pkgs.kibana7;
    # listening on 127.0.0.1:5601 by default
  };
}
