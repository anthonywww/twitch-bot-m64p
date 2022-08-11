# twitch-bot-m64p

This project builds a Twitch Streamable Dockerized Mupen64Plus container with XVFB and FFMPEG.

### Build
Build the Docker image.
```
./docker-build.sh
```



### Options

#### Environment Variables
| Name                  | Required? | Default Value        | Description                                                                        |
|-----------------------|-----------|----------------------|------------------------------------------------------------------------------------|
| `TWITCH_CLIENT_ID`    | Yes       |                      | Twitch Dev Client Id for Bot. https://dev.twitch.tv/console/apps                   |
| `TWITCH_OAUTH_SECRET` | Yes       |                      | Twitch OAuth Key for Bot. https://twitchapps.com/tmi                               |
| `TWITCH_STREAMKEY`    | Yes       |                      | Your Twitch Stream Key. https://dashboard.twitch.tv                                |
| `TITLE`               | No        | `Twitch Plays M64P!` | Top left overlay text.                                                             |
| `TITLE_SIZE`          | No        | `18`                 | Top left overlay text font size.                                                   |
| `TITLE_COLOR`         | No        | `orange`             | Top left overlay text color.                                                       |
| `DEBUG`               | No        |                      | Show debug overlay on top right. To enable, set to `true`.                         |
| `LOCAL`               | No        |                      | Stream a local UDP MPEGTS instead of Twitch. To enable, set to `true`.             |
| `LOCAL_PORT`          | No        | `38000`              | Set the local UDP MPEGTS port.                                                     |
| `CHAT_CHANNEL`        | Yes       |                      | Your Twitch.tv stream channel name (your username).                                |
| `CHAT_MODS_ONLY`      | No        |                      | Only allows chat moderators to control the bot. To enable, set to `true`.          |
| `CHAT_PREFIX`         | No        |                      | Bot commands must be prefixed with this to control the bot. i.e. `!`.              |
| `CHAT_MAX_CMDS`       | No        | `8`                  | Only allow a max of `8` commands in a single chat submission.                      |
| `CHAT_DEF_CMD_DUR`    | No        | `300`                | Default time that a button is held down for in milliseconds if not specified.      |
| `CHAT_MAX_CMD_DUR`    | No        | `5000`               | Maximum time that a button may be held down for in milliseconds.                   |
| `WHITELIST`           | No        |                      | Enable only whitelisted users to control the bot. To enable, set to `true`.        |
| `WHITELIST_LIST`      | No        |                      | Comma separated list of usernames to allow to control the bot.                     |

#### Chat Commands
All these buttons have an optional milliseconds parameter.
Button commands are executed in sequential order and wait for the previous command to finish before executing the next command.

You can execute a set of button commands at the same time without waiting for the previous button command to finish by using asynchronous blocks.

- `a` - A-Button.
- `b` - B-Button.
- `l` - L-Trigger.
- `r` - R-Trigger.
- `z` - Z-Trigger.
- `up` - Analog-Up.
- `down` - Analog-Down.
- `left` - Analog-Down.
- `right` - Analog-Down.
- `cup` - C-Up.
- `cdown` - C-Down.
- `cleft` - C-Left.
- `cright` - C-Right.
- `start` - Start/Pause button.
- `{` - Begin asynchronous block. Group a set of button commands in curly braces to execute them at the same time.
- `}` - End asynchronous block.

A few examples:

- `up` = Analog-Up for 300ms.
- `down 500` = Analog-Down for 500ms.
- `up left 2000 up 500 b b 3000` = Analog-Up for 300ms, then Analog-Left for 2s, then Analog-Up for 500ms, then B-Button for 300ms, then B-Button for 3s.
- `l up 1000 { up right up right up right }` = L-Trigger for 300ms, then Analog-Up for 1s, then Analog-Up and Analog-Right at the same time for 300ms three times.

#### Chat Moderator Commands
- `status` - Show emulation status.
- `reset` - Restart the emulator.
- `limiter <on/off>` - Enable or disable the speed limiter on the emulator.
- `modsonly <on/off>` - Enable or disable moderator-only mode.
- `whitelist list` - List all users in the whitelist.
- `whitelist <on/off>` - Enable/Disable only whitelisted users to control the bot.
- `whitelist add <user>` - Add a user to the whitelist.
- `whitelist remove <user>` - Remove a user from the whitelist.





### Deployment

### Stream to Twitch
Run the container as production.
Where `TWITCH_CLIENT_ID` and `TWITCH_SECRET` is provided by your dev.twitch.tv application.
```sh
docker run -d --name majoras-mask \
	-v "/home/user/Desktop/majoras_mask.z64:/mnt/rom.z64:ro" \
	-e TWITCH_CLIENT_ID="abcdef" \
	-e TWITCH_OAUTH_SECRET="oauth:ghijklm" \
	-e TWITCH_STREAMKEY="nopqrst" \
	-e TITLE="Majoras Mask" \
	-e TITLE_COLOR="purple" \
	-e CHAT_CHANNEL="twitchplaysmajora" \
	twitch-bot-m64p
```

### Stream Locally (Test)
```sh
docker run --rm -it \
	-v "/home/user/Desktop/majoras_mask.z64:/mnt/rom.z64:ro" \
	--net=host \
	-e DEBUG="true" \
	-e LOCAL="true" \
	-e TWITCH_CLIENT_ID="abcdef" \
	-e TWITCH_OAUTH_SECRET="oauth:ghijklm" \
	-e TWITCH_STREAMKEY="nopqrst" \
	-e CHAT_CHANNEL="twitchplaysmajora" \
	twitch-bot-m64p
```

### Development (Test)
```sh
docker run --rm -it \
	-v "$(pwd):/srv:ro" \
	-v "/home/user/Desktop/majoras_mask.z64:/mnt/rom.z64:ro" \
	--net=host \
	-e DEBUG="true" \
	-e LOCAL="true" \
	-e TWITCH_CLIENT_ID="abcdef" \
	-e TWITCH_OAUTH_SECRET="oauth:ghijklm" \
	-e TWITCH_STREAMKEY="nopqrst" \
	-e CHAT_CHANNEL="twitchplaysmajora" \
	twitch-bot-m64p bash
```










