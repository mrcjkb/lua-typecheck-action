# TODO: Use official alpine image with pinned package versions when lua-language-server is available
FROM lspcontainers/lua-language-server:latest AS lua

ENV LUA_VERSION="5.1.5"
ENV LUA_SHA1_CHECKSUM="b3882111ad02ecc6b972f8c1241647905cb2e3fc"

RUN set -ex \
    && cat /etc/*-release \
    && apk upgrade \
    && apk add --no-cache readline-dev \
    && apk add --no-cache --virtual .build-deps \
        make \
        gcc \
        libc-dev \
        ncurses-dev \
    && wget -cq https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz \
        -O lua.tar.gz \
    && [ "$(sha1sum lua.tar.gz | cut -d' ' -f1)" = "${LUA_SHA1_CHECKSUM}" ] \
    && tar -xzf lua.tar.gz \
    && rm lua.tar.gz

WORKDIR /lua-${LUA_VERSION}
RUN make -j"$(nproc)" linux \
    && make install

WORKDIR /
RUN rm -rf lua-${LUA_VERSION} \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

FROM lua AS sumneko-lint

COPY entrypoint.lua /entrypoint.lua

ENTRYPOINT ["/entrypoint.lua"]
