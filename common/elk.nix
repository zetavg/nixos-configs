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

let
  logstashElasticsearchTemplateFile = pkgs.writeText "logstash-es-template.json" ''
    {
      "order" : 0,
      "version" : 60001,
      "index_patterns" : [
        "logstash-*"
      ],
      "settings" : {
        "index" : {
          "lifecycle" : {
            "name" : "logstash-policy",
            "rollover_alias" : "logstash"
          },
          "number_of_shards" : "1",
          "refresh_interval" : "5s"
        }
      },
      "mappings" : {
        "dynamic_templates" : [
          {
            "message_field" : {
              "path_match" : "message",
              "mapping" : {
                "norms" : false,
                "type" : "text"
              },
              "match_mapping_type" : "string"
            }
          }
        ],
        "properties" : {
          "@timestamp" : {
            "type" : "date"
          },
          "geoip" : {
            "dynamic" : true,
            "properties" : {
              "ip" : {
                "type" : "ip"
              },
              "latitude" : {
                "type" : "half_float"
              },
              "location" : {
                "type" : "geo_point"
              },
              "longitude" : {
                "type" : "half_float"
              }
            }
          },
          "type" : {
            "type" : "keyword"
          },
          "facility" : {
            "type" : "keyword"
          },
          "ident" : {
            "type" : "keyword"
          },
          "priority" : {
            "type" : "keyword"
          },
          "method" : {
            "type" : "keyword"
          },
          "@version" : {
            "type" : "keyword"
          }
        }
      },
      "aliases" : { }
    }
  '';
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
    '';
    filterConfig = ''
      if [type] == "syslog" {
        # Use the systemd timestamp
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

        # Normalize field names
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

        # Normalize priority values from systemd
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

        # Normalize facility values from systemd
        mutate {
          lowercase => ["facility"]
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

        # Kibana specific operations
        if [ident] == "kibana" {
          json {
            source => "message"
            target => "kibana"
          }
          if [kibana] {
            mutate {
              rename => { "message" => "raw_message" }
              add_field => { "message" => "[%{[kibana][type]}] %{[kibana][message]}" }
            }
          }
        }

        # Nginx specific operations
        if [ident] == "nginx" {
          mutate {
            copy => { "message" => "raw_message" }
          }
          grok {
            # match => {
            #   "message" => "(?<nginx_timestamp>\d{4}/\d{2}/\d{2}\s{1,}\d{2}:\d{2}:\d{2})\s{1,}\[%{DATA:priority}\]\s{1,}(%{NUMBER:pid:int}#%{NUMBER:process_id}:\s{1,}\*%{NUMBER:thread_id}|\*%{NUMBER:connect_id}) %{DATA:message}(?:,\s{1,}client:\s{1,}(?<client_ip>%{IP}|%{HOSTNAME}))(?:,\s{1,}server:\s{1,}%{IPORHOST:server})(?:, request: %{QS:request})?(?:, host: %{QS:client_ip})?(?:, referrer: \"%{URI:referrer})?"
            # }
            match => {
              "message" => "(?<nginx_timestamp>\d{4}/\d{2}/\d{2}\s{1,}\d{2}:\d{2}:\d{2})\s{1,}\[%{DATA:priority}\]\s{1,}%{GREEDYDATA:message}"
            }
            overwrite => ["priority", "message"]
          }
        }

        # Normalize priority values
        mutate {
          lowercase => ["priority"]
        }
        if [priority] == "panic" {
          mutate { update => { "priority" => "emerg" } }
        } else if [priority] == "error" {
          mutate { update => { "priority" => "err" } }
        } else if [priority] == "warn" {
          mutate { update => { "priority" => "warning" } }
        }
      }
    '';
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
