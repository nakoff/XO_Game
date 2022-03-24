local C = {};

C.Color = {
    WHITE={255,255,255},
    GRAY={0.5,0.5,0.5},
    RED={255,0,0},
    GREEN={0,255,0},
    BLUE={0,0,255},
};

function C:new()
    local o = {};

    setmetatable(o, self);
    self.__index = self;
    return o;
end

function C:setColor(color)
    love.graphics.setColor(color[1],color[2],color[3]);
end

function C:drawCell(x, y, size)
    love.graphics.rectangle("line", x, y, size, size);
end

function C:drawO(x, y, color)
    if (color) then self:setColor(color); end
    love.graphics.print("O", x, y);
    if (color) then self:setColor(self.Color.WHITE); end
end

function C:drawX(x, y, color)
    if (color) then self:setColor(color); end
    love.graphics.print("X", x, y);
    if (color) then self:setColor(self.Color.WHITE); end
end

function C:drawUsed(x, y, size)
    self:setColor(self.Color.GRAY);
    love.graphics.rectangle("fill", x, y, size, size);
    self:setColor(self.Color.WHITE);
end

function C:drawLine(x1, y1, x2, y2, color)
    if (color) then self:setColor(color); end
    love.graphics.line(x1, y1, x2, y2);
    if (color) then self:setColor(self.Color.WHITE); end
end

return C;