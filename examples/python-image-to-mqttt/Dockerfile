FROM sixsq/opencv-python as builder

RUN apt update && \
    apt install -y portaudio19-dev python3-pyaudio

COPY requirements.txt ./

RUN pip3 install -r requirements.txt


FROM python:3.7-slim

COPY --from=builder /usr/local/lib/python3.7/site-packages /usr/local/lib/python3.7/site-packages

RUN apt update \
    && apt install -y curl \
    && curl -sL https://deb.nodesource.com/setup_12.x -O \
    && bash setup_12.x \
    && rm setup_12.x \
    && apt install -y nodejs \
    && apt remove -y curl \
    && apt clean \
    && apt autoremove -y --purge \
    && rm -rf /var/lib/apt/lists/* \

RUN npm config set user root \
    && npm install edge-impulse-linux -g --unsafe-perm

COPY obj-rec-2-mqtt.py /opt

WORKDIR /opt

ENTRYPOINT ["./obj-rec-2-mqtt.py"]