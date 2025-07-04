------------------------- MODULE sums_even -------------------------

EXTENDS Naturals, TLAPS

Even(x) == x % 2 = 0
Odd(x) == x % 2 = 1

THEOREM \A x \in Nat : Even(x+x)
BY Z3 DEF Even

THEOREM T1 == \A x \in Nat: Even(x+x)
<1>a TAKE x \in Nat
<1>1 \A z \in Nat : Even(z) \/ Odd(z) BY DEF Even, Odd
<1>2 CASE Even(x)
<2> USE <1>2
<2> ((x % 2) + (x % 2)) % 2 = (x+x)%2  BY <1>1 DEF Even, Odd
<2> DEFINE A == x%2
<2> HIDE DEF A
<2> A = 0 => (A + A) % 2 = (0+0) %2 BY SMT DEF Even
<2> QED BY DEF Even, A
<1>3 CASE Odd(x)
<2> USE <1>3
<2> ((x % 2) + (x % 2)) % 2 = (x+x)%2 BY <1>1 DEF Even, Odd
<2> DEFINE A == x%2
<2> HIDE DEF A
<2> A = 1 => (A + A) % 2 = (1+1) %2 BY SMT DEF Even
<2> QED BY DEF Even, Odd, A
<1> QED BY <1>1, <1>2, <1>3

=============================================================================
