FROM alpine:3.11 as build

RUN apk add --no-cache gcc musl-dev linux-headers openssl-dev make git

RUN addgroup -S app && adduser -S -G app app 
RUN chown -R app:app /usr/local

WORKDIR /tmp
USER app
RUN git clone https://github.com/artix75/redis-cluster-proxy
RUN cd redis-cluster-proxy && make install

FROM alpine:3.11 as runtime

RUN apk add --no-cache libstdc++
RUN apk add --no-cache strace
RUN apk add --no-cache python3
RUN apk add --no-cache redis

RUN addgroup -S app && adduser -S -G app app 
COPY --chown=app:app --from=build /usr/local/bin/redis-cluster-proxy /usr/local/bin/redis-cluster-proxy
RUN chmod +x /usr/local/bin/redis-cluster-proxy
RUN ldd /usr/local/bin/redis-cluster-proxy

RUN mkdir -p /usr/local/etc/redis-cluster-proxy
RUN mkdir -p /use/local/run/redis-cluster-proxy
RUN chown -R app:app /usr/local
VOLUME /usr/local/etc/redis-cluster-proxy
VOLUME /usr/local/run/redis-cluster-proxy

# Now run in usermode
USER app
WORKDIR /home/app

ENTRYPOINT ["/usr/local/bin/redis-cluster-proxy"]
EXPOSE 7777
CMD ["redis-cluster-proxy"]
