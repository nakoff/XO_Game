local DBManager = require ("core.dbManager");
local Cell = require ("models.cell.obj");

local M = {};
M.Status = { EMPTY=1, MARK_X=2, MARK_O=3, USED=4, }

function M.createCell(id, posX, posY)
    local cell = Cell:new(id, posX, posY);
    cell.status = M.Status.EMPTY;
    local err = DBManager.addObj(cell);
    return cell, err;
end

function M.getCell(id)
    return DBManager.getObj(DBManager.types.CELL, id);
end

function M.getCells()
    return DBManager.getAllObj(DBManager.types.CELL);
end

---@return Cell[]
---@return string
function M.getCellsByStatus(status)
    local objs, err = DBManager.getAllObj(DBManager.types.CELL);
    local filtered = {};
    if (err == nil) then
        for id, obj in pairs(objs) do
            if (obj.status == status) then
                table.insert(filtered, obj);
            end
        end
    end

    return filtered, err;
end

return M;