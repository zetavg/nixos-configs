/*
 * The ELK Stack (Elasticsearch, Logstash, and Kibana)
 *
 * Ref: https://sheenobu.net/nixos-recipes/elk.html
 *
 * To enable remote access via Nginx, add config like the following:
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

{
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
    '';
    filterConfig = ''
      if [type] == "syslog" {
        ruby {
          code => "event.set('timestamp_ms', event.get('__REALTIME_TIMESTAMP').to_i / 1000)"
        }

        date {
          match => ["timestamp_ms", "UNIX_MS"]
        }

        # Keep only relevant systemd fields
        # http://www.freedesktop.org/software/systemd/man/systemd.journal-fields.html
        prune {
          whitelist_names => [
            "type", "SYSLOG_FACILITY", "SYSLOG_IDENTIFIER",
            "_HOSTNAME", "_UID", "_GID", "_PID",
            "PRIORITY", "MESSAGE",
            "timestamp_ms", "@timestamp", "@version"
          ]
        }

        mutate {
          rename => ["SYSLOG_FACILITY", "facility"]
          rename => ["SYSLOG_IDENTIFIER", "ident"]
          rename => ["_HOSTNAME", "hostname"]
          rename => ["_UID", "uid"]
          rename => ["_GID", "gid"]
          rename => ["_PID", "pid"]
          rename => ["PRIORITY", "priority"]
          rename => ["MESSAGE", "message"]
        }

        if [priority] == "0" {
          mutate { update => { "priority" => "emerg" } }
        } else if [priority] == "1" {
          mutate { update => { "priority" => "alert" } }
        } else if [priority] == "2" {
          mutate { update => { "priority" => "crit" } }
        } else if [priority] == "3" {
          mutate { update => { "priority" => "err" } }
        } else if [priority] == "4" {
          mutate { update => { "priority" => "warning" } }
        } else if [priority] == "5" {
          mutate { update => { "priority" => "notice" } }
        } else if [priority] == "6" {
          mutate { update => { "priority" => "info" } }
        } else if [priority] == "7" {
          mutate { update => { "priority" => "debug" } }
        }

        if [facility] == "0" {
          mutate { update => { "facility" => "kern" } }
        } else if [facility] == "1" {
          mutate { update => { "facility" => "user" } }
        } else if [facility] == "2" {
          mutate { update => { "facility" => "mail" } }
        } else if [facility] == "3" {
          mutate { update => { "facility" => "daemon" } }
        } else if [facility] == "4" {
          mutate { update => { "facility" => "auth" } }
        } else if [facility] == "5" {
          mutate { update => { "facility" => "syslog" } }
        } else if [facility] == "6" {
          mutate { update => { "facility" => "lpr" } }
        } else if [facility] == "7" {
          mutate { update => { "facility" => "news" } }
        } else if [facility] == "8" {
          mutate { update => { "facility" => "uucp" } }
        } else if [facility] == "9" {
          mutate { update => { "facility" => "cron" } }
        } else if [facility] == "10" {
          mutate { update => { "facility" => "authpriv" } }
        } else if [facility] == "11" {
          mutate { update => { "facility" => "ftp" } }
        } else if [facility] == "12" {
          mutate { update => { "facility" => "ntp" } }
        } else if [facility] == "13" {
          mutate { update => { "facility" => "security" } }
        } else if [facility] == "14" {
          mutate { update => { "facility" => "console" } }
        } else if [facility] == "15" {
          mutate { update => { "facility" => "solaris-cron" } }
        } else if [facility] == "16" {
          mutate { update => { "facility" => "local0" } }
        } else if [facility] == "17" {
          mutate { update => { "facility" => "local1" } }
        } else if [facility] == "18" {
          mutate { update => { "facility" => "local2" } }
        } else if [facility] == "19" {
          mutate { update => { "facility" => "local3" } }
        } else if [facility] == "20" {
          mutate { update => { "facility" => "local4" } }
        } else if [facility] == "21" {
          mutate { update => { "facility" => "local5" } }
        } else if [facility] == "22" {
          mutate { update => { "facility" => "local6" } }
        } else if [facility] == "23" {
          mutate { update => { "facility" => "local7" } }
        }
      }
    '';
    outputConfig = ''
      elasticsearch {
        hosts => ["127.0.0.1:9200"]
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
