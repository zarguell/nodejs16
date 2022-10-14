######################## Base Args ########################
ARG BASE_REGISTRY=docker.io
ARG BASE_IMAGE=zarguell/ubi8
ARG BASE_TAG=latest

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG} as builder

# ARG BASE_REGISTRY=registry1.dso.mil
# ARG BASE_IMAGE=ironbank/redhat/ubi/ubi8
# ARG BASE_TAG=8.6

# FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG} as builder

FROM node:16.18.0 as base

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

ENV HOME=/home/node \
    USER=node

RUN groupadd -g 1001 node && \
    useradd -r -u 1001 -m -s /sbin/nologin -g node node && \
    chown node:0 ${HOME} && \
    chmod g=u ${HOME} && \
    dnf update -y && \
    dnf clean all && \
    rm -rf /var/cache/dnf

COPY --from=base /usr/local/bin /usr/local/bin
COPY --from=base /usr/local/include /usr/local/include
COPY --from=base /usr/local/share/man /usr/local/share/man
COPY --from=base /usr/local/share/doc /usr/local/share/doc
COPY --from=base /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=base /opt /opt
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod 755 /usr/local/bin/docker-entrypoint.sh && \
    chmod g-s /opt/yarn-v*/bin /opt/yarn-v*/lib && \
    chgrp -R root /opt/yarn-v* && \
    chgrp root /opt/yarn-v*/lib/* /opt/yarn-v*/bin/* /opt/yarn-v*/*

WORKDIR ${HOME}
USER 1001

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["node"]

HEALTHCHECK NONE
