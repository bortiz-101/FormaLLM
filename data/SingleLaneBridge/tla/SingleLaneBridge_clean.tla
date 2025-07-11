-------------------------- MODULE SingleLaneBridge --------------------------

EXTENDS Naturals, FiniteSets, Sequences

CONSTANTS CarsRight, CarsLeft, Bridge, Positions

VARIABLES Location, WaitingBeforeBridge
vars == <<Location, WaitingBeforeBridge>>

StartPos == CHOOSE min \in Positions : \A p \in Positions : min <= p
EndPos   == CHOOSE max \in Positions : \A p \in Positions : max >= p

StartBridge == CHOOSE min \in Bridge : \A e \in Bridge : min <= e
EndBridge   == CHOOSE max \in Bridge : \A e \in Bridge : max >= e

ASSUME CarsRight \cap CarsLeft = {}
ASSUME Cardinality(CarsRight \union CarsLeft ) # 0
ASSUME StartPos < StartBridge /\ EndPos > EndBridge /\ Cardinality(Bridge) < Cardinality(Positions)

RECURSIVE SeqFromSet(_)
SeqFromSet(S) ==
IF S = {} THEN << >>
ELSE LET x == CHOOSE x \in S : TRUE
IN  << x >> \o SeqFromSet(S \ {x})

Cars == CarsRight \union CarsLeft
CarsInBridge == { c \in Cars : Location[c] \in Bridge }
CarsBeforeBridge == { car \in CarsRight : EndPos - EndBridge = 1 } \cup { car \in CarsLeft : StartBridge - StartPos = 1 }

RMove(pos) == IF pos > StartPos THEN pos - 1 ELSE EndPos
LMove(pos) == IF pos < EndPos THEN pos + 1 ELSE StartPos

NextLocation(car) == IF car \in CarsRight THEN RMove(Location[car]) ELSE LMove(Location[car])

ChangeLocation(car) ==
/\ IF \/ car \in CarsRight /\ NextLocation(car) = EndBridge + 1
\/ car \in CarsLeft /\ NextLocation(car) = StartBridge - 1
THEN WaitingBeforeBridge' = Append(WaitingBeforeBridge, car)
ELSE UNCHANGED WaitingBeforeBridge
/\ Location' = [ Location EXCEPT ![car] = NextLocation(car) ]

HaveSameDirection(car) ==
\/ car \in CarsRight /\ \A c \in CarsInBridge : c \in CarsRight
\/ car \in CarsLeft /\ \A c \in CarsInBridge : c \in CarsLeft

MoveOutsideBridge(car) ==
/\ NextLocation(car) \notin Bridge
/\ ChangeLocation(car)

MoveInsideBridge(car) ==
/\ car \in CarsInBridge
/\ \A c \in Cars : Location[c] # NextLocation(car)
/\ ChangeLocation(car)

EnterBridge ==
\/  /\ CarsInBridge = {}
/\ Len(WaitingBeforeBridge) # 0
/\ Location' = [ Location EXCEPT ![Head(WaitingBeforeBridge)] = NextLocation(Head(WaitingBeforeBridge)) ]
/\ WaitingBeforeBridge' = Tail(WaitingBeforeBridge)
\/  /\ Len(WaitingBeforeBridge) # 0
/\ Head(WaitingBeforeBridge) \notin CarsInBridge
/\ HaveSameDirection(Head(WaitingBeforeBridge))
/\ \A c \in Cars : Location[c] # NextLocation(Head(WaitingBeforeBridge))
/\ Location' = [ Location EXCEPT ![Head(WaitingBeforeBridge)] = NextLocation(Head(WaitingBeforeBridge)) ]
/\ WaitingBeforeBridge' = Tail(WaitingBeforeBridge)

Init ==
/\ Location = [ c \in Cars |-> IF c \in CarsRight THEN EndPos ELSE StartPos  ]
/\ WaitingBeforeBridge = SeqFromSet(CarsBeforeBridge)

Next == \E car \in Cars : EnterBridge \/ MoveOutsideBridge(car) \/ MoveInsideBridge(car)

Fairness ==
/\ \A car \in Cars : WF_vars(MoveOutsideBridge(car))
/\ \A car \in Cars : WF_vars(MoveInsideBridge(car))
/\ \A car \in Cars : WF_vars(EnterBridge)

Spec == Init /\ [][Next]_vars /\ Fairness

Invariants ==

/\ \A a,b \in Cars :
/\ Location[a] \in Bridge
/\ Location[a] = Location[b]
=> a = b

/\ Cardinality(CarsInBridge) < Cardinality(Bridge) + 1

/\ \A <<r,l>> \in CarsRight \X CarsLeft :
~ (Location[r] \in Bridge /\ Location[l] \in Bridge)

TypeOK ==
/\ Location \in [ Cars -> Positions ]
/\ Len(WaitingBeforeBridge) <= Cardinality(Cars)

CarsInBridgeExitBridge ==

\A car \in Cars : Location[car] \in Bridge ~> Location[car] \notin Bridge

CarsEnterBridge ==

\A car \in Cars : Location[car] \notin Bridge ~> Location[car] \in Bridge

THEOREM Spec => [] Invariants

THEOREM Spec => [] TypeOK

THEOREM Spec => CarsInBridgeExitBridge
THEOREM Spec => CarsEnterBridge

=============================================================================
