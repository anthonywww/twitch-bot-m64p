#!/usr/bin/env bash

# Change directory to the current script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

SCRIPT="$0"
SCREEN_NUM="99"

TWITCH_CLIENT_ID=${TWITCH_CLIENT_ID:-}
TWITCH_OAUTH_SECRET=${TWITCH_OAUTH_SECRET:-}
TWITCH_STREAMKEY=${TWITCH_STREAMKEY:-}
TWITCH_CHANNEL=${TWITCH_CHANNEL:-}

TITLE="${TITLE:-"Twitch Plays M64P!"}"
TITLE_SIZE=${TITLE_SIZE:-"18"}
TITLE_COLOR=${TITLE_COLOR:-"orange"}

DEBUG=${DEBUG:-}
DEBUG_FONT_SIZE=12
DEBUG_FONT_VSPACE=15
DEBUG_BOX_BORDER=1
DEBUG_BOX_BACKGROUND="0.4"

LOCAL=${LOCAL:-}
LOCAL_PORT=${LOCAL_PORT:-"38000"}

CHAT_MODS_ONLY=${CHAT_MODS_ONLY:-}
CHAT_PREFIX=${CHAT_PREFIX:-""}
CHAT_MAX_CMDS=${CHAT_MAX_CMDS:-"8"}
WHITELIST=${WHITELIST:-}
WHITELIST_LIST=${WHITELIST_LIST:-""}

log() {
	echo -e "$(tput sgr0)${1}$(tput sgr0)"
}

check_installed() {
	# Check if command is installed
	if ! command -v ${1} &> /dev/null; then
		return 0
	fi
	return 1
}

require_installed() {
	# Check if command is installed
	if ! check_installed ${1} == 0; then
    	log "$(tput bold)$(tput setaf 1)${1} (${2}) is not installed, please install it!$(tput sgr0)"
    	exit 1
	fi
}

if [[ -z "${TWITCH_CLIENT_ID}" ]]; then
	log "Environment Variable 'TWITCH_CLIENT_ID' must be set!"
	exit 1
fi
if [[ -z "${TWITCH_OAUTH_SECRET}" ]]; then
	log "Environment Variable 'TWITCH_OAUTH_SECRET' must be set!"
	exit 1
fi
if [[ -z "${TWITCH_STREAMKEY}" ]]; then
	log "Environment Variable 'TWITCH_STREAMKEY' must be set!"
	exit 1
fi

if [[ ! -f "/mnt/rom.z64" ]]; then
	log "Missing file: /mnt/rom.z64! Make sure you volume mount a valid z64 ROM to /mnt/rom.z64."
	exit 127
fi

# Start services
rm -f /var/run/dbus/pid
rm -f /run/dbus/pid
rm -f /run/dbus/system_bus_socket
dbus-daemon --system --print-address
sleep 1
pulseaudio -v --system -D
sleep 1

# Parse game information
mupen64plus --verbose --windowed --cheats list /mnt/rom.z64 > /tmp/m64pdump.txt
GAME_NAME="$(cat /tmp/m64pdump.txt | awk '/Core: Name:/{print substr($0, index($0, " ")+7)}' | tr -d "[:cntrl:]" | tr -d "[:punct:]" | sed -e 's/\ *$//g')"
GAME_CRC="$(cat /tmp/m64pdump.txt | awk '/Core: CRC:/{print substr($0, index($0, " ")+6)}')"
GAME_ROM_SIZE="$(cat /tmp/m64pdump.txt | awk '/Core: Rom size:/{printf "%s", $4}')"
GAME_CARTRIDGE_ID="$(cat /tmp/m64pdump.txt | awk '/Core: Cartridge_ID:/{printf "%s", $3}')"
GAME_CLOCKRATE="$(cat /tmp/m64pdump.txt | awk '/Core: ClockRate/{printf "%s", $4}')"
rm /tmp/m64pdump.txt
mkdir -p /root/.local/share/mupen64plus/hires_texture/ZELDA\ MAJORA\'S\ MASK/


# Start mupen64plus
tmux new-session -d -s "xvfb" -- xvfb-run --server-args ":${SCREEN_NUM} -auth /tmp/xvfb.auth -ac -screen 0 800x600x24" -- mupen64plus --noosd --fullscreen --set Video-Rice[LoadHiResTextures]=True --resolution 800x600 /mnt/rom.z64


