#! /usr/bin/env python
# Simple IRC bot, originally by:
# Joel Rosdahl <joel@rosdahl.net>
#
# Modified to be a bridge to SWI-Prolog by:
# Owain Jones <tehdoomcat@gmail.com>

"""HogBot

This is the SingleServerIRCBot class from
irc.bot.  The bot enters a channel and listens for commands in
private messages and channel traffic.  Commands in channel messages
are given by prefixing the text by the bot name followed by a colon.

The known commands are:

    disconnect -- Disconnect the bot.  The bot will try to reconnect
                  after 60 seconds.

    die -- Let the bot cease to exist.

    ignore user -- add a nick to the 'ignore' list. When they attempt to talk to
    the bot they'll be greeted with 'EAT A DICK' or something equally as nice.
    NOTE: Not persistent! If you want certain people (Bots) always ignored, look
    at config.py

    unignore user -- remove someone from the 'ignore' list.

    admin user -- add someone to the 'admins' list... allows them to run !pl statements.

    !pl statement -- run a raw prolog statement. only runs once you add the final '.'

    !say statement -- say something (apologise for spamming up channels with 'false.')

    !fact data,of,fact -- add a fact to the database. all facts must be of form:
    Who,What,Where/When,Who - as the prolog predicate is fact/3.

    Anything prexied with the bot's nick will be interpreted as
    a question, e.g. "HedgehogBot: what bigger sun?" to which the reply will be
    <HedgehogBot> Nick: moon bigger sun.

"""

import irc.bot, simpl, config
from util import *
from irc.client import nm_to_n, irc_lower, ip_numstr_to_quad, ip_quad_to_numstr
from os import system

lastUpdated = file_get_contents('hook.txt')

class HedgehogBot(irc.bot.SingleServerIRCBot):
    def __init__(self, channel, nickname, server, port=6667):
        irc.bot.SingleServerIRCBot.__init__(self, [(server, port)], nickname, nickname)
        self.channel = channel
	self.ignore = config.GLOBAL_IGNORE
	self.admins = config.GLOBAL_ADMINS
	self.prolog = simpl.Prolog()
	self.cmdbuffer = {}

    def on_nicknameinuse(self, c, e):
        c.nick(c.get_nickname() + "_")

    def on_welcome(self, c, e):
        c.join(self.channel)

    def on_privmsg(self, c, e):
        #self.do_command(c, e, e.arguments()[0])
	self.on_pubmsg(c, e)

    def on_pubmsg(self, c, e):
	#print e.arguments()[0]
	global lastUpdated
	if file_get_contents('hook.txt') != lastUpdated:
		lastUpdated = file_get_contents('hook.txt')
		system('git pull')
		out = self.prolog.communicate("['hedgehogbot.pl'].")
		print 'Git updated! Reloaded prolog scripts...'
		print out

        a = e.arguments()[0].split(":", 1)
        if len(a) > 1 and irc_lower(a[0]) == irc_lower(self.connection.get_nickname()):
            self.do_command(c, e, a[1].strip())
        elif e.arguments()[0][:3] == "!pl":
	    if nm_to_n(e.source()).lower() in self.admins:
		    self.eval_command(c, e, e.arguments()[0][3:])
	elif e.arguments()[0][:4] == "!say":
	    c.privmsg(self.channel, e.arguments()[0][5:])
	elif e.arguments()[0][:5] == "!fact":
	    fact = "assert(fact("+e.arguments()[0][6:]+")). remember."
	    self.eval_command(c, e, fact)
        return

    def on_dccmsg(self, c, e):
        c.privmsg("You said: " + e.arguments()[0])

    def on_dccchat(self, c, e):
        if len(e.arguments()) != 2:
            return
        args = e.arguments()[1].split()
        if len(args) == 4:
            try:
                address = ip_numstr_to_quad(args[2])
                port = int(args[3])
            except ValueError:
                return
            self.dcc_connect(address, port)

    def eval_command(self,c, e, cmd):
	nick = nm_to_n(e.source()).lower()
	c = self.connection
	if len(cmd) <= 1: return
	if cmd[-1] == '.':
		if nick in self.cmdbuffer.keys():
			cmd = ''.join(self.cmdbuffer[nick]) + cmd
			self.cmdbuffer[nick] = []
		else:
			self.cmdbuffer[nick] = []
		out = self.prolog.communicate(cmd)
		print nick,'-',out
		c.privmsg(self.channel, nick+": "+out)		
	else:
		if nick in self.cmdbuffer.keys():
			self.cmdbuffer[nick].append(cmd)
		else:
			self.cmdbuffer[nick] = []
			self.cmdbuffer[nick].append(cmd)

    def do_command(self, c, e, cmd):
        nick = nm_to_n(e.source())
        c = self.connection

	if nick.lower() in config.BOT_IGNORE:
		return
	elif nick.lower() in self.ignore:
		c.privmsg(self.channel, nick+": EAT A DICK")
		return

        if cmd == "disconnect":
            self.prolog.terminate()
            self.disconnect()
        elif cmd == "die":
	    self.prolog.terminate()
            self.die()
	elif cmd[:5] == "admin":
	    self.admins.update([cmd[6:].lower()])
	elif cmd[:6] == "ignore":
	    print cmd[:6], '-', cmd[7:].lower()
	    self.ignore.update([cmd[7:].lower()])
        elif cmd == "stats":
            for chname, chobj in self.channels.items():
                c.notice(nick, "--- Channel statistics ---")
                c.notice(nick, "Channel: " + chname)
                users = chobj.users()
                users.sort()
                c.notice(nick, "Users: " + ", ".join(users))
                opers = chobj.opers()
                opers.sort()
                c.notice(nick, "Opers: " + ", ".join(opers))
                voiced = chobj.voiced()
                voiced.sort()
                c.notice(nick, "Voiced: " + ", ".join(voiced))
        elif cmd == "dcc":
            dcc = self.dcc_listen()
            c.ctcp("DCC", nick, "CHAT chat %s %d" % (
                ip_quad_to_numstr(dcc.localaddress),
                dcc.localport))
	elif cmd[:8] == "unignore":
	   self.ignore.discard(cmd[9:].lower())
        else:
	     out = self.prolog.communicate("single. \""+cmd+"\".")
	     if(len(out) >= 1):
		     print nick,'-',out
	             c.privmsg(self.channel, nick+": "+out)

def main():
    import sys
    if len(sys.argv) != 4:
        print "Usage: hedgehogbot <server[:port]> <channel> <nickname>"
        sys.exit(1)

    s = sys.argv[1].split(":", 1)
    server = s[0]
    if len(s) == 2:
        try:
            port = int(s[1])
        except ValueError:
            print "Error: Erroneous port."
            sys.exit(1)
    else:
        port = 6667
    channel = sys.argv[2]
    nickname = sys.argv[3]

    bot = HedgehogBot(channel, nickname, server, port)
    bot.start()

if __name__ == "__main__":
    main()
