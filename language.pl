% language.pl
% odj@aber.ac.uk
% Stock answers to questions

% Generic responses in case user input isn't understood
misunderstood(1,['didn''t hear yoooouuuu.']).
misunderstood(2,['say that again!']).
misunderstood(3,['huh?']).
misunderstood(4,['in layman''s terms?']).
misunderstood(5,['say whaaat?']).
misunderstood(6,['que estas?']).
misunderstood(7,['be clearer!']).
misunderstood(8,['ooh I know some of those words!']).
misunderstood(9,['use your words, dammit!']).
misunderstood(10,['you''re blowing my mind']).
misunderstood(11,['run that past me again butty?']).
misunderstood(12,['je n''ai comprendes pas!']).
misunderstood(13,['very interesting, I''m sure...']).

% Generic responses for when the answer to a question is
% not known (i.e. not in the knowledge base), even though
% we understood the question
unknown(1,['i''m not sure...']).
unknown(2,['nope, no idea.']).
unknown(3,['can''t remember']).
unknown(4,['ummmmmm...']).
unknown(5,['ich weiss nicht...']).
unknown(6,['I dunno!']).
unknown(7,['the answer isn''t coming to me']).
unknown(8,['no fair! how am I supposed to know that!']).

% Generic responses for when we're asking a true or false
% question about a fact.
yes(1,['Yep!']).
yes(2,['True.']).
yes(3,['That''s correct.']).
yes(4,['Correctamundo.']).
yes(5,['You would be right.']).
yes(6,['Pretty sure that''s right.']).
yes(7,['That''s pretty alright yeah.']).
yes(8,['Sounds reasonable.']).
yes(9,['Correct.']).
yes(10,['Fair one!']).
no(1,['Nope.']).
no(2,['WRONG!']).
no(3,['Nooooooooo.']).
no(4,['I wouldn''t count on that...']).
no(5,['I don''t think that''s correct.']).
no(6,['Sorry! Try again - I don''t think that''s right.']).

% Give Prolog a way to access the above responses via an
% index, so we can pick them at random.
% choice(Type,Index,Output).
choice(misunderstood,X,E) :- misunderstood(X,E).
choice(unknown,X,E) :- unknown(X,E).
choice(yes,X,E) :- yes(X,E).
choice(no,X,E) :- no(X,E).
