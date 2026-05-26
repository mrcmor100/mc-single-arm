FROM rootproject/root:6.30.02-alma9

LABEL org.opencontainers.image.title="mc-single-arm"
LABEL org.opencontainers.image.description="Containerized Hall C mc-single-arm"
LABEL org.opencontainers.image.source="https://github.com/JeffersonLab/mc-single-arm"

RUN dnf install -y gcc-gfortran gcc-c++ make python3 pcre pcre-devel \
    && dnf clean all

WORKDIR /opt/mc-single-arm
COPY . /opt/mc-single-arm

RUN chmod +x /opt/mc-single-arm/bin/mc-single-arm-api /opt/mc-single-arm/bin/mc-single-arm-run \
    && mkdir -p /data/infiles /data/outfiles /data/runout /data/worksim /opt/mc-single-arm/share \
    && cp -r /opt/mc-single-arm/infiles /opt/mc-single-arm/share/infiles \
    && rm -rf /opt/mc-single-arm/infiles /opt/mc-single-arm/outfiles /opt/mc-single-arm/runout /opt/mc-single-arm/worksim \
    && ln -s /data/infiles /opt/mc-single-arm/infiles \
    && ln -s /data/outfiles /opt/mc-single-arm/outfiles \
    && ln -s /data/runout /opt/mc-single-arm/runout \
    && ln -s /data/worksim /opt/mc-single-arm/worksim \
    && cp -n /opt/mc-single-arm/share/infiles/*.inp /data/infiles/ \
    && ROOT_PREFIX="$(root-config --prefix)" \
    && make -C /opt/mc-single-arm/src clean all \
    && make -C /opt/mc-single-arm/util/root_tree clean all ROOTSYS="$ROOT_PREFIX" \
    && ln -s /opt/mc-single-arm/bin/mc-single-arm-api /usr/local/bin/mc-single-arm-api \
    && ln -s /opt/mc-single-arm/bin/mc-single-arm-run /usr/local/bin/mc-single-arm-run

ENV MC_SINGLE_ARM_APP_ROOT=/opt/mc-single-arm
ENV MC_SINGLE_ARM_DATA_ROOT=/data

VOLUME ["/data"]
CMD ["mc-single-arm-run", "--help"]
