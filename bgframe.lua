function removeColumns(tableBuilder, dataIndex)
    if C_PvP.IsRatedBattleground() or C_PvP.IsRatedArena() or C_PvP.IsRatedSoloShuffle() or C_PvP.IsSoloShuffle() or C_PvP.IsRatedSoloRBG() then
        tremove(tableBuilder.columns);
        tremove(tableBuilder.columns);
    end
end
hooksecurefunc("ConstructPVPMatchTable", removeColumns)