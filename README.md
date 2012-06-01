HedgehogBot
===========

(Really really silly) Python+SWI-Prolog chatbot for IRC

This is some of the messiest code I've ever written - most of the IRC functionality is thanks to Joel Rosdahl and Jason R. Coombs of http://python-irclib.sourceforge.net/ - the Python library I am using for the IRC interface.
To talk to SWI-Prolog, the 'pexpect' module is also used [http://www.noah.org/wiki/pexpect].

Current features:
	- Ignore lists
	- Admin lists
	- !pl command for running raw prolog statements
	- !fact command for storing new facts in the database
	- Bot can be spoken to in (caveman) natural language; "<Erinaceous> HedgehogBot: what are kittens?" -> "<HedgehogBot> Erinaceous: kittens are explosive". (From fact(kittens,are,explosive))
	- AutoUpdate; using GitHub hooks, my copy of the bot will reload prolog whenever a new git commit is made, meaning new predicates can be added on-the-fly.

I suck at prolog, though, it must be said. I could definitely do with some help improving how it deals with user input :)
