FROM alpine:3.9

LABEL maintainer="Théo Lévesque <theo.levesque.024@gmail.com>"

RUN apk --no-cache add mosquitto libpq mosquitto-dev postgresql-dev openssl-dev && \
    apk --no-cache add --virtual build-deps git build-base mosquitto-libs && \
    git clone git://github.com/jpmens/mosquitto-auth-plug.git && \
    cd mosquitto-auth-plug && \
    cp config.mk.in config.mk && \
    sed -i "s/BACKEND_MYSQL ?= yes/BACKEND_MYSQL ?= no/" config.mk && \
    sed -i "s/BACKEND_POSTGRES ?= no/BACKEND_POSTGRES ?= yes/" config.mk && \
    sed -i "s/BACKEND_FILES ?= no/BACKEND_FILES ?= yes/" config.mk && \
    sed -i "s/CFG_CFLAGS =/CFG_CFLAGS = -DRAW_SALT/" config.mk && \
    make -j "$(nproc)" && \
    install -s -m755 auth-plug.so /usr/local/lib/ && \
    install -s -m755 np /usr/local/bin/ && \
    cd .. && rm -rf mosquitto-auth-plug && \
    apk del build-deps && rm -rf /var/cache/apk/*

VOLUME ["/mosquitto/data", "/mosquitto/log"]

# Set up the entry point script and default command
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]
