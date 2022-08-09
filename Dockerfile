FROM debian:bullseye-slim
LABEL name="twitch-bot-m64p"
LABEL description="Twitch Bot for Playing Mupen64Plus Games"
LABEL maintainer="Anthony Waldsmith <awaldsmith@protonmail.com>"

ENV M64P_DOWNLOAD=https://github.com/mupen64plus/mupen64plus-core/releases/download/2.5.9/mupen64plus-bundle-linux64-2.5.9.tar.gz

RUN apt update -yq \
	&& apt install -y git curl tmux xvfb ffmpeg coreutils binutils python3 python-is-python3 python3-pip libminizip1 libglu1 pulseaudio dbus xdotool

ADD ${M64P_DOWNLOAD} /tmp/m64p.tar.gz

# Install Mupen64Plus
RUN cd /tmp \
	&& tar xzf m64p.tar.gz \
	&& rm m64p.tar.gz \
	&& cd mupen* \
	&& chmod +x install.sh \
	&& ./install.sh \
	&& cd .. \
	&& rm -rf mupen*

# Setup PulseAudio
RUN mkdir -p /var/run/dbus \
	&& dbus-uuidgen > /var/run/dbus/machine-id \
	&& rm -f /run/dbus/pid \
	&& dbus-daemon --system --print-address \
	&& sed -i 's/load-module module-native-protocol-unix/load-module module-native-protocol-unix auth-anonymous=1\nload-module module-native-protocol-tcp auth-anonymous=1 auth-ip-acl=127.0.0.1/g' /etc/pulse/system.pa \
	&& echo "load-module module-null-sink sink_name=loopback" >> /etc/pulse/system.pa \
	&& echo "set-default-sink loopback" >> /etc/pulse/system.pa \
	&& pulseaudio --system -D

WORKDIR /srv

ADD ./ /srv

RUN pip install -r requirements.txt

CMD /bin/bash /srv/entrypoint.sh
