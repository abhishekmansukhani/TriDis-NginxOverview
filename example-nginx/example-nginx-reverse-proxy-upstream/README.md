# About example-nginx-reverse-proxy-upstream

This example shows how to set up nginx with an upstream host that is defined in an upstream group.

## Notes

* The `nginx.vh.default.conf` file is renamed to `default.conf` during the docker build step

* The `127.0.0.11` name server is the docker container embedded name server

* The example uses `example-service-hello-world` as the upstream host being proxied

## References to NGINX Documentation for nginx.vh.default.conf

* See [ngx_http_core_module](https://nginx.org/en/docs/http/ngx_http_core_module.html) to learn more about the, `listen`, `resolver`, `server_name` directives and the `location`, and `server` contexts that are used in `nginx.vh.default.conf`

* See [ngx_http_proxy_module](https://nginx.org/en/docs/http/ngx_http_proxy_module.html) to learn more about the `proxy_pass`, and `proxy_set_header`, directives that are used in `nginx.vh.default.conf`