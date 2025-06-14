This spec was inspired by https://github.com/microsoft/CCF/blob/main/tla/consensus/abs.tla.

This spec has a machine-closed fairness constraint, which differs from the the CRDT and
ReplicatedLog examples.  However, this spec assumes that a server can consistently read the
state of all other servers, which is clearly not a realistic assumption for a real
distributed system.  A real system would rely on some messaging protocol to determine the
lag between servers (compare Raft).

---- MODULE DistributedReplicatedLog ----
EXTENDS Sequences, SequencesExt, Integers, FiniteSets, FiniteSetsExt

CONSTANT Lag, Servers, Values
ASSUME Lag \in Nat /\ IsFiniteSet(Servers)

VARIABLE cLogs
vars == <<cLogs>>

TypeOK ==
/\ cLogs \in [Servers -> Seq(Values)]

Init ==
/\ cLogs \in [Servers -> {<< >>}]

Copy(i) ==
\E j \in Servers:
/\ Len(cLogs[j]) > Len(cLogs[i])
/\
LET L == (Len(cLogs[j]) - Len(cLogs[i]))

IN  \E l \in L-1 .. L:
cLogs' = [cLogs EXCEPT ![i] = @ \o SubSeq(cLogs[j], Len(@) + 1, Len(@) + l)]

Extend(i) ==
/\ \A j \in Servers:
Len(cLogs[j]) \leq Len(cLogs[i])
/\ \E s \in BoundedSeq(Values, Lag - Max({Len(cLogs[i]) - Len(cLogs[j]) : j \in Servers})):
cLogs' = [cLogs EXCEPT ![i] = @ \o s]

Next ==
\E i \in Servers:
\/ Copy(i)
\/ Extend(i)

Spec ==
/\ Init
/\ [][Next]_vars
/\ \A s \in Servers: WF_vars(Extend(s)) /\ WF_vars(Copy(s))

----

Abs(n) ==
IF n < 0 THEN -n ELSE n

BoundedLag ==
\A i, j \in Servers: Abs(Len(cLogs[i]) - Len(cLogs[j])) <= Lag

THEOREM Spec => []BoundedLag

----

AllExtending ==
\A s \in Servers: []<><<IsStrictPrefix(cLogs[s], cLogs'[s])>>_cLogs

THEOREM Spec => AllExtending

InSync ==

\A i, j \in Servers : []<>(cLogs[i] = cLogs[j])

====
