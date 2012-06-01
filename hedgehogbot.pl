:- use_module(library(qsave)).

hedgehog(A) :- true.

:- ['parse'].

remember :-
	qsave_program("hog.state").
