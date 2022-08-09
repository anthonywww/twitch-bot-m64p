import os
import sys
import subprocess
from twitchio.ext import commands

display = 99
chat_channel = None
chat_prefix = ""
chat_mods_only = False
chat_max_cmds = 8
chat_default_cmd_duration = 300
chat_max_cmd_duration = 5000
whitelist = False
whitelist_list = []

speedlimiter = True

if "DISPLAY" in os.environ:
	display = int(os.environ['DISPLAY'])

if not "TWITCH_OAUTH_SECRET" in os.environ:
	sys.exit("Error: Environment Variable TWITCH_OAUTH_SECRET is required.")

if "CHAT_CHANNEL" in os.environ:
	chat_channel = os.environ['CHAT_CHANNEL']
else:
	sys.exit("Error: Environment Variable CHAT_CHANNEL is required.")

if "CHAT_PREFIX" in os.environ:
	chat_prefix = os.environ['CHAT_PREFIX']

if "CHAT_MODS_ONLY" in os.environ:
	chat_mods_only = True

if "CHAT_MAX_CMDS" in os.environ:
	chat_max_cmds = int(os.environ['CHAT_PREFIX'])

if "CHAT_DEF_CMD_DUR" in os.environ:
	chat_default_cmd_duration = int(os.environ['CHAT_DEF_CMD_DUR'])

if "CHAT_MAX_CMD_DUR" in os.environ:
	chat_max_cmd_duration = int(os.environ['CHAT_MAX_CMD_DUR'])

if "WHITELIST" in os.environ:
	whitelist = True

if "WHITELIST_LIST" in os.environ:
	whitelist_list = os.environ['WHITELIST_LIST'].split(",")





def exec(wait, command):
	process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
	if wait:
		process.wait()
	else:
		process.poll()


class Bot(commands.Bot):

	def __init__(self):
		# Initialise our Bot with our access token, prefix and a list of channels to join on boot...
		super().__init__(token=os.environ['TWITCH_OAUTH_SECRET'], prefix=chat_prefix, initial_channels=[os.environ['CHAT_CHANNEL']])

	async def event_ready(self):
		# We are logged in and ready to chat and use commands...
		print(f'Logged in as: {self.nick}')
		print(f'User id is: {self.user_id}')

	async def event_channel_joined(self, channel):
		await channel.send("/me Connected.")

	async def event_message(self, message):
		global display
		global chat_channel
		global chat_prefix
		global chat_mods_only
		global chat_max_cmds
		global chat_default_cmd_duration
		global chat_max_cmd_duration
		global whitelist
		global whitelist_list
		global speedlimiter
		
		if message.content.startswith(chat_prefix):
			#message.author.name
			#message.author.display_name
			#message.author.color
			#message.author.is_broadcaster
			#message.author.is_mod
			#message.author.is_subscriber
			#message.author.send(str)
			#message.channel
			#message.content
			
			if message == None:
				return
				
			if not hasattr(message, 'author'):
				return
			
			parts = message.content.split(" ")
			
			# Commands
			operator = False
			
			if (hasattr(message.author, 'is_mod') and message.author.is_mod) or (hasattr(message.author, 'is_broadcaster') and message.author.is_broadcaster):
				operator = True
			
			if parts[0] == "help" and len(parts) == 1:
				await message.channel.send(f"/me @{message.author.name} Buttons: a,b,l,r,z,up,down,left,right,cup,cdown,cleft,cright,start")
				await message.channel.send(f"/me @{message.author.name} Syntax: <button> [duration 100-5000]")
				return
			
			if parts[0] == "status" and operator and len(parts) == 1:
				await message.channel.send(f"/me System OK TehePelo")
				return
			
			if parts[0] == "reset" and operator and len(parts) == 1:
				await message.channel.send(f"/me Resetting Emulator")
				exec(True, f"DISPLAY=:{display} xdotool key --clearmodifiers F9")
				return
			
			if parts[0] == "save" and operator and len(parts) == 1:
				await message.channel.send(f"/me Saved Emulator State")
				exec(True, f"DISPLAY=:{display} xdotool key --clearmodifiers F5")
				return
			
			if parts[0] == "load" and operator and len(parts) == 1:
				await message.channel.send(f"/me Loaded Emulator State")
				exec(True, f"DISPLAY=:{display} xdotool key --clearmodifiers F7")
				return
			
			if parts[0] == "limiter" and operator:
				if len(parts) == 2 and (parts[1] == "on" or parts[1] == "off"):
					if parts[1] == "on":
						speedlimiter = True
						await message.channel.send(f"/me CPU Limiter Enabled")
						exec(True, f"DISPLAY=:{display} xdotool keyup f")
						return
					elif parts[1] == "off":
						speedlimiter = False
						await message.channel.send(f"/me CPU Limiter Disabled")
						exec(True, f"DISPLAY=:{display} xdotool keydown f")
						return
				await message.channel.send(f"/me @{message.author.name} speedlimiter <on/off>")
				return
				


			
			
			
			# Buttons handler
			
			commands = []
			
			for i in range(len(parts)):
				key = None
				delay = chat_default_cmd_duration
				if parts[i] == "a":
					key = "shift"
				elif parts[i] == "b":
					key = "ctrl"
				elif parts[i] == "l":
					key = "x"
				elif parts[i] == "r":
					key = "c"
				elif parts[i] == "z":
					key = "z"
				elif parts[i] == "up":
					key = "Up"
				elif parts[i] == "down":
					key = "Down"
				elif parts[i] == "left":
					key = "Left"
				elif parts[i] == "right":
					key = "Right"
				elif parts[i] == "cup":
					key = "i"
				elif parts[i] == "cdown":
					key = "k"
				elif parts[i] == "cleft":
					key = "j"
				elif parts[i] == "cright":
					key = "l"
				elif parts[i] == "start":
					key = "Return"
				
				
				if not key == None:
					if i+1 < len(parts):
						try:
							udelay = int(parts[i+1])
							if udelay >= 100 and udelay <= chat_max_cmd_duration:
								delay = udelay
							else:
								return
						except ValueError:
							pass
					
					commands.append({"key": key, "delay": delay, "async": False})

			if len(commands) > 0 and len(commands) < chat_max_cmds:
				#await message.channel.send(f"/me @{message.author.name} sent {len(commands)} command(s)")
				print(f"{message.author.name} sent {len(commands)} command(s)")
				
				if speedlimiter:
					exec(True, f"DISPLAY=:{display} xdotool keyup f")
				else:
					exec(True, f"DISPLAY=:{display} xdotool keydown f")
				
				for cmd in commands:
					exec(not cmd["async"], f"DISPLAY=:{display} xdotool key --delay {cmd['delay']} {cmd['key']}")
				exec(True, f"DISPLAY=:{display} xdotool key --clearmodifiers 0")



bot = Bot()
bot.run()


