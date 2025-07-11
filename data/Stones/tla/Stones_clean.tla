------------------------------- MODULE Stones -------------------------------

EXTENDS Integers, Sequences, FiniteSets, TLC

RECURSIVE SeqSum(_)
SeqSum(s) == IF Len(s) = 0 THEN 0 ELSE Head(s) + SeqSum(Tail(s))

CONSTANTS W, N
ASSUME W \in Nat /\ N \in 1..W

RECURSIVE Partitions(_ , _)
Partitions(seq, wt) ==
IF Len(seq) = N
THEN {seq}
ELSE LET r == N - Len(seq)
max == IF Len(seq) = 0 THEN wt ELSE Head(seq)
S == {x \in 1..max : /\ (r-1) =< (wt - x)
/\ wt =< x*r          }
IN UNION { Partitions(<<x>> \o seq, wt - x ) : x \in S }

Weighs(seq, wt) ==
\E coef \in [1..N -> -1..1] :
SeqSum([i \in 1..N |-> coef[i] * seq[i]]) = wt

ASSUME \/ \E p \in Partitions(<< >>, W) :
IF \A wt \in 1..W : Weighs(p, wt)
THEN PrintT(p)
ELSE FALSE
\/ PrintT("No solution")

=============================================================================
