{ lib, ... }:

{
  imports = [
    ../../services/filebeat.nix
  ];

  services.filebeat = {
    inputs = [
      {
        type = "log";
        enabled = true;
        paths = ["/var/spool/nginx/logs/access-json.log"];
        fields = {
          type = "nginx_json";
          subtype = "access";
        };
      }
      {
        type = "log";
        enabled = true;
        paths = ["/var/spool/nginx/logs/error.log"];
        fields = {
          type = "nginx_error";
          subtype = "error";
        };
      }
    ];
  };

  services.nginx.commonHttpConfig = lib.mkBefore ''
    log_format json escape=json
      '{'
        # '"time_local":"$time_local",'
        # '"remote_addr":"$remote_addr",'
        # '"remote_user":"$remote_user",'
        # '"request":"$request",'
        # '"status": "$status",'
        # '"body_bytes_sent":"$body_bytes_sent",'
        # '"request_time":"$request_time",'
        '"http_referrer":"$http_referer",'
        '"http_user_agent":"$http_user_agent",'

        # https://stackoverflow.com/a/37678933
        # '"ancient_browser":"$ancient_browser",' # equals the value set by the ancient_browser_value directive, if a browser was identified as ancient
        # '"arg_":"$arg_",' # argument in the request line
        '"args":"$args",' # arguments in the request line
        # '"binary_remote_addr":"$binary_remote_addr",' # client address in a binary form, value’s length is always 4 bytes for IPv4 addresses or 16 bytes for IPv6 addresses
        '"body_bytes_sent":"$body_bytes_sent",' # number of bytes sent to a client, not counting the response header; this variable is compatible with the “%B” parameter of the mod_log_config Apache module
        '"bytes_sent":"$bytes_sent",' # number of bytes sent to a client (1.3.8, 1.2.5)
        '"connection":"$connection",' # connection serial number (1.3.8, 1.2.5)
        '"connection_requests":"$connection_requests",' # current number of requests made through a connection (1.3.8, 1.2.5)
        # '"connections_active":"$connections_active",' # same as the Active connections value
        # '"connections_reading":"$connections_reading",' # same as the Reading value
        # '"connections_waiting":"$connections_waiting",' # same as the Waiting value
        # '"connections_writing":"$connections_writing",' # same as the Writing value
        '"content_length":"$content_length",' # “Content-Length” request header field
        '"content_type":"$content_type",' # “Content-Type” request header field
        # '"cookie_":"$cookie_",' # the named cookie
        # '"date_gmt":"$date_gmt",' # current time in GMT. The format is set by the config command with the timefmt parameter
        # '"date_local":"$date_local",' # current time in the local time zone. The format is set by the config command with the timefmt parameter
        # '"document_root":"$document_root",' # root or alias directive’s value for the current request
        # '"document_uri":"$document_uri",' # same as $uri
        # '"fastcgi_path_info":"$fastcgi_path_info",' # the value of the second capture set by the fastcgi_split_path_info directive. This variable can be used to set the PATH_INFO parameter
        # '"fastcgi_script_name":"$fastcgi_script_name",' # request URI or, if a URI ends with a slash, request URI with an index file name configured by the fastcgi_index directive appended to it.
        # '"geoip_area_code":"$geoip_area_code",' # telephone area code (US only)
        # '"geoip_city":"$geoip_city",' # city name, for example, “Moscow”, “Washington”
        # '"geoip_city_continent_code":"$geoip_city_continent_code",' # two-letter continent code, for example, “EU”, “NA”
        # '"geoip_city_country_code":"$geoip_city_country_code",' # two-letter country code, for example, “RU”, “US”
        # '"geoip_city_country_code3":"$geoip_city_country_code3",' # three-letter country code, for example, “RUS”, “USA”
        # '"geoip_city_country_name":"$geoip_city_country_name",' # country name, for example, “Russian Federation”, “United States”
        # '"geoip_country_code":"$geoip_country_code",' # two-letter country code, for example, “RU”, “US”
        # '"geoip_country_code3":"$geoip_country_code3",' # three-letter country code, for example, “RUS”, “USA”
        # '"geoip_country_name":"$geoip_country_name",' # country name, for example, “Russian Federation”, “United States”
        # '"geoip_dma_code":"$geoip_dma_code",' # DMA region code in US (also known as “metro code”), according to the geotargeting in Google AdWords API
        # '"geoip_latitude":"$geoip_latitude",' # latitude
        # '"geoip_longitude":"$geoip_longitude",' # longitude
        # '"geoip_org":"$geoip_org",' # organization name, for example, “The University of Melbourne”
        # '"geoip_postal_code":"$geoip_postal_code",' # postal code
        # '"geoip_region":"$geoip_region",' # two-symbol country region code (region, territory, state, province, federal land and the like), for example, “48”, “DC”
        # '"geoip_region_name":"$geoip_region_name",' # country region name (region, territory, state, province, federal land and the like), for example, “Moscow City”, “District of Columbia”
        '"gzip_ratio":"$gzip_ratio",' # achieved compression ratio, computed as the ratio between the original and compressed response sizes
        '"host":"$host",' # in this order of precedence: host name from the request line, or host name from the “Host” request header field, or the server name matching a request
        '"hostname":"$hostname",' # host name
        '"http2":"$http2",' # negotiated protocol identifier: “h2” for HTTP/2 over TLS, “h2c” for HTTP/2 over cleartext TCP, or an empty string otherwise
        # '"http_":"$http_",' # arbitrary request header field; the last part of the variable name is the field name converted to lower case with dashes replaced by underscores. Examples: $http_referer, $http_user_agent
        '"https":"$https",' # “on” if connection operates in SSL mode, or an empty string otherwise
        # '"invalid_referer":"$invalid_referer",' # Empty string, if the “Referer” request header field value is considered valid, otherwise “1”
        # '"is_args":"$is_args",' # “?” if a request line has arguments, or an empty string otherwise
        # '"limit_rate":"$limit_rate",' # setting this variable enables response rate limiting; see limit_rate
        # '"memcached_key":"$memcached_key",' # Defines a key for obtaining response from a memcached server
        # '"modern_browser":"$modern_browser",' # equals the value set by the modern_browser_value directive, if a browser was identified as modern
        '"msec":"$msec",' # current time in seconds with the milliseconds resolution (1.3.9, 1.2.6)
        # '"msie":"$msie",' # equals “1” if a browser was identified as MSIE of any version
        '"nginx_version":"$nginx_version",' # nginx version
        '"pid":"$pid",' # PID of the worker process
        '"pipe":"$pipe",' # “p” if request was pipelined, “.” otherwise (1.3.12, 1.2.7)
        '"proxy_add_x_forwarded_for":"$proxy_add_x_forwarded_for",' # the “X-Forwarded-For” client request header field with the $remote_addr variable appended to it, separated by a comma. If the “X-Forwarded-For” field is not present in the client request header, the $proxy_add_x_forwarded_for variable is equal to the $remote_addr variable
        '"proxy_host":"$proxy_host",' # name and port of a proxied server as specified in the proxy_pass directive
        '"proxy_port":"$proxy_port",' # port of a proxied server as specified in the proxy_pass directive, or the protocol’s default port
        '"proxy_protocol_addr":"$proxy_protocol_addr",' # client address from the PROXY protocol header, or an empty string otherwise (1.5.12). the PROXY protocol must be previously enabled by setting the proxy_protocol parameter in the listen directive.
        '"proxy_protocol_port":"$proxy_protocol_port",' # client port from the PROXY protocol header, or an empty string otherwise (1.11.0). the PROXY protocol must be previously enabled by setting the proxy_protocol parameter in the listen directive.
        '"query_string":"$query_string",' # same as $args
        '"realip_remote_addr":"$realip_remote_addr",' # keeps the original client address (1.9.7)
        '"realip_remote_port":"$realip_remote_port",' # keeps the original client port (1.11.0)
        # realpath() "/var/spool/nginx/html" failed (2: No such file or directory) while logging request
        # '"realpath_root":"$realpath_root",' # an absolute pathname corresponding to the root or alias directive’s value for the current request, with all symbolic links resolved to real paths
        '"remote_addr":"$remote_addr",' # client address
        '"remote_port":"$remote_port",' # client port
        '"remote_user":"$remote_user",' # user name supplied with the Basic authentication
        '"request":"$request",' # full original request line
        # '"request_body":"$request_body",' # request bod. The variable’s value is made available in locations processed by the proxy_pass, fastcgi_pass, uwsgi_pass, and scgi_pass directives.
        # '"request_body_file":"$request_body_file",' # name of a temporary file with the request body. At the end of processing, the file needs to be removed. To always write the request body to a file, client_body_in_file_only needs to be enabled. When the name of a temporary file is passed in a proxied request or in a request to a FastCGI/uwsgi/SCGI server, passing the request body should be disabled by the proxy_pass_request_body off, fastcgi_pass_request_body off, uwsgi_pass_request_body off, or scgi_pass_request_body off directives, respectively.
        '"request_completion":"$request_completion",' # “OK” if a request has completed, or an empty string otherwise
        '"request_filename":"$request_filename",' # file path for the current request, based on the root or alias directives, and the request URI
        '"request_id":"$request_id",' # unique request identifier generated from 16 random bytes, in hexadecimal (1.11.0)
        '"request_length":"$request_length",' # request length (including request line, header, and request body) (1.3.12, 1.2.7)
        '"request_method":"$request_method",' # request method, usually “GET” or “POST”
        '"request_time":"$request_time",' # request processing time in seconds with a milliseconds resolution (1.3.9, 1.2.6); time elapsed since the first bytes were read from the client
        '"request_uri":"$request_uri",' # full original request URI (with arguments)
        '"scheme":"$scheme",' # request scheme, “http” or “https”
        # '"secure_link":"$secure_link",' # The status of a link check. The specific value depends on the selected operation mode
        # '"secure_link_expires":"$secure_link_expires",' # The lifetime of a link passed in a request; intended to be used only in the secure_link_md5 directive
        # '"sent_http_":"$sent_http_",' # arbitrary response header field; the last part of the variable name is the field name converted to lower case with dashes replaced by underscores
        '"server_addr":"$server_addr",' # an address of the server which accepted a request. Computing a value of this variable usually requires one system call. To avoid a system call, the listen directives must specify addresses and use the bind parameter.
        '"server_name":"$server_name",' # name of the server which accepted a request
        '"server_port":"$server_port",' # port of the server which accepted a request
        '"server_protocol":"$server_protocol",' # request protocol, usually “HTTP/1.0”, “HTTP/1.1”, or “HTTP/2.0”
        # '"session_log_binary_id":"$session_log_binary_id",' # current session ID in binary form (16 bytes)
        # '"session_log_id":"$session_log_id",' # current session ID
        # '"slice_range":"$slice_range",' # the current slice range in HTTP byte range format, for example, bytes=0-1048575
        # '"spdy":"$spdy",' # SPDY protocol version for SPDY connections, or an empty string otherwise
        # '"spdy_request_priority":"$spdy_request_priority",' # request priority for SPDY connections, or an empty string otherwise
        '"ssl_cipher":"$ssl_cipher",' # returns the string of ciphers used for an established SSL connection
        # '"ssl_client_cert":"$ssl_client_cert",' # returns the client certificate in the PEM format for an established SSL connection, with each line except the first prepended with the tab character; this is intended for the use in the proxy_set_header directive
        # '"ssl_client_fingerprint":"$ssl_client_fingerprint",' # returns the SHA1 fingerprint of the client certificate for an established SSL connection (1.7.1)
        # '"ssl_client_i_dn":"$ssl_client_i_dn",' # returns the “issuer DN” string of the client certificate for an established SSL connection
        # '"ssl_client_raw_cert":"$ssl_client_raw_cert",' # returns the client certificate in the PEM format for an established SSL connection
        # '"ssl_client_s_dn":"$ssl_client_s_dn",' # returns the “subject DN” string of the client certificate for an established SSL connection
        # '"ssl_client_serial":"$ssl_client_serial",' # returns the serial number of the client certificate for an established SSL connection
        # '"ssl_client_verify":"$ssl_client_verify",' # returns the result of client certificate verification: “SUCCESS”, “FAILED”, and “NONE” if a certificate was not present
        '"ssl_protocol":"$ssl_protocol",' # returns the protocol of an established SSL connection
        '"ssl_server_name":"$ssl_server_name",' # returns the server name requested through SNI (1.7.0)
        '"ssl_session_id":"$ssl_session_id",' # returns the session identifier of an established SSL connection
        '"ssl_session_reused":"$ssl_session_reused",' # returns “r” if an SSL session was reused, or “.” otherwise (1.5.11)
        '"status":"$status",' # response status (1.3.2, 1.2.2)
        # '"tcpinfo_rtt":"$tcpinfo_rtt",'
        # '"tcpinfo_rttvar":"$tcpinfo_rttvar",'
        # '"tcpinfo_snd_cwnd":"$tcpinfo_snd_cwnd",'
        # '"tcpinfo_rcv_space":"$tcpinfo_rcv_space",' # information about the client TCP connection; available on systems that support the TCP_INFO socket option
        '"time_iso8601":"$time_iso8601",' # local time in the ISO 8601 standard format (1.3.12, 1.2.7)
        '"time_local":"$time_local",' # local time in the Common Log Format (1.3.12, 1.2.7)
        # '"uid_got":"$uid_got",' # The cookie name and received client identifier
        # '"uid_reset":"$uid_reset",' # If the variable is set to a non-empty string that is not “0”, the client identifiers are reset. The special value “log” additionally leads to the output of messages about the reset identifiers to the error_log
        # '"uid_set":"$uid_set",' # The cookie name and sent client identifier
        # '"upstream_addr":"$upstream_addr",' # keeps the IP address and port, or the path to the UNIX-domain socket of the upstream server. If several servers were contacted during request processing, their addresses are separated by commas, e.g. “192.168.1.1:80, 192.168.1.2:80, unix:/tmp/sock”. If an internal redirect from one server group to another happens, initiated by “X-Accel-Redirect” or error_page, then the server addresses from different groups are separated by colons, e.g. “192.168.1.1:80, 192.168.1.2:80, unix:/tmp/sock : 192.168.10.1:80, 192.168.10.2:80”
        # '"upstream_cache_status":"$upstream_cache_status",' # keeps the status of accessing a response cache (0.8.3). The status can be either “MISS”, “BYPASS”, “EXPIRED”, “STALE”, “UPDATING”, “REVALIDATED”, or “HIT”
        # '"upstream_connect_time":"$upstream_connect_time",' # time spent on establishing a connection with an upstream server
        # '"upstream_cookie_":"$upstream_cookie_",' # cookie with the specified name sent by the upstream server in the “Set-Cookie” response header field (1.7.1). Only the cookies from the response of the last server are saved
        # '"upstream_header_time":"$upstream_header_time",' # time between establishing a connection and receiving the first byte of the response header from the upstream server
        # '"upstream_http_":"$upstream_http_",' # keep server response header fields. For example, the “Server” response header field is available through the $upstream_http_server variable. The rules of converting header field names to variable names are the same as for the variables that start with the “$http_” prefix. Only the header fields from the response of the last server are saved
        # '"upstream_response_length":"$upstream_response_length",' # keeps the length of the response obtained from the upstream server (0.7.27); the length is kept in bytes. Lengths of several responses are separated by commas and colons like addresses in the $upstream_addr variable
        # '"upstream_response_time":"$upstream_response_time",' # time between establishing a connection and receiving the last byte of the response body from the upstream server
        # '"upstream_status":"$upstream_status",' # keeps status code of the response obtained from the upstream server. Status codes of several responses are separated by commas and colons like addresses in the $upstream_addr variable
        '"uri":"$uri"' # current URI in request, normalized. The value of $uri may change during request processing, e.g. when doing internal redirects, or when using index files.
      '}';

    access_log /var/spool/nginx/logs/access-json.log json;
  '';
}
