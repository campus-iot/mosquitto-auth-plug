FROM golang:latest

LABEL maintainer="Théo Lévesque <theo.levesque.024@gmail.com>"

ENV CGO_CFLAGS="-I/usr/local/include -fPIC"
ENV CGO_LDFLAGS="-shared"

RUN set -x && \
    apt-get update && apt-get install -y git curl build-essential libc-ares-dev uuid-dev libwebsockets-dev libssl-dev && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L https://github.com/eclipse/mosquitto/archive/v1.5.8.tar.gz | tar xzv && \
    cd mosquitto-1.5.8 && \
    make -j "$(nproc)" WITH_WEBSOCKETS=yes WITH_DOCS=no && \
    make install WITH_WEBSOCKETS=yes WITH_DOCS=no && \
    groupadd mosquitto && \
    useradd -s /sbin/nologin mosquitto -g mosquitto -d /var/lib/mosquitto && \
    curl -L https://github.com/iegomez/mosquitto-go-auth/archive/0.2.0.tar.gz | tar xzv && \
    cd mosquitto-go-auth-0.2.0 && \
    make && \
    install -s -m755 go-auth.so /usr/local/lib/

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/local/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]
