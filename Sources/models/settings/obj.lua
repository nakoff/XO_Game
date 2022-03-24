local DBManager = require ("core.dbManager");
local object = require("core.object");

local C = {};

function C:new()
    local o = object:new(DBManager.types.SETTINGS, 1);
    o.step = 0;
    o.status = "none";
    o.mapMode = "";
    o.gameMode = "";
    o.stepBy = "";

    o.keys = { }

    setmetatable(o, self);
    self.__index = self;
    return o;
end

function C:addKey(id, k)
    self.keys[id] = k;
end

function C:getKey(id)
    return self.keys[id];
end

function C:incStep()
    self.step = self.step + 1;
end

return C;