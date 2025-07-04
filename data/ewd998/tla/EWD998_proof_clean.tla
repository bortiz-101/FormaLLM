---------------------------- MODULE EWD998_proof ----------------------------

EXTENDS EWD998, FiniteSetTheorems, TLAPS

USE NAssumption

THEOREM TypeCorrect == Init /\ [][Next]_vars => []TypeOK
<1>. USE DEF TypeOK, Node, Color, Token
<1>1. Init => TypeOK
BY DEF Init
<1>2. TypeOK /\ [Next]_vars => TypeOK'
<2> SUFFICES ASSUME TypeOK,
[Next]_vars
PROVE  TypeOK'
OBVIOUS
<2>1. CASE InitiateProbe
BY <2>1 DEF InitiateProbe
<2>2. ASSUME NEW i \in Node \ {0},
PassToken(i)
PROVE  TypeOK'
BY <2>2 DEF PassToken
<2>3. ASSUME NEW i \in Node,
SendMsg(i)
PROVE  TypeOK'
BY <2>3 DEF SendMsg
<2>4. ASSUME NEW i \in Node,
RecvMsg(i)
PROVE  TypeOK'
BY <2>4 DEF RecvMsg
<2>5. ASSUME NEW i \in Node,
Deactivate(i)
PROVE  TypeOK'
BY <2>5 DEF Deactivate
<2>6. CASE UNCHANGED vars
BY <2>6 DEF vars
<2>7. QED
BY <2>1, <2>2, <2>3, <2>4, <2>5, <2>6 DEF Environment, Next, System
<1>. QED  BY <1>1, <1>2, PTL

IsAssociativeOn(op(_,_), S) ==
\A x,y,z \in S : op(x, op(y,z)) = op(op(x,y), z)

IsCommutativeOn(op(_,_), S) ==
\A x,y \in S : op(x,y) = op(y,x)

IsIdentityOn(op(_,_), e, S) ==
\A x \in S : op(e,x) = x

LEMMA FoldFunctionIsFoldFunctionOnSet ==
ASSUME NEW op(_,_), NEW base, NEW fun
PROVE  FoldFunction(op, base, fun) = FoldFunctionOnSet(op, base, fun, DOMAIN fun)

LEMMA FoldFunctionOnSetEmpty ==
ASSUME NEW op(_,_), NEW base, NEW fun
PROVE  FoldFunctionOnSet(op, base, fun, {}) = base

LEMMA FoldFunctionOnSetIterate ==
ASSUME NEW op(_,_),
NEW S, IsFiniteSet(S), NEW T,
NEW base \in T, NEW fun \in [S -> T],
NEW inds \in SUBSET S, NEW e \in inds,
IsAssociativeOn(op, T), IsCommutativeOn(op, T), IsIdentityOn(op, base, T)
PROVE  FoldFunctionOnSet(op, base, fun, inds)
= op(fun[e], FoldFunctionOnSet(op, base, fun, inds \ {e}))

LEMMA FoldFunctionOnSetUnion ==
ASSUME NEW op(_,_),
NEW S, IsFiniteSet(S), NEW T,
NEW base \in T, NEW fun \in [S -> T],
NEW inds1 \in SUBSET S, NEW inds2 \in SUBSET S, inds1 \cap inds2 = {},
IsAssociativeOn(op, T), IsCommutativeOn(op, T), IsIdentityOn(op, base, T)
PROVE  FoldFunctionOnSet(op, base, fun, inds1 \cup inds2)
= op(FoldFunctionOnSet(op, base, fun, inds1), FoldFunctionOnSet(op, base, fun, inds2))

LEMMA FoldFunctionOnSetEqual ==
ASSUME NEW op(_,_),
NEW S, IsFiniteSet(S), NEW T, NEW base \in T,
NEW f \in [S -> T], NEW g \in [S -> T],
NEW inds \in SUBSET S,
\A x \in inds : f[x] = g[x]
PROVE  FoldFunctionOnSet(op, base, f, inds) = FoldFunctionOnSet(op, base, g, inds)

LEMMA FoldFunctionOnSetType ==
ASSUME NEW op(_,_),
NEW S, NEW T, IsFiniteSet(S),
NEW base \in T, NEW fun \in [S -> T],
NEW inds \in SUBSET S,
\A x,y \in T : op(x,y) \in T
PROVE  FoldFunctionOnSet(op, base, fun, inds) \in T

LEMMA NodeIsFinite == IsFiniteSet(Node)
BY FS_Interval DEF Node

LEMMA PlusACI ==
/\ IsAssociativeOn(+, Nat)
/\ IsCommutativeOn(+, Nat)
/\ IsIdentityOn(+, 0, Nat)
/\ IsAssociativeOn(+, Int)
/\ IsCommutativeOn(+, Int)
/\ IsIdentityOn(+, 0, Int)
BY DEF IsAssociativeOn, IsCommutativeOn, IsIdentityOn

LEMMA SumEmpty ==
ASSUME NEW fun
PROVE  Sum(fun, {}) = 0
BY FoldFunctionOnSetEmpty DEF Sum

LEMMA SumIterate ==
ASSUME NEW fun \in [Node -> Int],
NEW inds \in SUBSET Node, NEW e \in inds
PROVE  Sum(fun, inds) = fun[e] + Sum(fun, inds \ {e})

LEMMA SumSingleton ==
ASSUME NEW fun \in [Node -> Int], NEW x \in Node
PROVE  Sum(fun, {x}) = fun[x]
BY SumIterate, SumEmpty, Isa

LEMMA SumUnion ==
ASSUME NEW fun \in [Node -> Int],
NEW inds1 \in SUBSET Node, NEW inds2 \in SUBSET Node, inds1 \cap inds2 = {}
PROVE  Sum(fun, inds1 \cup inds2) = Sum(fun, inds1) + Sum(fun, inds2)

