FROM accetto/ubuntu-vnc-xfce-g3

# Switch to root user to avoid permission issues
USER root

# Expose ports
EXPOSE 5901 6901 4455

# Set environment variables
ENV VNC_PASSWD=headless
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"
ENV LIBVA_DRIVER_NAME=iHD

# Install dependencies and clean up
RUN apt-get update && \
    apt-get install -y avahi-daemon xterm git build-essential cmake curl git libboost-dev libnss3 mesa-utils qtbase5-dev strace x11-xserver-utils net-tools python3 python3-numpy scrot wget vlc jq udev unrar qt5-image-formats-plugins software-properties-common intel-media-va-driver-non-free libigdgmm12 va-driver-all library-va-utils vainfo && \
    add-apt-repository -y ppa:obsproject/obs-studio && \
    apt-get update && \
    apt-get install -y ffmpeg obs-studio && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /config /root/.config /home/headless/.vnc && \
    chown -R headless:headless /config /root/.config /home/headless/.vnc && \
    sed -i 's/geteuid/getppid/' /usr/bin/vlc && \
    ln -s /config/obs-studio/ /root/.config/obs-studio && \
    wget -q -O /tmp/distroav.deb https://github.com/DistroAV/DistroAV/releases/download/6.2.1/distroav-6.2.1-x86_64-linux-gnu.deb && \
    wget -q -O /tmp/libndi-get.sh https://raw.githubusercontent.com/DistroAV/DistroAV/master/CI/libndi-get.sh && \
    chmod +x /tmp/libndi-get.sh && \
    cd /tmp && ./libndi-get.sh && \
    dpkg -i /tmp/*.deb && \
    rm -rf /tmp/*

VOLUME ["/config"]
COPY service-start.sh /dockerstartup/service-start.sh
ENTRYPOINT ["/dockerstartup/service-start.sh"]
