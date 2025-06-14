------------------------------ MODULE AddTwo --------------------------------

EXTENDS Naturals, TLAPS

VARIABLE x

vars == << x >>

Init ==
/\ x = 0

Next == x' = x + 2

Spec == Init /\ [][Next]_vars

TypeOK == x \in Nat

THEOREM TypeInvariant == Spec => []TypeOK
<1>a. Init => TypeOK
BY DEF Init, TypeOK
<1>b. TypeOK /\ UNCHANGED vars => TypeOK'
BY DEF TypeOK, vars
<1>c. TypeOK /\ Next => TypeOK'
BY DEF TypeOK, Next
<1> QED BY PTL, <1>a, <1>b, <1>c DEF Spec

a|b == \E c \in Nat : a*c = b

Even == 2|x

THEOREM Spec => []Even
<1>a. Init => Even
BY DEF Init, Even, |
<1>b. Even /\ UNCHANGED vars => Even'
BY DEF Even, vars
<1>c. Even /\ Next => Even'
BY \A c \in Nat : c+1 \in Nat /\ 2*(c+1) = 2*c + 2, Zenon
DEF TypeOK, Even, Next, |
<1> QED BY PTL, <1>a, <1>b, <1>c DEF Spec

=============================================================================
