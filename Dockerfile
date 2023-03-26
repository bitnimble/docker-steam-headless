# Steam Headless (Arch Linux)
# (WIP) An Arch variant of the steam-headless image
# It is currently my intent to switch to arch as the main
# image base once SteamOS 3 is released (pending review)
#
FROM archlinux:latest
LABEL maintainer="Josh.5 <jsunnex@gmail.com>"

# Update package repos
RUN \
    echo "**** Update package manager ****" \
        && sed -i 's/^NoProgressBar/#NoProgressBar/g' /etc/pacman.conf \
        && echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf \
    && \
    echo

# Update locale
RUN \
    echo "**** Configure locals ****" \
        && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
        && locale-gen \
    && \
    echo
ENV \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Re-install certificates
RUN \
    echo "**** Install certificates ****" \
	    && pacman -Syu --noconfirm --needed \
            ca-certificates \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Install core packages
RUN \
    echo "**** Install tools ****" \
	    && pacman -Syu --noconfirm --needed \
            bash \
            bash-completion \
            curl \
            git \
            less \
            man-db \
            nano \
            net-tools \
            patch \
            pkg-config \
            rsync \
            screen \
            sudo \
            unzip \
            vim \
            wget \
            xz \
    && \
    echo "**** Install python ****" \
	    && pacman -Syu --noconfirm --needed \
            python \
            python-numpy \
            python-pip \
            python-setuptools \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Install supervisor
RUN \
    echo "**** Install supervisor ****" \
	    && pacman -Syu --noconfirm --needed \
            supervisor \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# XFS requirements
# RUN \
#     echo "**** Install XFS requirements ****" \
# 	    && pacman -Syu --noconfirm --needed \
#             xfsdump \
#             xfsprogs \
#     && \
#     echo "**** Section cleanup ****" \
# 	    && pacman -Scc --noconfirm \
#     && \
#     echo

# Install mesa requirements
RUN \
    echo "**** Install mesa and vulkan requirements ****" \
	    && pacman -Syu --noconfirm --needed \
            glu \
            libva-mesa-driver \
            mesa-utils \
            mesa-vdpau \
            opencl-mesa \
            pciutils \
            vulkan-mesa-layers \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Install desktop environment
RUN \
    echo "**** Install Desktop Environment ****" \
	    && pacman -Syu --noconfirm --needed \
            konsole \
            xorg-server \
            xorg-xinit \
            plasma-desktop \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# pacman -Syu --noconfirm --needed \
#     xorg-server \
#     xorg-server-xephyr \
#     xorg-xwininfo \
#     xorg-xhost \
#     xorg-xinit \
#     xorg-xinput \
#     xorg-xrandr \
#     xorg-xprop \
#     xorg-xkill \
#     xorg-xbacklight \
#     xorg-xsetroot
# s
# pacman -Syu --noconfirm --needed autorandr xdg-desktop-portal xdg-desktop-portal-gtk wmctrl xbindkeys xdotool xautolock
#
#
# pacman -Syu --noconfirm --needed gestures
# pacman -Syu --noconfirm --needed numlockx
#
# echo 'Server = https://mirror.fsmg.org.nz/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
#
# Server = https://mirror.pkgbuild.com/$repo/os/$arch
# Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch
# Server = https://mirror.leaseweb.net/archlinux/$repo/os/$arch

# Install audio requirements
RUN \
    echo "**** Install X Server requirements ****" \
	    && pacman -Syu --noconfirm --needed \
            pipewire \
            wireplumber \
            pipewire-pulse \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Install openssh server
RUN \
    echo "**** Install openssh server ****" \
	    && pacman -Syu --noconfirm --needed \
            openssh \
        && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Install noVNC
ARG NOVNC_VERSION=1.2.0
RUN \
    echo "**** Fetch noVNC ****" \
        && cd /tmp \
        && wget -O /tmp/novnc.tar.gz https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz \
    && \
    echo "**** Extract noVNC ****" \
        && cd /tmp \
        && tar -xvf /tmp/novnc.tar.gz \
    && \
    echo "**** Configure noVNC ****" \
        && cd /tmp/noVNC-${NOVNC_VERSION} \
        && sed -i 's/credentials: { password: password } });/credentials: { password: password },\n                           wsProtocols: ["'"binary"'"] });/g' app/ui.js \
        && mkdir -p /opt \
        && rm -rf /opt/noVNC \
        && cd /opt \
        && mv -f /tmp/noVNC-${NOVNC_VERSION} /opt/noVNC \
        && cd /opt/noVNC \
        && ln -s vnc.html index.html \
        && chmod -R 755 /opt/noVNC \
    && \
    echo "**** Modify noVNC title ****" \
        && sed -i '/    document.title =/c\    document.title = "Steam Headless - noVNC";' \
            /opt/noVNC/app/ui.js \
    && \
    echo "**** Section cleanup ****" \
        && rm -rf \
            /tmp/noVNC* \
            /tmp/novnc.tar.gz

# Install nginx
RUN \
    echo "**** Install nginx ****" \
	    && pacman -Syu --noconfirm --needed \
            nginx \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Install Websockify
