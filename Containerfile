ARG FEDORA_VERSION=${FEDORA_VERSION}

FROM scratch AS ctx
COPY build-scripts /
COPY patches /patches
COPY system-files/assets /assets
COPY system-files/ /system-files

FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION}
COPY system-files/common /

ARG IMAGE=${IMAGE}

RUN mkdir -p /usr/lib/bootupd/updates \
    && cp -r /usr/lib/efi/*/*/* /usr/lib/bootupd/updates

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

# Le personalizzazioni vortexos vengono copiate DOPO build.sh così
# sovrascrivono qualsiasi file di sistema-files/wm/ con precedenza garantita.
# Questi file sono elencati in PROTECTED_FILES.txt e NON devono essere
# sovrascritti dal sync upstream automatico.
COPY system-files/custom /

RUN bootc container lint
