FROM ubuntu:18.04
 
MAINTAINER Jackie "www.jackieathome.net"
ENV NGINX_VERSION 1.18.0
ENV OPENSSL_VERSION 1.1.1g
ENV PCRE_VERSION 8.44
ENV ZLIB_VERSION 1.2.11
ENV BUILD_ROOT /usr/local/src/nginx
 
RUN     apt-get update \
        && apt-get -y install git zip unzip curl make gcc g++ \
        && mkdir -p $BUILD_ROOT \
        && cd $BUILD_ROOT \
        && curl https://ftp.pcre.org/pub/pcre/pcre-$PCRE_VERSION.zip -o $BUILD_ROOT/pcre-$PCRE_VERSION.zip \
        && curl https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz -o $BUILD_ROOT/openssl-$OPENSSL_VERSION.tar.gz \
        && curl http://www.zlib.net/zlib-$ZLIB_VERSION.tar.gz -o $BUILD_ROOT/zlib-$ZLIB_VERSION.tar.gz \
        && curl https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o $BUILD_ROOT/nginx-$NGINX_VERSION.tar.gz \
        && git clone git://github.com/perusio/nginx-delay-module.git \
        && tar vxzf nginx-$NGINX_VERSION.tar.gz \
        && unzip pcre-$PCRE_VERSION.zip \
        && tar vxfz zlib-$ZLIB_VERSION.tar.gz \
        && tar vxfz openssl-$OPENSSL_VERSION.tar.gz \
        && cd nginx-$NGINX_VERSION \
        && BUILD_CONFIG="\
            --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --http-log-path=/var/log/nginx/access.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --with-openssl=$BUILD_ROOT/openssl-$OPENSSL_VERSION \
            --with-pcre=$BUILD_ROOT/pcre-$PCRE_VERSION \
            --with-zlib=$BUILD_ROOT/zlib-$ZLIB_VERSION \
            --add-module=/usr/local/src/nginx/nginx-delay-module \
            --with-http_ssl_module \
            --with-http_v2_module \ 
            --with-threads \
            " \
        && mkdir -p /var/cache/nginx \
        && ./configure $BUILD_CONFIG \
        && make && make install \
        && rm -rf $BUILD_ROOT \
        && apt-get -y remove git zip unzip curl make gcc g++ \
        && apt-get -y autoremove \
        && rm -rf /var/lib/apt/lists/* \
        && ln -sf /dev/stdout /var/log/nginx/access.log \
        && ln -sf /dev/stderr /var/log/nginx/error.log
 
# create a docker-entrypoint.d directory
RUN mkdir /docker-entrypoint.d

COPY docker-entrypoint.sh /
COPY 10-listen-on-ipv6-by-default.sh /docker-entrypoint.d
COPY 20-envsubst-on-templates.sh /docker-entrypoint.d
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80 443

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]

