------------------------------- MODULE Utils -------------------------------
EXTENDS Integers, Sequences, FiniteSets, TLC, Functions, SequencesExt

IsSimpleCycle(S, r) ==

LET
F[ i \in 1..Cardinality(S) ] ==
IF i = 1 THEN << CHOOSE s \in S : TRUE >>
ELSE LET seq == F[i-1]
head == Head(seq)
IN << r[head] >> \o F[i-1]
IN Range(F[Cardinality(S)]) = S

SimpleCycle(S) ==
LET sts == LET SE == INSTANCE SequencesExt IN SE!SetToSeq(S)
RECURSIVE SimpleCycle(_,_,_)
SimpleCycle(seq, prefix, i) ==
IF i = Len(seq)
THEN prefix @@ (seq[i] :> seq[1])
ELSE SimpleCycle(seq, prefix @@ (seq[i] :> seq[i+1]), i+1)
IN SimpleCycle(sts, sts[1] :> sts[2], 2)

=============================================================================
