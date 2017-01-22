FROM alpine:3.4
COPY Dockerfile /

ARG BUILD_DATE
ARG VCS_REF
ENV PUPPET_EXPLORER_VERSION="2.0.0"

LABEL org.label-schema.build-date=$BUILD_DATE \
			org.label-schema.name="puppetexplorer" \
			org.label-schema.description="Puppet Explorer 2.0" \
			org.label-schema.url="http://andradaprieto.es" \
			org.label-schema.vcs-ref=$VCS_REF \
			org.label-schema.vcs-url="https://github.com/jandradap/puppetexplorer" \
			org.label-schema.vendor="Jorge Andrada Prieto" \
      org.label-schema.version=$PUPPET_EXPLORER_VERSION \
			org.label-schema.schema-version="1.0" \
			maintainer="Jorge Andrada Prieto <jandradap@gmail.com>"

RUN apk add --no-cache --update ca-certificates wget && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

RUN wget "https://caddyserver.com/download/build?os=linux&arch=amd64&features=prometheus,realip" -O - | tar -xz --no-same-owner -C /usr/bin/ caddy

RUN wget https://github.com/spotify/puppetexplorer/releases/download/"$PUPPET_EXPLORER_VERSION"/puppetexplorer-"$PUPPET_EXPLORER_VERSION".tar.gz -O - | tar -xz && \
    ln -s puppetexplorer-"$PUPPET_EXPLORER_VERSION" /puppetexplorer

# This patch fixes https://github.com/spotify/puppetexplorer/issues/56 until a new release of puppetexplorer is made
RUN sed -i -e 's/puppetlabs\.puppetdb\.query\.population/puppetlabs\.puppetdb\.population/g' -e 's/type=default,//g' /puppetexplorer/app.js

COPY Caddyfile /etc/caddy/Caddyfile
COPY config.js /puppetexplorer

EXPOSE 80

WORKDIR /etc/caddy

CMD ["/usr/bin/caddy"]
