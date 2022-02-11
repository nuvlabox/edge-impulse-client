FROM python:3.7-slim as base

RUN apt update && \
    apt install -y gcc \
                build-essential  \
                make \
                portaudio19-dev \
                curl

COPY requirements.txt ./

RUN pip install edge_impulse_linux

WORKDIR /tmp

RUN curl -sL https://deb.nodesource.com/setup_12.x -O


FROM python:3.7-slim

COPY --from=base /usr/local/lib/python3.7/site-packages/ /usr/local/lib/python3.7/site-packages/

COPY --from=base /tmp/setup_12.x ./setup_12.x

RUN bash setup_12.x

RUN apt update && \
    apt-get install -y ffmpeg \
                    libsm6 \
                    libxext6 \
                    portaudio19-dev \
                    nodejs && \
    apt clean && \
    apt autoremove -y --purge && \
    rm -rf /var/lib/apt/lists/* && \
    rm setup_12.x

RUN npm config set user root \
    && npm install edge-impulse-linux -g --unsafe-perm

COPY obj-rec-2-mqtt.py /opt

WORKDIR /opt

ENTRYPOINT ["./obj-rec-2-mqtt.py"]
