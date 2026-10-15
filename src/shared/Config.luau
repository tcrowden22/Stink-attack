--!strict
-- Foundation free-play settings. Round settings are reserved for later milestones.
return table.freeze({
    MinimumPlayers = 2,
    VacuumFraction = 1 / 5,
    RespawnDelay = 3,
    Teams = table.freeze({
        StinkBugs = table.freeze({ Scale = 0.35, WalkSpeed = 13, JumpHeight = 2 }),
        Vacuums = table.freeze({ Scale = 1, WalkSpeed = 11, JumpHeight = 3 }),
    }),
    LobbySeconds = 15,
    RoundSeconds = 300,
})
