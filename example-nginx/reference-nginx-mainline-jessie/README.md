# About reference-nginx-mainline-jessie

This reference shows the default nginx configuration in the official Docker image for nginx.

See the [official NGINX Dockerfiles]((https://github.com/nginxinc/docker-nginx)) project, and especially the [/docker-nginx/mainline/alpine](https://github.com/nginxinc/docker-nginx/tree/master/mainline/alpine) directory for similar content.

## Notes

* The `nginx.conf` file includes `/etc/nginx/conf.d/*.conf` as the last directive in its `http` context

* The `nginx.vh.default.conf` file is renamed to `default.conf` during the docker build step

## References to NGINX Documentation for nginx.conf

* See [ngx_core_module](https://nginx.org/en/docs/ngx_core_module.html) to learn more about the `error_log`, `include`, `pid`, `user`, and `worker_processes` directives and the `events` context that are used in `nginx.conf`

* See [ngx_http_core_module](https://nginx.org/en/docs/http/ngx_http_core_module.html) to learn more about the `default_type`, `keepalive_timeout`, and `sendfile` directives that are used in `nginx.conf`

* See [ngx_http_log_module](https://nginx.org/en/docs/http/ngx_http_log_module.html) to learn more about the `log_format`, and `access_log` directives that are used in `nginx.conf`

## References to NGINX Documentation for nginx.vh.default.conf

* See [ngx_http_core_module](https://nginx.org/en/docs/http/ngx_http_core_module.html) to learn more about the `error_page`, `listen`, `root`, and `server_name` directives and the `server` context that are used in `nginx.vh.default.conf`

* See [ngx_http_index_module](https://nginx.org/en/docs/http/ngx_http_index_module.html) to learn more about the `index` directive that is used in `nginx.vh.default.conf`