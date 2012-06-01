% parse.pl
% odj@aber.ac.uk
% The brunt of the program is in here.

% The code for splitting a sentence into a list of words
% using a DCG has been copied from:
% http://stackoverflow.com/a/6104707
% and modified to do more.

% Tell Prolog what a sentence consists of
sentence([A|As]) -->
	spaces(_),
	chars([X|Xs]),
	{atom_codes(A, [X|Xs])},
	puncts(_),
	spaces(_),
	sentence(As).
sentence([]) --> [].

% Recursively search for characters (not whitespace or punctuation)
% If char(X) fails, continue with [Xs] list.
chars([X|Xs]) --> char(X), !, chars(Xs).
chars([]) --> [].

% Same as above but for spaces.
spaces([X|Xs]) --> space(X), !, spaces(Xs).
spaces([]) --> [].

% " " punctuation characters.
puncts([X|Xs]) --> punct(X), !, puncts(Xs).
puncts([]) --> [].

% Tell Prolog what constitutes whitespace, punctuations and valid chars.
space(X) --> [X], {code_type(X, space)}.
punct(X) --> [X], {code_type(X, punct)}, {\+ X = ''''}.
char(X) --> [X],
	{\+ code_type(X, space)}, {\+ code_type(X, punct)}.
termination(X) --> ['.',' '].

% Convert everything to lowercase
% http://objectmix.com/prolog/183135-converting-string-uppercase-lowercase.html
% Modified to work with atoms rather than single chars
tolower([],[]).
tolower([Upper|UpperTail],[Lower|LowerTail]) :-
	downcase_atom(Upper,Lower),
	tolower(UpperTail,LowerTail).

% Take a phrase and parse it with the DCG above.
% Store the resulting list in 'Atoms' variable.
parseSentence(Codes,Atoms) :-
	(phrase(sentence(AtomList), Codes) ->
		% Normalize: Make everything lowercase
		tolower(AtomList, Atoms)
	).

% Routine for printing the bot's response to console.
% Takes a normal list and just chucks spaces in between
% the elements.
printList([]) :- !,fail.
printList([X]) :-
	writeln(X).
printList([H|T]) :-
	write(H),
	write(' '),
	printList(T).

% Load the knowledge-base.
:- ['knowledge'].

% Load the language definitions afterwards, knowledge
% from the knowledge base will now be true for multiple
% tenses (e.g. X caused Y, X causes Y, X cause Y, ...)
:- ['language'].

% BUGFIX: For some reason, you have to load
% the knowledge base twice or it stack overflows like mad.
:- ['knowledge'].

% Predicate for testing whether user input is a question
is_question(Input) :-
	parseSentence(Input,Atoms),
	question(Atoms,_).

% Handle user input
reply(Input) :-
	parseSentence(Input, Question),
	input(Question,Answer),
	writeln(Answer), nl.
	%printList(Answer), nl.

% Recursively search a list for an item
on(Item,[Item|Rest]).
on(Item,[_|Tail]) :-
	on(Item,Tail).

% Pick a specific predicate from the list of predicates of
% the same type (choose(misunderstood,E) will make E =
% misunderstood(_,_). 
choose([],_) :- !, fail.
choose(List,Elem) :-
	aggregate_all(count, choice(List,X,_),Length),
	random(1, Length, Index),
	choice(List,Index,Elem).

% Look for quit keywords in input
quit(Input) :-
	end(Input,_), writeln('Goodbye!'),nl.

output(X).

% Gracefully handle bad input...
% Tell the user we didn't understand their
% question/statement, rather than going 'false'
% and breaking out of the loop annoyingly.
input([],S) :-
	choose(misunderstood,A),
	sformat(S, '~w', A).
input([_],S) :- input([],S).
input([_,_],S) :- input([],S).

% Handle input of the form "are X Y"
% % % e.g. "are kittens explosive?"
% % Q = kittens, A = explosive
% % O = yes/no, S = output string
input([are,Q,A],S) :-
          (fact(Q,T,A),
          choose(yes,O),
          sformat(S, '~w ~w ~w ~w.', [O,Q,are,A]))
          ;
          choose(no,O), sformat(S, '~w', O).
input([is,Q,A],S) :- input([are,Q,A],S).
input([do,Q,A],S) :- input([are,Q,A],S).

% Handle good input of the form
% "What X Y" - e.g. "what are kittens"
input([_,T,Q],S) :-
        (fact(A,T,Q),
        sformat(S, '~w ~w ~w.', [A,T,Q]))
        ;
        choose(unknown,A), sformat(S, '~w', A).

% Handle the inverse of that:
% "what are explosive" - "kittens are explosive"
input([_,T,Q],S) :-
	(fact(Q,T,A),
	sformat(S, '~w ~w ~w.', [Q,T,A]))
	;
	choose(unknown,A), sformat(S, '~w', A).

% Handle questions of the form
% "is X a Y" - e.g. "is clegg a swearword"
input([did,N,T,Q],S) :-
	(fact(N,T,Q),
	choose(yes,A),
	sformat(S, '~w ~w ~w ~w.', [A,N,T,Q]))
	;
	choose(no,A), sformat(S, '~w', A).

% Handle some variants of above question format
input([does,N,T,Q],S) :- input([did,N,T,Q],S).
input([do,N,T,Q],S) :- input([did,N,T,Q],S).
input([can,N,T,Q],S) :- input([did,N,T,Q],S).
input([are,N,T,Q],S) :- input([did,N,T,Q],S).
input([is,N,a,Q],S) :- input([did,N,is,Q],S).

% Put everything in a Read-eval-print loop
start :-
	writeln('Welcome to the PHILOSOCRATICA COSMOLOGICUS!'),
	writeln('Ready to ax me some questions?'),
	loop.

loop :-
	read(I),
	reply(I),
	loop.

single :-
	read(I),
	reply(I).

% THUNDERBIRDS ARE GO!
start.
