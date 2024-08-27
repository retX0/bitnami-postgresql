ARG DOCKER_TAG=16.4.0-debian-12-r3

FROM bitnami/postgresql:${DOCKER_TAG} AS build
USER root
ENV PGVECTOR_VERSION=v0.6.1

RUN set -e; \
    install_packages build-essential git ; \
    git clone --branch $PGVECTOR_VERSION https://github.com/pgvector/pgvector.git /tmp/pgvector ; \
    cd /tmp/pgvector ; \
    make OPTFLAGS="" ; \
    make install ; \
    :

FROM bitnami/postgresql:${DOCKER_TAG}
USER root

# Doc
COPY --from=build \
     /tmp/pgvector/README.md \
     /tmp/pgvector/LICENSE \
       /usr/share/doc/pgvector/

# Code
COPY --from=build \
     /tmp/pgvector/vector.so \
       /opt/bitnami/postgresql/lib/
COPY --from=build \
     /tmp/pgvector/vector.control \
       /opt/bitnami/postgresql/share/extension/
COPY --from=build \
     /tmp/pgvector/sql/*.sql \
       /opt/bitnami/postgresql/share/extension/

## Set the container to be run as a non-root user by default
USER 1001