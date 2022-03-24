local DBManager = require ("core.dbManager");
local Obj = require ("models.settings.obj");

local M = {};
M.Status = {
    GAME_RUN="Game Run",
    GAME_FINISHED="Game Finished",
};

M.MapMode = {
    SMALL = "3 X 3",
    BIG = "5 X 5",
}

M.GameMode = {
    PVC = "Player vs Cpu",
    PVP = "Player vs Player",
    CVC = "Cpu vs Cpu",
}

M.StepBy = {
    PLAYER_1 = "Player1",
    PLAYER_2 = "Player2",
    CPU_1 = "Cpu1",
    CPU_2 = "Cpu2",
}

M.GameKey = {
    RESTART = 1,
    MODE_PVC = 2,
    MODE_PVP = 3,
    MODE_CVC = 4,
    MAP_CHANGE = 5,
    FIRST_STEP_CHANGE = 6,
}

function M.createSettings()
    local obj = Obj:new();
    local err = DBManager.addObj(obj);
    return obj, err;
end

function M.getSettings()
    return DBManager.getObj(DBManager.types.SETTINGS, 1);
end

return M;