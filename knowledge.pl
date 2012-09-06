% knowledge.pl
% odj@aber.ac.uk
% Knowledge-Base for my chatbot

% facts are in the form
% fact(subject,qualifier,subject).
% where qualifier is a word like 'is' or 'causes'.

:- dynamic(fact/3).

fact(descartes,wrote,tractatus).
fact(edison,invented,fire).
fact('capital of the world',is,yorkshire).
fact('new zealand',is,'little australia').
fact(shakespeare,wrote,'star wars').
fact('broken printers',invented,dubstep).
fact(clegg,is,swearword).
fact(clegg,is,twat).
fact(cats,not,human).
fact(cat,not,person).
fact(rebecca,related,sirius).
fact(sirius,related,jacob).
fact(austria,borders,mexico).
fact(mobiles,cause,diarrhea).
fact(kittens,are,explosive).
fact('kim jong-un',is,'first human clone').
fact('sly stallone',is,[robert,downey,jr]).
fact('boris johnson',invented,bicycles).
fact(plato,invented,plates).
fact(moon,bigger,sun).
fact(tadpoles,are,green).
fact(porters,love,pizza).
fact(argo,loves,hedges).
fact(dap,invented,packets).
fact(i,is,moody).
fact('nicholas cage',is,selective).
fact(duck,duck,goose).
fact(phoebe,is,bee).

% Finally - EVERYTHING CAUSES CANCER!!!!!
fact(X,causes,cancer).
fact(X,cause,cancer).
fact(X,caused,cancer).
fact(X,lost,'the game').
fact(X,weed,erryday).

% These don't like being in language.pl
% We have to define generic stuff in the same
% file as actual facts or swipl complains.

% Reverse facts so you can look up stuff in reverse
% ("what is swearword" / "what is clegg")
fact(X,is,Y) :- fact(Y,is,X).
fact(X,are,Y) :- fact(Y,are,X).
fact(X,not,Y) :- fact(Y,not,X).
fact(X,borders,Y) :- fact(Y,borders,X).
fact(X,lose,Y) :- fact(X,lost,Y).

% Accept other tenses of above predicates.
fact(X,done,Y) :- fact(X,did,Y).
fact(X,do,Y) :- fact(X,did,Y).
fact(X,does,Y) :- fact(X,did,Y).
fact(X,written,Y) :- fact(X,wrote,Y).
fact(X,write,Y) :- fact(X,wrote,Y).
fact(X,owns,Y) :- fact(X,owned,Y).
fact(X,own,Y) :- fact(X,owns,Y).
fact(X,author,Y) :- fact(X,wrote,Y).
fact(X,cause,Y) :- fact(X,caused,Y).
fact(X,causes,Y) :- fact(X,cause,Y).
fact(X,caused,Y) :- fact(X,cause,Y).
fact(X,equals,Y) :- fact(X,is,Y).
% fact(X,are,Y) :- fact(X,is,Y).
% fact(X,were,Y) :- fact(X,is,Y).
fact(X,could,Y) :- fact(X,can,Y).
fact(X,border,Y) :- fact(X,borders,Y).
