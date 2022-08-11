FROM debian:bullseye-slim
LABEL name="twitch-bot-m64p"
LABEL description="Twitch Bot for Playing Mupen64Plus Games"
LABEL maintainer="Anthony Waldsmith <awaldsmith@protonmail.com>"

RUN apt update -yq \
	&& apt install -y git curl tmux xvfb ffmpeg coreutils binutils python3 python-is-python3 python3-pip libminizip1 libglu1 pulseaudio dbus xdotool pkg-config libpng-dev libsdl-dev libfreetype-dev nasm

# Install Mupen64Plus
RUN cd /tmp \
	&& echo "M64P: CORE" \
	&& git clone https://github.com/mupen64plus/mupen64plus-core \
	&& cd mupen64plus-core/projects/unix/ \
	&& make all \
	&& make install \
	&& cd /tmp \
	&& echo "M64P: UI-CONSOLE" \
	&& git clone https://github.com/mupen64plus/mupen64plus-ui-console \
	&& cd mupen64plus-ui-console/projects/unix/ \
	&& make all \
	&& make install \
	&& cd /tmp \
	&& echo "M64P: INPUT SDL" \
	&& git clone https://github.com/mupen64plus/mupen64plus-input-sdl \
	&& cd mupen64plus-input-sdl/projects/unix/ \
	&& make all \
	&& make install \
	&& cd /tmp \
	&& echo "M64P: AUDIO SDL" \
	&& git clone https://github.com/mupen64plus/mupen64plus-audio-sdl \
	&& cd mupen64plus-audio-sdl/projects/unix/ \
	&& make all \
	&& make install \
	&& cd /tmp \
	&& echo "M64P: RSP HLE" \
	&& git clone https://github.com/mupen64plus/mupen64plus-rsp-hle \
	&& cd mupen64plus-rsp-hle/projects/unix/ \
	&& make all \
	&& make install \
	&& cd /tmp \
	&& echo "M64P: VIDEO RICE" \
	&& git clone https://github.com/mupen64plus/mupen64plus-video-rice \
	&& cd mupen64plus-video-rice/projects/unix/ \
	&& make all \
	&& make install \
	&& cd /tmp \
	&& echo "M64P: VIDEO GLIDE64 MK2" \
	&& git clone https://github.com/mupen64plus/mupen64plus-video-glide64mk2 \
	&& cd mupen64plus-video-glide64mk2/projects/unix/ \
	&& make all \
	&& make install
	

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
