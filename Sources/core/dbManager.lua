local M = {};

M.types = { CELL=1, SETTINGS=2};
local db = {};

function M.init()
    for k,v in pairs(M.types) do
        db[v] = {};
    end

    return "DBManager initialized";
end

function M.addObj(obj)
    if (obj.type == nil or obj.id == nil) then
        return "ERR: wrong obj";
    end

    if (M.getObj(obj.type, obj.id)) then
        return "ERR: obj "..obj.type..", id "..obj.id.." already is exists";
    end

    db[obj.type][obj.id] = obj;
end

---@param objType number
---@param objId number
---@return table
---@return string
function M.getObj(objType, objId)
    local obj;
    local objs, err = M.getAllObj(objType);

    if (err == nil) then
        obj = objs[objId];
        if (obj == nil) then
            err = "ERR: obj "..objType..", id "..objId.." not found";
        end
    end

    return obj, err;
end

---@param objType any
---@return Object[]
---@return string
function M.getAllObj(objType)
    local err;
    local obj = db[objType];
    if (obj == nil) then
        err = "ERR: obj "..objType.." not found";
    end

    return db[objType], err;
end

return M;