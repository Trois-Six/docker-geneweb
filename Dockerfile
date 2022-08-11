FROM ocaml/opam:alpine-3.15-ocaml-4.14 AS build

RUN sudo apk --no-cache add gmp-dev perl perl-ipc-system-simple perl-string-shellquote

RUN set -eux && \
  git clone https://github.com/geneweb/geneweb.git geneweb && cd geneweb && \
  opam pin add geneweb.dev . --no-action && \
  opam depext geneweb && \
  opam install geneweb --deps-only && \
  eval $(opam env) && \
  ocaml ./configure.ml --release && \
  opam exec make clean distrib

FROM alpine:3.15

COPY --chown=root geneweb.sh /usr/local/bin/geneweb.sh

RUN apk --no-cache add gmp && \
  addgroup -S geneweb && \
  adduser -S -G geneweb -h /usr/local/share/geneweb -s /bin/bash geneweb && \
  chmod 755 /usr/local/bin/geneweb.sh

USER geneweb:geneweb
WORKDIR /usr/local/share/geneweb

ENV LANGUAGE en
ENV HOST_IP 172.17.0.1

RUN mkdir bin etc log share tmp

COPY --from=build --chown=geneweb /home/opam/geneweb/distribution share/dist

RUN mv share/dist/bases share/data

ENTRYPOINT /usr/local/bin/geneweb.sh

EXPOSE 2316-2317
