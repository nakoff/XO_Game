local DBManager = require ("core.dbManager");
local object = require("core.object");

local C = {};

function C:new(id, x, y)
    local o = object:new(DBManager.types.CELL, id);
    o.status = 0;
    o.x = x;
    o.y = y;

    setmetatable(o, self);
    self.__index = self;
    return o;
end


return C;