ARG WEBSOCKETIFY_VERSION=0.10.0
RUN \
    echo "**** Fetch Websockify ****" \
        && cd /tmp \
        && wget -O /tmp/websockify.tar.gz https://github.com/novnc/websockify/archive/v${WEBSOCKETIFY_VERSION}.tar.gz \
    && \
    echo "**** Extract Websockify ****" \
        && cd /tmp \
        && tar -xvf /tmp/websockify.tar.gz \
    && \
    echo "**** Install Websockify to main ****" \
        && cd /tmp/websockify-${WEBSOCKETIFY_VERSION} \
        && python3 ./setup.py install \
    && \
    echo "**** Install Websockify to noVNC path ****" \
        && cd /tmp \
        && mv -v /tmp/websockify-${WEBSOCKETIFY_VERSION} /opt/noVNC/utils/websockify \
    && \
    echo "**** Section cleanup ****" \
        && rm -rf \
            /tmp/websockify-* \
            /tmp/websockify.tar.gz

# Install Steam
# RUN \
#     echo "**** Install steam ****" \
# 	    && pacman -Syu --noconfirm --needed \
#             lib32-vulkan-icd-loader \
#             steam \
#             vulkan-icd-loader \
#     && \
#     echo "**** Section cleanup ****" \
# 	    && pacman -Scc --noconfirm \
#     && \
#     echo

# Add support for flatpaks
# RUN \
#     echo "**** Install flatpak support ****" \
# 	    && pacman -Syu --noconfirm --needed \
#             flatpak \
#             xdg-desktop-portal-gtk \
#     && \
#     echo "**** Section cleanup ****" \
# 	    && pacman -Scc --noconfirm \
#     && \
#     echo

# Install desktop environment
# RUN \
#     echo "**** Install desktop environment ****" \
# 	    && pacman -Syu --noconfirm --needed \
#             kde-system-meta \
#             konsole \
#             plasma \
#     && \
#     echo "**** Section cleanup ****" \
# 	    && pacman -Scc --noconfirm \
#     && \
#     echo

# Install firefox
RUN \
    echo "**** Install firefox ****" \
	    && pacman -Syu --noconfirm --needed \
            firefox \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# # Setup browser audio streaming deps
# RUN \
#     echo "**** Update apt database ****" \
#         && apt-get update \
#     && \
#     echo "**** Install audio streaming deps ****" \
#         && apt-get install -y --no-install-recommends \
#             bzip2 \
#             gstreamer1.0-alsa \
#             gstreamer1.0-gl \
#             gstreamer1.0-gtk3 \
#             gstreamer1.0-libav \
#             gstreamer1.0-plugins-base \
#             gstreamer1.0-plugins-good \
#             gstreamer1.0-pulseaudio \
#             gstreamer1.0-qt5 \
#             gstreamer1.0-tools \
#             gstreamer1.0-x \
#             libgstreamer1.0-0 \
#             libncursesw5 \
#             libopenal1 \
#             libsdl-image1.2 \
#             libsdl-ttf2.0-0 \
#             libsdl1.2debian \
#             libsndfile1 \
#             ucspi-tcp \
#     && \
#     echo "**** Section cleanup ****" \
#         && apt-get clean autoclean -y \
#         && apt-get autoremove -y \
#         && rm -rf \
#             /var/lib/apt/lists/* \
#             /var/tmp/* \
#             /tmp/* \
#     && \
#     echo

# Configure default user and set env
ENV \
    PUID=99 \
    PGID=100 \
    UMASK=000 \
    USER="default" \
    USER_PASSWORD="password" \
    USER_HOME="/home/default" \
    TZ="Pacific/Auckland" \
    USER_LOCALES="en_US.UTF-8 UTF-8"
RUN \
    echo "**** Configure default user '${USER}' ****" \
        && mkdir -p \
            ${USER_HOME} \
        && useradd -d ${USER_HOME} -s /bin/bash ${USER} \
        && chown -R ${USER} \
            ${USER_HOME} \
        && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Add FS overlay
COPY overlay /

# Set display environment variables
ENV \
    XORG_SOCKET_DIR="/tmp/.X11-unix" \
    XDG_RUNTIME_DIR="/tmp/.X11-unix/run" \
    DISPLAY_CDEPTH="24" \
    DISPLAY_DPI="96" \
    DISPLAY_REFRESH="120" \
    DISPLAY_SIZEH="1080" \
    DISPLAY_SIZEW="1920" \
    DISPLAY_VIDEO_PORT="DFP" \
    DISPLAY=":55" \
    NVIDIA_DRIVER_CAPABILITIES="all" \
    NVIDIA_VISIBLE_DEVICES="all"

# Set pulseaudio environment variables
ENV \
    PULSE_SOCKET_DIR="/tmp/pulse" \
    PULSE_SERVER="unix:/tmp/pulse/pulse-socket"

# Set container configuration environment variables
ENV \
    MODE="primary" \
    WEB_UI_MODE="vnc" \
    ENABLE_VNC_AUDIO="true" \
    ENABLE_SUNSHINE="false"

# Configure required ports
ENV \
    PORT_SSH="" \
    PORT_NOVNC_WEB="8083"

# Expose the required ports
EXPOSE 8083

# Set entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