LEMMA SumEqual ==
ASSUME NEW f \in [Node -> Int], NEW g \in [Node -> Int],
NEW inds \in SUBSET Node,
\A x \in inds : f[x] = g[x]
PROVE  Sum(f, inds) = Sum(g, inds)

LEMMA SumIsInt ==
ASSUME NEW fun \in [Node -> Int],
NEW inds \in SUBSET Node
PROVE  Sum(fun, inds) \in Int
BY FoldFunctionOnSetType, NodeIsFinite, Isa DEF Sum

LEMMA SumIsNat ==
ASSUME NEW fun \in [Node -> Nat],
NEW inds \in SUBSET Node
PROVE  Sum(fun, inds) \in Nat
BY FoldFunctionOnSetType, NodeIsFinite, Isa DEF Sum

LEMMA SumZero ==
ASSUME NEW fun \in [Node -> Int], NEW inds \in SUBSET Node,
\A i \in inds : fun[i] = 0
PROVE  Sum(fun, inds) = 0
<1>1. IsFiniteSet(inds)
BY NodeIsFinite, FS_Subset
<1>. DEFINE P(T) == T \subseteq inds => Sum(fun, T) = 0
<1>2. P({})
BY SumEmpty
<1>3. ASSUME NEW T, NEW x, IsFiniteSet(T), P(T), x \notin T
PROVE  P(T \cup {x})
BY <1>3, SumIterate
<1>4. P(inds)
<2>. HIDE DEF P
<2>. QED  BY <1>1, <1>2, <1>3, FS_Induction, IsaM("blast")
<1>. QED  BY <1>4

