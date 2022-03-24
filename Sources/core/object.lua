local Object = {};

function Object:new(type, id)
    local o = {};
    o.type = type;
    o.id = id;

    setmetatable(o, self);
    self.__index = self;
    return o;
end

return Object;