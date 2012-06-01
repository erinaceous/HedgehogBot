#!/usr/bin/python -OO
import pexpect

class Prolog:
	def __init__(self):
		self.process = pexpect.spawn('swipl -x hog.state -q --nosignals -O --tty -s hedgehogbot.pl')
		self.process.expect(".*")
		print self.process.after

	def communicate(self,cmd=''):
		self.process.sendline(cmd)
		self.process.expect(".*")
		self.process.sendline('')
		self.process.expect(".*")
		return ' '.join([line for line in self.process.after.split('\n')[1:-1]])

if __name__ == '__main__':
	prolog = Prolog()
	while 1:
		s = raw_input('> ')
		print prolog.communicate(s)
