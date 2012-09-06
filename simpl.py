#!/usr/bin/python -OO
import pexpect
#from subprocess import check_output
import subprocess
from os import system

class Prolog:
	def __init__(self):
		self.process = pexpect.spawn('swipl -q --nosignals -O --tty -s hedgehogbot.pl')
		self.process.expect(".*")
		print self.process.after

	def communicate(self,cmd=''):
		self.process.sendline(cmd)
		self.process.expect(".*")
		self.process.sendline('')
		self.process.expect(".*")
		out = ' '.join([line for line in self.process.after.split('\n')[1:-1]])
		print out
		return out

	def restart(self):
		system("killall -s TERM swipl")
		self.__init__()

def get_output(args):
	return subprocess.Popen(args, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE).communicate()[0]

def omnom():
	return ' '.join(get_output(['curl http://omnom.slashingedge.co.uk/lipsum.php']).split('\n'))

if __name__ == '__main__':
	prolog = Prolog()
	while 1:
		s = raw_input('> ')
		print prolog.communicate(s)
