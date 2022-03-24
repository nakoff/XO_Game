local DBManager = require ("core.dbManager");
local GameController = require ("game.controller");
local UIController = require ("ui.controller");
local SettingsModel = require ("models.settings.model");
local Conf = require ("conf");

local gc;
local uc;
local settings;

local function restart()
    print(DBManager.init());
    uc = UIController:new();
    gc = GameController:new(100);

    settings = SettingsModel.getSettings();
    settings:addKey(SettingsModel.GameKey.FIRST_STEP_CHANGE, 'w');
    settings:addKey(SettingsModel.GameKey.MAP_CHANGE, 'q');
    settings:addKey(SettingsModel.GameKey.RESTART, 'r');
    settings:addKey(SettingsModel.GameKey.MODE_PVC, '1');
    settings:addKey(SettingsModel.GameKey.MODE_PVP, '2');
    settings:addKey(SettingsModel.GameKey.MODE_CVC, '3');
end

function love.load()
    restart();
end

function love.update(dt)
    gc:onUpdate(dt);
end

function love.draw()
    gc:onDraw();
    uc:onDraw();
end

function love.keypressed(key, scancode)
    for id, k in pairs(settings.keys) do
        if (key == k) then
            if (id == SettingsModel.GameKey.RESTART) then
            elseif (id == SettingsModel.GameKey.MAP_CHANGE) then
                if (Conf.MapSize == 1) then Conf.MapSize = 2 else Conf.MapSize = 1; end
            elseif (id == SettingsModel.GameKey.MODE_PVC) then
                Conf.GameMode = 1;
            elseif (id == SettingsModel.GameKey.MODE_PVP) then
                Conf.GameMode = 2;
            elseif (id == SettingsModel.GameKey.MODE_CVC) then
                Conf.GameMode = 3;
            elseif (id == SettingsModel.GameKey.FIRST_STEP_CHANGE) then
                if (Conf.FirstStep == 1) then Conf.FirstStep = 2; else Conf.FirstStep = 1; end
            end
            restart();
        end
    end
end

function love.mousereleased( x, y, button, istouch, presses )
    gc:onClick(x, y);
end
