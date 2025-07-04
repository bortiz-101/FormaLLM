---------------------- MODULE MCCheckpointCoordination ----------------------
EXTENDS CheckpointCoordination, FiniteSets, Naturals, TLC

CONSTANTS MaxLog, MaxNat

MCNat == 0..MaxNat

MCLogIndex == 1..MaxLog

StateConstraint == OpenIndices /= {}

NodeSymmetry == Permutations(Node)

IncorrectlyOptimizedShouldReplaceLease(currentLease) ==
LET CC == INSTANCE CheckpointCoordination IN
\/ CC!ShouldReplaceLease(currentLease)

\/ currentLease.node = Leader

=============================================================================