THEOREM Invariance == Init /\ [][Next]_vars => []Inv
<1>1. Init => Inv
BY DEF Init, B, Rng, Inv
<1>2. TypeOK /\ TypeOK' /\ Inv /\ [Next]_vars => Inv'
<2> SUFFICES ASSUME TypeOK, TypeOK',
Inv,
[Next]_vars
PROVE  Inv'
OBVIOUS
<2>1. CASE InitiateProbe
<3>1. B' = Sum(counter', Node)
BY <2>1 DEF InitiateProbe, Inv, B
<3>2. Rng(token.pos+1, N-1)' = {}
BY <2>1 DEF InitiateProbe, Node, Rng
<3>3. Inv!P1'
BY <2>1, <3>2, SumEmpty DEF InitiateProbe
<3>. QED  BY <3>1, <3>3 DEF Inv
<2>2. ASSUME NEW i \in Node \ {0},
PassToken(i)
PROVE  Inv'
<3>1. B' = Sum(counter, Node)'
BY <2>2 DEF PassToken, Inv, B
<3>2. Inv!2'
<4>1. ASSUME Inv!P1 PROVE Inv!P1'
<5>1. \A j \in Rng(token.pos+1, N-1)' : active'[j] = FALSE
BY <2>2, <4>1 DEF PassToken, TypeOK, Token, Node, Rng
<5>2. token'.pos # N-1
BY <2>2 DEF PassToken, TypeOK, Token, Node
<5>a. /\ Rng(token.pos+1, N-1) \in SUBSET Node
/\ Rng(token'.pos+1, N-1) \in SUBSET Node
BY DEF Rng
<5>b. /\ Sum(counter, Rng(token.pos+1, N-1)) \in Int
/\ Sum(counter, Rng(token.pos+1, N-1))' \in Int
BY <5>a, SumIsInt DEF TypeOK
<5>3. token.q = Sum(counter, Rng(token.pos+1, N-1))
<6>1. CASE token.pos = N-1
BY <4>1, <6>1, SumEmpty DEF Rng, Node
<6>2. CASE token.pos # N-1
BY <4>1, <6>2
<6>. QED  BY <6>1, <6>2
<5>c. token'.pos+1 \in Rng(token'.pos+1, N-1)
BY <5>2 DEF TypeOK, Token, Node, Rng
<5>4. Sum(counter, Rng(token.pos+1, N-1))'
= counter'[token'.pos+1] + Sum(counter', Rng(token'.pos+1, N-1) \ {token'.pos+1})
BY SumIterate, <5>2, <5>a, <5>c DEF TypeOK
<5>5. /\ Rng(token'.pos+1, N-1) \ {token'.pos+1} = Rng(token.pos+1, N-1)
/\ token'.pos+1 = token.pos
/\ counter' = counter
/\ token'.q = token.q + counter[token.pos]
BY <2>2 DEF PassToken, TypeOK, Token, Node, Rng
<5>6. Sum(counter, Rng(token.pos+1, N-1))'
= counter[token.pos] + Sum(counter, Rng(token.pos+1, N-1))
BY <5>4, <5>5, Zenon
<5>9. token'.q = Sum(counter, Rng(token.pos+1, N-1))'
BY <5>b, <5>3, <5>5, <5>6 DEF TypeOK, Token
<5>. QED  BY <5>1, <5>2, <5>9
<4>2. ASSUME Inv!P2 PROVE Inv!P2'
<5>1. /\ Rng(0, token.pos) \in SUBSET Node
/\ Rng(0, token.pos)' \in SUBSET Node
BY DEF Rng
<5>2. /\ Sum(counter, Rng(0, token.pos)) \in Int
/\ Sum(counter, Rng(0, token.pos))' \in Int
BY <5>1, SumIsInt DEF TypeOK
<5>3. Sum(counter, Rng(0, token.pos))
= counter[token.pos] + Sum(counter, Rng(0, token.pos) \ {token.pos})
BY SumIterate DEF TypeOK, Token, Node, Rng
<5>4. Rng(0, token.pos)' = Rng(0, token.pos) \ {token.pos}
BY <2>2 DEF PassToken, TypeOK, Token, Node, Rng
<5>5. /\ token'.q = token.q + counter[token.pos]
/\ counter' = counter
BY <2>2 DEF PassToken
<5>6. Sum(counter, Rng(0, token.pos))' + token'.q
= Sum(counter, Rng(0, token.pos)) + token.q
BY <5>1, <5>2, <5>3, <5>4, <5>5 DEF TypeOK, Token
<5>. QED  BY <4>2, <5>6
<4>3. ASSUME Inv!P3 PROVE Inv!P3' \/ Inv!P4'
<5>1. PICK j \in Rng(0, token.pos) : color[j] = "black"
BY <4>3
<5>2. CASE j = i
BY <2>2, <5>1, <5>2 DEF PassToken
<5>3. CASE j # i
<6>1. j \in Rng(0, token'.pos)
BY <2>2, <5>3 DEF PassToken, TypeOK, Token, Node, Rng
<6>2. color'[j] = color[j]
BY <2>2, <5>3 DEF PassToken
<6>. QED  BY <5>1, <6>1, <6>2
<5>. QED  BY <5>2, <5>3
<4>4. ASSUME Inv!P4 PROVE Inv!P4'
BY <2>2, <4>4 DEF PassToken
<4>. QED  BY <4>1, <4>2, <4>3, <4>4, Zenon DEF Inv
<3>. QED  BY <3>1, <3>2 DEF Inv
<2>3. ASSUME NEW i \in Node,
SendMsg(i)
PROVE  Inv'
<3>1. PICK j \in Node \ {i} :
/\ active[i]
/\ counter' = [counter EXCEPT ![i] = @+1]
/\ pending' = [pending EXCEPT ![j] = @+1]
/\ UNCHANGED <<active, color, token>>
BY <2>3, Zenon DEF SendMsg
<3>2. B' = Sum(counter, Node)'
<4>1. B' = B + 1
<5>1. /\ B = pending[j] + Sum(pending, Node \ {j})
/\ B' = pending'[j] + Sum(pending', Node \ {j})
BY SumIterate DEF B, TypeOK
<5>2. \A x \in Node \ {j} : pending'[x] = pending[x]
BY <3>1 DEF TypeOK
<5>3. Sum(pending', Node \ {j}) = Sum(pending, Node \ {j})
BY SumEqual, <5>2 DEF TypeOK
<5>. QED  BY SumIsNat, <5>1, <5>3, <3>1 DEF B, TypeOK
<4>2. Sum(counter, Node)' = Sum(counter, Node) + 1
<5>1. /\ Sum(counter, Node) = counter[i] + Sum(counter, Node \ {i})
/\ Sum(counter, Node)' = counter'[i] + Sum(counter', Node \ {i})
BY SumIterate DEF TypeOK
<5>2. \A x \in Node \ {i} : counter'[x] = counter[x]
BY <3>1 DEF TypeOK
<5>3. Sum(counter', Node \ {i}) = Sum(counter, Node \ {i})
BY SumEqual, <5>2 DEF TypeOK
<5>. QED  BY SumIsInt, <5>1, <5>3, <3>1 DEF TypeOK
<4>. QED  BY <4>1, <4>2 DEF Inv
<3>3. ASSUME Inv!P1 PROVE Inv!P1'
<4>1. /\ Rng(token.pos+1, N-1) \in SUBSET Node
/\ Rng(token.pos+1, N-1)' = Rng(token.pos+1, N-1)
BY <3>1 DEF Rng
<4>2. \A x \in Rng(token.pos+1, N-1) : counter'[x] = counter[x]
BY <3>1, <3>3 DEF TypeOK, Rng, Token, Node
<4>3. Sum(counter, Rng(token.pos+1, N-1))' = Sum(counter, Rng(token.pos+1, N-1))
BY SumEqual, <4>1, <4>2, SumEqual DEF TypeOK
<4>. QED  BY <3>1, <3>3, <4>1, <4>3
<3>4. ASSUME Inv!P2 PROVE Inv!P2'
<4>1. /\ Rng(0, token.pos) \in SUBSET Node
/\ Rng(0, token.pos)' = Rng(0, token.pos)
BY <3>1 DEF Rng
<4>2. CASE i \in Rng(0, token.pos)
<5>1. /\ Sum(counter, Rng(0, token.pos)) = counter[i] + Sum(counter, Rng(0, token.pos) \ {i})
/\ Sum(counter, Rng(0, token.pos))' = counter'[i] + Sum(counter', Rng(0, token.pos) \ {i})
BY <4>1, <4>2, SumIterate DEF TypeOK
<5>2. \A x \in Rng(0, token.pos) \ {i} : counter'[x] = counter[x]
BY <3>1, <4>1 DEF TypeOK
<5>3. Sum(counter', Rng(0, token.pos) \ {i}) = Sum(counter, Rng(0, token.pos) \ {i})
BY SumEqual, <4>1, <5>2 DEF TypeOK
<5>. QED  BY SumIsInt, <3>4, <4>1, <5>1, <5>3, <3>1 DEF TypeOK, Token
<4>3. CASE i \notin Rng(0, token.pos)
<5>1. \A x \in Rng(0, token.pos) : counter'[x] = counter[x]
BY <3>1, <4>3 DEF TypeOK, Rng
<5>2. Sum(counter, Rng(0, token.pos))' = Sum(counter, Rng(0, token.pos))
BY <4>1, <5>1, SumEqual DEF TypeOK
<5>. QED  BY <3>1, <3>4, <5>2
<4>. QED  BY <4>2, <4>3
<3>5. ASSUME Inv!P3 PROVE Inv!P3'
BY <2>3, <3>5 DEF SendMsg
<3>6. ASSUME Inv!P4 PROVE Inv!P4'
BY <2>3, <3>6 DEF SendMsg
<3>. QED  BY <3>2, <3>3, <3>4, <3>5, <3>6, Zenon DEF Inv
<2>4. ASSUME NEW i \in Node,
RecvMsg(i)
PROVE  Inv'
<3>1. B' = Sum(counter, Node)'
<4>1. B' = B - 1
<5>1. /\ B = pending[i] + Sum(pending, Node \ {i})
/\ B' = pending'[i] + Sum(pending', Node \ {i})
BY SumIterate DEF B, TypeOK
<5>2. \A x \in Node \ {i} : pending'[x] = pending[x]
BY <2>4 DEF TypeOK, RecvMsg
<5>3. Sum(pending', Node \ {i}) = Sum(pending, Node \ {i})
BY SumEqual, <5>2 DEF TypeOK
<5>. QED  BY SumIsNat, <5>1, <5>3, <2>4 DEF B, TypeOK, RecvMsg
<4>2. Sum(counter, Node)' = Sum(counter, Node) - 1
<5>1. /\ Sum(counter, Node) = counter[i] + Sum(counter, Node \ {i})
/\ Sum(counter, Node)' = counter'[i] + Sum(counter', Node \ {i})
BY SumIterate DEF TypeOK
<5>2. \A x \in Node \ {i} : counter'[x] = counter[x]
BY <2>4 DEF TypeOK, RecvMsg
<5>3. Sum(counter', Node \ {i}) = Sum(counter, Node \ {i})
BY SumEqual, <5>2 DEF TypeOK
<5>. QED  BY SumIsInt, <5>1, <5>3, <2>4 DEF TypeOK, RecvMsg
<4>. QED  BY <4>1, <4>2 DEF Inv
<3>2. Inv!2'
<4>0. i \in Rng(0, token.pos) \/ i \in Rng(token.pos+1, N-1)
BY DEF TypeOK, Token, Node, Rng
<4>1. CASE i \in Rng(0, token.pos)
BY <2>4, <4>1 DEF RecvMsg, TypeOK
<4>2. CASE i \in Rng(token.pos+1, N-1)
<5>0. /\ Rng(0, token.pos) \in SUBSET Node
/\ Rng(0, token.pos)' = Rng(0, token.pos)
/\ Rng(token.pos+1, N-1) \in SUBSET Node
/\ Rng(token.pos+1, N-1)' = Rng(token.pos+1, N-1)
BY <2>4 DEF RecvMsg, Rng
<5>1. ASSUME Inv!P1 PROVE Inv!P2
<6>1. B \in Nat \ {0}
<7>. B = pending[i] + Sum(pending, Node \ {i})
BY SumIterate DEF TypeOK, B
<7>. QED  BY <2>4, SumIsNat DEF RecvMsg, TypeOK
<6>2. CASE token.pos = N-1
<7>1. token.q = 0
BY <5>1, <6>2, SumEmpty DEF TypeOK, Token, Node, Rng
<7>2. Sum(counter, Rng(0, token.pos)) = B
<8>. Rng(0, token.pos) = Node
BY <6>2 DEF Rng, Node
<8> QED  BY DEF Inv
<7>. QED BY <6>1, <7>1, <7>2
<6>3. CASE token.pos # N-1
<7>1. token.q = Sum(counter, Rng(token.pos+1,N-1))
BY <5>1, <6>3
<7>2. Sum(counter, Rng(0, token.pos)) + Sum(counter, Rng(token.pos+1, N-1))
= Sum(counter, Node)
<8>. /\ Rng(0, token.pos) \union Rng(token.pos+1, N-1) = Node
/\ Rng(0, token.pos) \cap Rng(token.pos+1, N-1) = {}
BY DEF Rng, TypeOK, Token, Node
<8>. QED  BY SumUnion DEF TypeOK
<7>3. Sum(counter, Rng(0, token.pos)) + token.q = B
BY <7>1, <7>2 DEF Inv
<7>. QED  BY <6>1, <7>3
<6>. QED  BY <6>2, <6>3
<5>2. ASSUME Inv!P2 PROVE Inv!P2'
<6>1. \A x \in Rng(0, token.pos) : counter'[x] = counter[x]
BY <2>4, <4>2 DEF RecvMsg, TypeOK, Token, Node, Rng
<6>2. Sum(counter, Rng(0, token.pos))' = Sum(counter, Rng(0, token.pos))
BY SumEqual, <5>0, <6>1 DEF TypeOK
<6>. QED  BY <2>4, <5>0, <5>2, <6>2 DEF RecvMsg
<5>3. ASSUME Inv!P3 PROVE Inv!P3'
BY <2>4, <5>0, <5>3 DEF RecvMsg, TypeOK
<5>4. ASSUME Inv!P4 PROVE Inv!P4'
BY <2>4, <5>4 DEF RecvMsg
<5>. QED  BY <5>1, <5>2, <5>3, <5>4, Zenon DEF Inv
<4>. QED  BY <4>0, <4>1, <4>2, Zenon
<3>. QED  BY <3>1, <3>2 DEF Inv
<2>5. ASSUME NEW i \in Node,
Deactivate(i)
PROVE  Inv'
BY <2>5 DEF Deactivate, TypeOK, Token, Node, Range, Inv, B
<2>6. CASE UNCHANGED vars
BY <2>6 DEF vars, Inv, B
<2>7. QED
BY <2>1, <2>2, <2>3, <2>4, <2>5, <2>6 DEF Environment, Next, System
<1>. QED  BY <1>1, <1>2, TypeCorrect, PTL

THEOREM Safety ==
/\ TypeOK /\ Inv /\ terminationDetected => Termination
/\ TypeOK' /\ Inv' /\ terminationDetected' => Termination'
<1>1. TypeOK /\ Inv /\ terminationDetected => Termination
<2>. SUFFICES ASSUME TypeOK, Inv, terminationDetected
PROVE  Termination
OBVIOUS
<2>1. Inv!P1
<3>1. ~ Inv!P4
BY DEF terminationDetected
<3>2. ~ Inv!P3
BY DEF terminationDetected, Rng, Node
<3>3. ~ Inv!P2
<4>1. Sum(counter, Rng(0,0)) = counter[0] + Sum(counter, Rng(0,0) \ {0})
BY SumIterate DEF TypeOK, Rng, Node
<4>2. Sum(counter, Rng(0,0)) = counter[0]
BY <4>1, SumEmpty DEF TypeOK, Rng, Node
<4>. QED  BY <4>2 DEF terminationDetected, TypeOK, Token
<3>. QED  BY <3>1, <3>2, <3>3 DEF Inv
<2>2. \A i \in Node : active[i] = FALSE
BY <2>1 DEF TypeOK, Token, Node, Rng, terminationDetected
<2>3. Sum(counter, Node) = 0
<3>1. token.q = Sum(counter, Rng(1, N-1))
<4>1. CASE token.pos = N-1
<5>1. N = 1
BY <4>1 DEF terminationDetected
<5>2. Sum(counter, Rng(1, N-1)) = 0
BY <5>1, SumEmpty DEF Rng, Node
<5>3. Rng(token.pos+1, N-1) = {}
BY <4>1, NAssumption DEF TypeOK, Token, Rng, Node
<5>. QED  BY <2>1, <4>1, <5>2, <5>3, SumEmpty
<4>2. CASE token.pos # N-1
BY <2>1, <4>2 DEF terminationDetected
<4>. QED  BY <4>1, <4>2
<3>2. Sum(counter, Node) = counter[0] + Sum(counter, Rng(1, N-1))
BY SumIterate DEF TypeOK, Node, Rng
<3>. QED  BY <3>1, <3>2 DEF TypeOK, Token, terminationDetected
<2>. QED  BY <2>2, <2>3 DEF Inv, Termination
<1>2. TypeOK' /\ Inv' /\ terminationDetected' => Termination'
BY <1>1, PTL
<1>. QED  BY <1>1, <1>2

LEMMA B0NoMessagePending ==
/\ TypeOK /\ B=0 => \A i \in Node : pending[i] = 0
/\ TypeOK' /\ B'=0 => \A i \in Node : pending'[i] = 0
<1>1. TypeOK /\ B=0 => \A i \in Node : pending[i] = 0
<2>. SUFFICES ASSUME TypeOK, B = 0, NEW i \in Node, pending[i] # 0
PROVE  FALSE
OBVIOUS
<2>. B = pending[i] + Sum(pending, Node \ {i})
BY SumIterate DEF TypeOK, B
<2>. QED  BY SumIsNat DEF TypeOK
<1>2. (TypeOK /\ B=0 => \A i \in Node : pending[i] = 0)'
BY <1>1, PTL
<1>. QED  BY <1>1, <1>2

-----------------------------------------------------------------------------

LEMMA EnabledSystem ==
ASSUME TypeOK, N > 1 \/ counter[0]=0
PROVE  ENABLED <<System>>_vars
<=> \/ /\ token.pos = 0
/\ token.color = "black" \/ color[0] = "black" \/ counter[0]+token.q > 0
\/ \E i \in Node \ {0} : ~ active[i] /\ token.pos = i
<1>1. <<System>>_vars <=> System
<2>1. InitiateProbe => <<InitiateProbe>>_vars
BY DEF InitiateProbe, TypeOK, Token, vars, Node
<2>2. \A i \in Node \ {0} : PassToken(i) => <<PassToken(i)>>_vars
BY DEF PassToken, TypeOK, Token, vars, Node
<2>. QED  BY <2>1, <2>2 DEF System
<1>2. (ENABLED <<System>>_vars) <=> (ENABLED System)
BY <1>1, ENABLEDrules
<1>3. ENABLED UNCHANGED <<active, counter, pending>>
BY ExpandENABLED
<1>. QED  BY <1>2, <1>3, ENABLEDrewrites DEF System, InitiateProbe, PassToken

COROLLARY EnabledAtMaster ==
ASSUME TypeOK, Inv, Termination, token.pos = 0, ~ terminationDetected
PROVE  ENABLED <<System>>_vars
<1>. USE DEF Termination, TypeOK, B, Node, Token
<1>1. N=1 => counter[0] = 0
BY SumSingleton, N=1 => 0 .. N-1 = {0}, Isa DEF Inv
<1>2. /\ token.pos = 0
/\ token.color = "black" \/ color[0] = "black" \/ counter[0]+token.q > 0
<2>1. CASE Inv!P1
<3>1. Sum(counter, Node) = counter[0] + Sum(counter, Rng(token.pos+1, N-1))
BY SumIterate DEF Rng
<3>2. counter[0] + token.q = 0
BY <2>1, <3>1 DEF Inv
<3>. QED  BY <3>2, B0NoMessagePending DEF terminationDetected, Color
<2>2. CASE Inv!P2
BY <2>2, SumSingleton DEF Rng
<2>3. CASE Inv!P3
BY <2>3 DEF Rng
<2>4. CASE Inv!P4
BY <2>4
<2>. QED  BY <2>1, <2>2, <2>3, <2>4, Zenon DEF Inv
<1>. QED  BY <1>1, <1>2, EnabledSystem

BSpec ==
/\ []TypeOK
/\ []Inv
/\ [][Next]_vars
/\ []~terminationDetected
/\ WF_vars(System)

atMaster == token.pos = 0
tknWhite == token.color = "white"
tknCount == token.q = Sum(counter, Rng(1,N-1))
allWhite == \A i \in Node : color[i] = "white"

LEMMA Round1 == BSpec => (Termination
~> Termination /\ atMaster)
<1>. DEFINE P(n) == Termination /\ n \in Node /\ token.pos = n
Q == P(0)
R(n) == BSpec => [](P(n) => <>Q)
<1>1. \A n \in Nat : R(n)
<2>1. R(0)
BY PTL
<2>2. ASSUME NEW n \in Nat
PROVE  R(n) => R(n+1)
<3>. DEFINE Pn == P(n)  Pn1 == P(n+1)
<3>. USE DEF TypeOK, Termination, Node, Token, B
<3>1. TypeOK /\ Pn1 /\ [Next]_vars => Pn1' \/ Pn'
BY B0NoMessagePending
DEF Next, vars, System, Environment, InitiateProbe, PassToken, Deactivate, SendMsg, RecvMsg
<3>2. TypeOK /\ Pn1 /\ <<System>>_vars => Pn'
BY DEF System, InitiateProbe, PassToken, vars
<3>3. TypeOK /\ Pn1 => ENABLED <<System>>_vars
BY EnabledSystem
<3>. HIDE DEF Pn1
<3>4. R(n) => (BSpec => [](Pn1 => <>Q))
BY <3>1, <3>2, <3>3, PTL DEF BSpec
<3>. QED  BY <3>4 DEF Pn1
<2>. HIDE DEF R
<2>. QED  BY <2>1, <2>2, NatInduction, Isa
<1>2. BSpec => []((\E n \in Nat : P(n)) => <>Q)
<2>. HIDE DEF P, Q
<2>1. BSpec => [](\A n \in Nat : P(n) => <>Q)
BY <1>1
<2>2. (\A n \in Nat : P(n) => <>Q) <=> ((\E n \in Nat : P(n)) => <>Q)
OBVIOUS
<2>. QED  BY <2>1, <2>2, PTL
<1>3. TypeOK => (Termination => \E n \in Nat : P(n))
BY DEF Termination, TypeOK, Node, Token
<1>. QED  BY <1>2, <1>3, PTL DEF BSpec, atMaster

LEMMA Round2 == BSpec => (Termination /\ atMaster
~> Termination /\ atMaster /\ allWhite)
<1>. DEFINE P(n) == /\ Termination /\ n \in Node /\ token.pos = n
/\ color[0] = "white"
/\ \A i \in n+1 .. N-1 : color[i] = "white"
Q == P(0)
R(n) == BSpec => [](P(n) => <>Q)
<1>1. BSpec => (Termination /\ atMaster ~> \E n \in Nat : P(n))
<2>. DEFINE S == Termination /\ atMaster
T == P(N-1)
<2>. USE DEF TypeOK, Termination, Node, Token, B, atMaster
<2>1. TypeOK /\ S /\ [Next]_vars => S' \/ T'
BY B0NoMessagePending
DEF Next, vars, System, Environment, InitiateProbe, PassToken, Deactivate, SendMsg, RecvMsg
<2>2. TypeOK /\ S /\ <<System>>_vars => T'
BY DEF System, InitiateProbe, PassToken, vars
<2>3. TypeOK /\ Inv /\ ~terminationDetected /\ S => ENABLED <<System>>_vars
BY EnabledAtMaster
<2>4. T => \E n \in Nat : P(n)
OBVIOUS
<2>. HIDE DEF T
<2>5. QED  BY <2>1, <2>2, <2>3, <2>4, PTL DEF BSpec
<1>2. \A n \in Nat : R(n)
<2>1. R(0)
BY PTL
<2>2. ASSUME NEW n \in Nat
PROVE  R(n) => R(n+1)
<3>. DEFINE Pn == P(n)  Pn1 == P(n+1)
<3>. USE DEF TypeOK, Termination, Node, Token, B
<3>1. TypeOK /\ Pn1 /\ [Next]_vars => Pn1' \/ Pn'
BY B0NoMessagePending
DEF Next, vars, System, Environment, InitiateProbe, PassToken, Deactivate, SendMsg, RecvMsg
<3>2. TypeOK /\ Pn1 /\ <<System>>_vars => Pn'
BY DEF System, InitiateProbe, PassToken, vars
<3>3. TypeOK /\ Pn1 => ENABLED <<System>>_vars
BY EnabledSystem
<3>. HIDE DEF Pn1
<3>4. R(n) => (BSpec => [](Pn1 => <>Q))
BY <3>1, <3>2, <3>3, PTL DEF BSpec
<3>. QED  BY <3>4 DEF Pn1
<2>. HIDE DEF R
<2>. QED  BY <2>1, <2>2, NatInduction, Isa
<1>3. BSpec => []((\E n \in Nat : P(n)) => <>Q)
<2>. HIDE DEF P, Q
<2>1. BSpec => [](\A n \in Nat : P(n) => <>Q)
BY <1>2
<2>2. (\A n \in Nat : P(n) => <>Q) <=> ((\E n \in Nat : P(n)) => <>Q)
OBVIOUS
<2>. QED  BY <2>1, <2>2, PTL
<1>4. Q => Termination /\ atMaster /\ allWhite
BY DEF atMaster, allWhite, Node
<1>. QED  BY <1>1, <1>3, <1>4, PTL

LEMMA Round3 == BSpec => (Termination /\ atMaster /\ allWhite
~> Termination /\ atMaster /\ allWhite /\ tknWhite /\ tknCount)
<1>. DEFINE P(n) == /\ Termination /\ n \in Node /\ token.pos = n
/\ allWhite /\ tknWhite
/\ token.q = Sum(counter, Rng(n+1, N-1))
Q == P(0)
R(n) == BSpec => [](P(n) => <>Q)
<1>1. BSpec => (Termination /\ atMaster /\ allWhite ~> \E n \in Nat : P(n))
<2>. DEFINE S == Termination /\ atMaster /\ allWhite
T == P(N-1)
<2>. USE DEF TypeOK, Termination, Node, Token, B, atMaster, allWhite, tknWhite
<2>0. TypeOK /\ S /\ System => T'
<3> SUFFICES ASSUME TypeOK, S, System
PROVE  T'
OBVIOUS
<3>1. CASE InitiateProbe
<4>. Rng(N, N-1) = {}
BY DEF Rng
<4>. QED  BY <3>1, SumEmpty DEF InitiateProbe
<3>2. ASSUME NEW i \in Node \ {0},
PassToken(i)
PROVE  T'
BY <3>2 DEF PassToken
<3>3. QED
BY <3>1, <3>2 DEF System
<2>1. TypeOK /\ S /\ [Next]_vars => S' \/ T'
BY <2>0, B0NoMessagePending
DEF Next, vars, Environment, Deactivate, SendMsg, RecvMsg
<2>3. TypeOK /\ Inv /\ ~terminationDetected /\ S => ENABLED <<System>>_vars
BY EnabledAtMaster
<2>4. T => \E n \in Nat : P(n)
OBVIOUS
<2>. HIDE DEF T
<2>5. QED  BY <2>0, <2>1, <2>3, <2>4, PTL DEF BSpec
<1>2. \A n \in Nat : R(n)
<2>1. R(0)
BY PTL
<2>2. ASSUME NEW n \in Nat
PROVE  R(n) => R(n+1)
<3>. DEFINE Pn == P(n)  Pn1 == P(n+1)
<3>. USE DEF TypeOK, Termination, Node, Token, B, allWhite, tknWhite
<3>0. TypeOK /\ Pn1 /\ System => Pn'
<4>1. ASSUME TypeOK, Pn1, InitiateProbe
PROVE  Pn'
BY <4>1, SumEmpty DEF InitiateProbe, Rng
<4>2. ASSUME TypeOK, Pn1, NEW i \in Node \ {0}, PassToken(i)
PROVE  Pn'
<5>. Sum(counter, Rng(i, N-1)) = counter[i] + Sum(counter, Rng(i+1, N-1))
BY <4>2, SumIterate DEF Rng
<5>. QED  BY <4>2 DEF PassToken
<4>. QED  BY <4>1, <4>2 DEF System
<3>1. TypeOK /\ Pn1 /\ [Next]_vars => Pn1' \/ Pn'
BY <3>0, B0NoMessagePending DEF Next, vars, Environment, SendMsg, RecvMsg, Deactivate
<3>3. TypeOK /\ Pn1 => ENABLED <<System>>_vars
BY EnabledSystem
<3>. HIDE DEF Pn1
<3>4. R(n) => (BSpec => [](Pn1 => <>Q))
BY <3>0, <3>1, <3>3, PTL DEF BSpec
<3>. QED  BY <3>4 DEF Pn1
<2>. HIDE DEF R
<2>. QED  BY <2>1, <2>2, NatInduction, Isa
<1>3. BSpec => []((\E n \in Nat : P(n)) => <>Q)
<2>. HIDE DEF P, Q
<2>1. BSpec => [](\A n \in Nat : P(n) => <>Q)
BY <1>2
<2>2. (\A n \in Nat : P(n) => <>Q) <=> ((\E n \in Nat : P(n)) => <>Q)
OBVIOUS
<2>. QED  BY <2>1, <2>2, PTL
<1>4. Q => Termination /\ atMaster /\ allWhite /\ tknWhite /\ tknCount
BY DEF atMaster, allWhite, tknCount, Node
<1>. QED  BY <1>1, <1>3, <1>4, PTL

LEMMA Detection ==
TypeOK /\ Inv /\ Termination /\ atMaster /\ allWhite /\ tknWhite /\ tknCount
=> terminationDetected
<1>. SUFFICES ASSUME TypeOK, Inv, Termination, atMaster, allWhite, tknWhite, tknCount
PROVE  terminationDetected
OBVIOUS
<1>1. /\ token.pos = 0
/\ token.color = "white"
/\ color[0] = "white"
/\ ~ active[0]
/\ pending[0] = 0
BY B0NoMessagePending DEF Termination, atMaster, allWhite, tknWhite, Node
<1>2. token.q + counter[0] = 0
<2>1. Sum(counter, Node) = counter[0] + Sum(counter, Rng(1,N-1))
BY SumIterate DEF Node, TypeOK, Rng
<2>2. Sum(counter, Node) = token.q + counter[0]
BY <2>1 DEF tknCount, TypeOK, Token, Node
<2>3. Sum(counter, Node) = 0
BY DEF Termination, Inv
<2>. QED  BY <2>2, <2>3
<1>. QED  BY <1>1, <1>2 DEF terminationDetected

THEOREM Live == []TypeOK /\ []Inv /\ [][Next]_vars /\ WF_vars(System) => Liveness
BY Round1, Round2, Round3, Detection, PTL DEF BSpec, Liveness

COROLLARY SpecLive == Spec => Liveness
BY TypeCorrect, Invariance, Live, PTL DEF Spec

-----------------------------------------------------------------------------

LEMMA NodeIsNode == TD!Node = Node
BY DEF Node, TD!Node

THEOREM Refinement == Spec => TD!Spec
<1>. USE NodeIsNode
<1>1. Init => TD!Init
BY Zenon DEF Init, TD!Init, terminationDetected
<1>2. TypeOK /\ TypeOK' /\ Inv /\ Inv' /\ [Next]_vars => [TD!Next]_(TD!vars)
<2> SUFFICES ASSUME TypeOK, TypeOK', Inv, Inv',
[Next]_vars
PROVE  [TD!Next]_(TD!vars)
OBVIOUS
<2>1. CASE InitiateProbe
<3>1. terminationDetected = FALSE
BY <2>1 DEF InitiateProbe, TypeOK, Token, Node, terminationDetected
<3>2. UNCHANGED <<active, pending>>
BY <2>1 DEF InitiateProbe
<3>3. CASE terminationDetected' = FALSE
BY <3>1, <3>2, <3>3, Zenon DEF TD!vars

<3>4. CASE terminationDetected' = TRUE
<4>1. /\ token'.pos = 0
/\ ~ active[0]
/\ pending[0] = 0
BY <3>2, <3>4 DEF terminationDetected
<4>2. N = 1
BY <2>1, <4>1 DEF InitiateProbe, TypeOK, Token, Node
<4>3. TD!terminated
BY <4>1, <4>2 DEF Node, TD!terminated
<4>. QED  BY <3>2, <3>4, <4>3 DEF TD!Next, TD!DetectTermination
<3>. QED  BY <3>3, <3>4 DEF terminationDetected
<2>2. ASSUME NEW i \in Node \ {0},
PassToken(i)
PROVE  [TD!Next]_(TD!vars)
<3>1. terminationDetected = FALSE
BY <2>2 DEF PassToken, TypeOK, Token, Node, terminationDetected
<3>2. UNCHANGED <<active, pending>>
BY <2>2 DEF PassToken
<3>3. CASE terminationDetected' = FALSE
BY <3>1, <3>2, <3>3, Zenon DEF TD!vars
<3>4. CASE terminationDetected' = TRUE
<4>. TD!terminated'
BY <3>4, Safety, B0NoMessagePending DEF Termination, TD!terminated
<4>. QED  BY <3>2, <3>4 DEF TD!Next, TD!DetectTermination, TD!terminated
<3>. QED  BY <3>3, <3>4 DEF terminationDetected
<2>3. ASSUME NEW i \in Node,
SendMsg(i)
PROVE  [TD!Next]_(TD!vars)
<3>1. PICK j \in Node :
/\ active[i]
/\ counter' = [counter EXCEPT ![i] = @ + 1]
/\ pending' = [pending EXCEPT ![j] = @ + 1]
/\ UNCHANGED <<active, color, token>>
BY <2>3, Zenon DEF SendMsg
<3>2. /\ terminationDetected = FALSE
/\ terminationDetected' = FALSE
BY <3>1, Safety DEF Termination
<3>. QED  BY <3>1, <3>2, Zenon DEF TD!Next, TD!SendMsg
<2>4. ASSUME NEW i \in Node,
RecvMsg(i)
PROVE  [TD!Next]_(TD!vars)
<3>. /\ terminationDetected = FALSE
/\ terminationDetected' = FALSE
BY <2>4, Safety, B0NoMessagePending DEF RecvMsg, terminationDetected, Termination, TypeOK
<3>. QED  BY <2>4, Zenon DEF RecvMsg, TD!Next, TD!RcvMsg
<2>5. ASSUME NEW i \in Node,
Deactivate(i)
PROVE  [TD!Next]_(TD!vars)
<3>1. terminationDetected = FALSE
BY <2>5, Safety DEF Termination, Deactivate
<3>2. CASE terminationDetected' = FALSE
BY <2>5, <3>1, <3>2, Zenon DEF Deactivate, TD!Terminate, TD!Next
<3>3. CASE terminationDetected' = TRUE
BY <2>5, <3>3, Safety, B0NoMessagePending, Zenon
DEF Deactivate, Termination, TD!terminated, TD!Terminate, TD!Next, TypeOK
<3>. QED  BY <3>2, <3>3 DEF terminationDetected
<2>6. CASE UNCHANGED vars
BY <2>6 DEF vars, terminationDetected, TD!vars
<2>7. QED
BY <2>1, <2>2, <2>3, <2>4, <2>5, <2>6 DEF Environment, Next, System
<1>4. []TypeOK /\ []Inv /\ [][Next]_vars /\ WF_vars(System)
=> WF_(TD!vars)(TD!DetectTermination)
<2>1. SUFFICES /\ []TypeOK /\ []Inv /\ [][Next]_vars /\ WF_vars(System)
/\ []ENABLED <<TD!DetectTermination>>_(TD!vars)
=> FALSE
BY PTL
<2>2. TypeOK /\ ENABLED <<TD!DetectTermination>>_(TD!vars)
=> Termination /\ ~ terminationDetected
<3>. SUFFICES ASSUME TypeOK, ENABLED <<TD!DetectTermination>>_(TD!vars)
PROVE  Termination /\ ~ terminationDetected
OBVIOUS
<3>1. TD!terminated /\ ~ terminationDetected
BY ExpandENABLED DEF TD!DetectTermination, TD!vars, terminationDetected
<3>2. \A n \in Node : ~ active[n] /\ pending[n] = 0
BY <3>1 DEF TD!terminated
<3>3. B = 0
BY <3>2, SumZero DEF TypeOK, B
<3>. QED  BY <3>1, <3>2, <3>3 DEF Termination
<2>. QED  BY <2>2, Live, TypeCorrect, Invariance, PTL DEF Liveness
<1>. QED  BY <1>1, <1>2, <1>4, TypeCorrect, Invariance, PTL DEF Spec, TD!Spec

=============================================================================
