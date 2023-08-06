FROM ubuntu:22.04
ENV DEBIAN_FRONTEND noninteractive

ENV DEBIAN_FRONTEND noninteractive

#ARG LO_PPA=libreoffice-fresh
ARG LO_PPA=ppa
ARG USER_ID=1000
ARG GROUP_ID=1000

LABEL name="Libreoffice-API-FULL" \
    description="A LibreOffice server - LibreOffice API Access" \
    maintainer="DockDock"

RUN apt-get update -y \
    && apt-get full-upgrade -y \
    && apt-get install --no-install-recommends -y \
    software-properties-common \
    apt-utils \
    bash-completion \
    curl \
    htop \
    ncurses-term \
    python3 \
    gpg-agent \
    python-is-python3 \
    default-jre-headless \
    poppler-data \
    poppler-utils \
    graphicsmagick \
    tzdata \
    enchant-2 \
    && add-apt-repository ppa:libreoffice/ppa -y \
    && apt-get update -y \
    && apt-get install -y libreoffice \
    libreoffice-script-provider-python \
    && ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
    && echo "UTC" > /etc/timezone \
    && dpkg-reconfigure tzdata \
    && apt-get purge -y libreoffice-gnome* libreoffice-gtk* libreoffice-help* libreoffice-kde* \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && fc-cache -f \
    && groupadd -g $GROUP_ID dockdock \
    && useradd --shell /bin/bash -u $USER_ID -g $GROUP_ID -o -c "dockdock base user" -m dockdock

ENV LC_ALL="en_US.UTF-8" \
    LC_CTYPE="en_US.UTF-8" \
    LANG="C.UTF-8"

EXPOSE 2002

USER dockdock
WORKDIR /home/dockdock
HEALTHCHECK --interval=5s --timeout=1s CMD timeout 1s bash -c ':> /dev/tcp/127.0.0.1/2002'
# initilize ~/.config/libreoffice
RUN soffice --headless --terminate_after_init

CMD soffice '--accept=socket,host=0.0.0.0,port=2002;urp;StarOffice.ServiceManager' --nologo --headless --nofirststartwizard --norestore
