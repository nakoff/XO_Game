local UIViewer = require ("ui.viewer");
local SettingsModel = require ("models.settings.model");
local Conf = require ("conf");

local C = {};
local viewer;
local settings;

function C:new()
    local o = {};
    viewer = UIViewer:new();
    local err;
    settings, err = SettingsModel.createSettings();
    if (err) then print(err); end

    settings.mapMode = SettingsModel.MapMode.BIG;
    if (Conf.MapSize == 1) then
        settings.mapMode = SettingsModel.MapMode.SMALL;
    end

    settings.gameMode = SettingsModel.GameMode.CVC;
    if (Conf.GameMode == 1) then
        settings.gameMode = SettingsModel.GameMode.PVC;
    elseif (Conf.GameMode == 2) then
        settings.gameMode = SettingsModel.GameMode.PVP;
    end

    settings.stepBy = SettingsModel.StepBy.CPU_1;
    if (Conf.FirstStep == 1 and settings.gameMode ~= SettingsModel.GameMode.CVC) then
        settings.stepBy = SettingsModel.StepBy.PLAYER_1;
    end

    setmetatable(o, self);
    self.__index = self;
    return o;
end

function C:onDraw()
    local size = 1.5;
    viewer:drawText("Status: "..settings.status, 10*size, 10*size, size);

    viewer:drawText("Mode: "..settings.gameMode, 150*size, 10, size);
    viewer:drawText("Map size: "..settings.mapMode, 150*size, 25*size, size);

    viewer:drawText("Step By: "..settings.stepBy, 300*size, 10*size, size);
    viewer:drawText("Step Count: "..settings.step, 300*size, 25*size, size);

    local key = settings:getKey(SettingsModel.GameKey.MODE_PVC);
    viewer:drawText("Press "..string.upper(key).." to PvC mode", 360*size, 210*size, size);

    key = settings:getKey(SettingsModel.GameKey.MODE_PVP);
    viewer:drawText("Press "..string.upper(key).." to PvP mode", 360*size, 230*size, size);

    key = settings:getKey(SettingsModel.GameKey.MODE_CVC);
    viewer:drawText("Press "..string.upper(key).." to CvC mode", 360*size, 250*size, size);

    local key = settings:getKey(SettingsModel.GameKey.FIRST_STEP_CHANGE);
    viewer:drawText("Press "..string.upper(key).." to change first step", 360*size, 285*size, size);
    viewer:drawText("[ First Player = "..tostring(Conf.FirstStep==1).." ]", 360*size, 300*size, size);

    key = settings:getKey(SettingsModel.GameKey.MAP_CHANGE);
    viewer:drawText("Press "..string.upper(key).." to change map", 360*size, 330*size, size);

    key = settings:getKey(SettingsModel.GameKey.RESTART);
    viewer:drawText("Press "..string.upper(key).." to restart", 360*size, 380*size, size);
end

return C;