FROM alpine:3.9

LABEL maintainer="Théo Lévesque <theo.levesque.024@gmail.com>"

ENV CGO_CFLAGS="-I/usr/local/include -fPIC"
ENV CGO_LDFLAGS="-shared"

RUN set -x && \
    apk --no-cache add mosquitto libwebsockets c-ares openssl openssl-dev libuuid mosquitto-dev mosquitto-libs libwebsockets-dev c-ares-dev build-base go && \
    apk --no-cache add --virtual build-deps git && \
    git clone git://github.com/iegomez/mosquitto-go-auth.git && \
    cd mosquitto-go-auth && \
    go build -buildmode=c-archive go-auth.go && \
    go build -buildmode=c-shared -o go-auth.so && \
    install -s -m755 go-auth.so /usr/local/lib/ && \
    apk del build-deps && rm -rf /var/cache/apk/*

VOLUME ["/mosquitto/data", "/mosquitto/log"]

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]
