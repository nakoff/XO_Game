local C = {};

function C:new()
    local o = {};

    setmetatable(o, self);
    self.__index = self;
    return o;
end

function C:drawText(text, x, y, size)
    love.graphics.setColor(0, 1, 0, 1);
    local s = size or 1;
    love.graphics.print(text, x, y, 0, s, s);
    love.graphics.setColor(1, 1, 1, 1);
end

return C;