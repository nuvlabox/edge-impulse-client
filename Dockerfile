FROM sixsq/opencv-python

RUN apt update \
    && apt install -y curl \
    && curl -sL https://deb.nodesource.com/setup_12.x -O \
    && bash setup_12.x \
    && rm setup_12.x

RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    bison \
    build-essential \
    ca-certificates \
    flex \
    gettext \
    libffi-dev \
    libglib2.0 \
    libnice-dev \
    libopus-dev \
    libpcre3-dev \
    libsrtp-dev \
    libssl-dev \
    libvpx-dev \
    libx264-dev \
    mount \
    perl \
    wget \
    zlib1g \
    ninja-build \
    nodejs \
    sox \
    libjpeg8-dev

RUN pip3 install meson

RUN wget https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.19.3.tar.xz \
    && tar xvfJ gstreamer-1.19.3.tar.xz > /dev/null \
    && cd gstreamer-1.19.3 \
    && meson build \
    && ninja -C build \
    && ninja -C build install \
    && cd - \
    && rm -r gstreamer-1.19.3*

RUN wget https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-1.19.3.tar.xz \
    && tar xvfJ gst-plugins-base-1.19.3.tar.xz > /dev/null \
    && cd gst-plugins-base-1.19.3 \
    && meson build \
    && ninja -C build \
    && ninja -C build install \
    && cd - \
    && rm -r gst-plugins-base-1.19.3*

RUN wget https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-1.19.3.tar.xz \
    && tar xvfJ gst-plugins-good-1.19.3.tar.xz > /dev/null \
    && cd gst-plugins-good-1.19.3 \
    && meson build \
    && ninja -C build \
    && ninja -C build install \
    && cd - \
    && rm -r gst-plugins-good-1.19.3*

RUN npm config set user root \
    && npm install edge-impulse-linux -g --unsafe-perm

RUN apt remove -y ninja-build wget \
    && pip uninstall -y meson \
    && apt clean \
    && apt autoremove -y --purge \
    && rm -rf /var/lib/apt/lists/*