if [[ ! -z "${DEBUG}" ]]; then
	ADDITIONAL_DRAWTEXT=", \
	drawtext=text='$(uname -sr) Impl. $(python3 --version) M64P $(mupen64plus --verbose | awk '/Version/{printf "%s", $5}')':fontcolor=yellow:fontsize=${DEBUG_FONT_SIZE}:box=1:boxborderw=${DEBUG_BOX_BORDER}:boxcolor=black@${DEBUG_BOX_BACKGROUND}:x=(w-text_w):y=2, \
	drawtext=text='${GAME_NAME:-"Unknown Game"} | CRC ${GAME_CRC:-"????????"}':fontcolor=yellow:fontsize=${DEBUG_FONT_SIZE}:box=1:boxborderw=${DEBUG_BOX_BORDER}:boxcolor=black@${DEBUG_BOX_BACKGROUND}:x=(w-text_w):y=2+${DEBUG_FONT_VSPACE}, \
	drawtext=text='F\: %{n} T\:%{pts\:hms}':start_number=1:fontcolor=yellow:fontsize=${DEBUG_FONT_SIZE}:box=1:boxborderw=${DEBUG_BOX_BORDER}:boxcolor=black@${DEBUG_BOX_BACKGROUND}:x=(w-text_w):y=2+${DEBUG_FONT_VSPACE}*2, \
	drawtext=text='H\: $(hostname -s)':fontcolor=yellow:fontsize=${DEBUG_FONT_SIZE}:box=1:boxborderw=${DEBUG_BOX_BORDER}:boxcolor=black@${DEBUG_BOX_BACKGROUND}:x=(w-text_w):y=2+${DEBUG_FONT_VSPACE}*3, \
	drawtext=text='ROM\: ${GAME_ROM_SIZE:-"0"} bytes':fontcolor=yellow:fontsize=${DEBUG_FONT_SIZE}:box=1:boxborderw=${DEBUG_BOX_BORDER}:boxcolor=black@${DEBUG_BOX_BACKGROUND}:x=(w-text_w):y=2+${DEBUG_FONT_VSPACE}*4, \
	drawtext=text='CID\: ${GAME_CARTRIDGE_ID:-"????"}':fontcolor=yellow:fontsize=${DEBUG_FONT_SIZE}:box=1:boxborderw=${DEBUG_BOX_BORDER}:boxcolor=black@${DEBUG_BOX_BACKGROUND}:x=(w-text_w):y=2+${DEBUG_FONT_VSPACE}*5, \
	drawtext=text='CLK\: ${GAME_CLOCKRATE:-"?"}':fontcolor=yellow:fontsize=${DEBUG_FONT_SIZE}:box=1:boxborderw=${DEBUG_BOX_BORDER}:boxcolor=black@${DEBUG_BOX_BACKGROUND}:x=(w-text_w):y=2+${DEBUG_FONT_VSPACE}*6, \
	drawtext=text='':fontcolor=yellow:fontsize=${DEBUG_FONT_SIZE}:box=1:boxborderw=${DEBUG_BOX_BORDER}:boxcolor=black@${DEBUG_BOX_BACKGROUND}:x=(w-text_w):y=2+${DEBUG_FONT_VSPACE}*7, \
	drawtext=text='':fontcolor=yellow:fontsize=${DEBUG_FONT_SIZE}:box=1:boxborderw=${DEBUG_BOX_BORDER}:boxcolor=black@${DEBUG_BOX_BACKGROUND}:x=(w-text_w):y=2+${DEBUG_FONT_VSPACE}*8${ADDITIONAL_DRAWTEXT:-""}"
fi


FFMPEG_OUTPUT="-c:v libx264 -r 30 -g 30 -pix_fmt yuv420p -f flv rtmp://live-fra.twitch.tv/app/${TWITCH_STREAMKEY}"
if [[ ! -z "${LOCAL}" ]]; then
	#FFMPEG_OUTPUT="-listen 1 -seekable 0 -multiple_requests 1 -c:v libx264 -f mpegts http://0.0.0.0:${LOCAL_PORT}"
	FFMPEG_OUTPUT="-c:v libx264 -r 30 -g 30 -pix_fmt yuv420p -f mpegts udp://0.0.0.0:${LOCAL_PORT}"
fi

# Start FFMPEG
tmux new-session -d -s "ffmpeg" -- ffmpeg -y -f pulse -i loopback.monitor -c:a aac -strict experimental \
	-video_size 800x600 -framerate 30 -f x11grab -i :${SCREEN_NUM} -preset ultrafast -tune zerolatency -b 900k -threads 0 \
	-vf "[in] \
	drawtext=text='${TITLE}':fontcolor=${TITLE_COLOR}:fontsize=${TITLE_SIZE}:box=1:boxborderw=${DEBUG_BOX_BORDER}:boxcolor=black@${DEBUG_BOX_BACKGROUND}:x=2:y=2${ADDITIONAL_DRAWTEXT}" ${FFMPEG_OUTPUT} >> ffmpeg.log

tmux new-session -s "bot" -- python3 src/bot.py

