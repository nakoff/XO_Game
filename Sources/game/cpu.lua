local CellModel = require ("models.cell.model");

local C = {};
local gc;

local Direction = { RL=9, UD=10, D1=11, D2=12, };

function C:new(gamecontroller)
    local o = {};
    gc = gamecontroller;

    setmetatable(o, self);
    self.__index = self;
    return o;
end

local function getTargetCell(cell0, cells)
    if (#cells < gc.cols - 2) then
        return;
    end

    local empty = CellModel.Status.EMPTY;
    local countCell0 = 0;
    local cellEmpty;
    for _, cell in ipairs(cells) do
        if (cell.status == cell0.status) then countCell0 = countCell0 + 1;
        elseif (cell.status == empty and cellEmpty == nil) then 
            cellEmpty = cell; 
        end
    end

    if (countCell0 >= gc.cols -2 and cellEmpty) then
        return cellEmpty;
    end
end

local function getHotCell(status)
    local cells = CellModel.getCellsByStatus(status);
    for _, cell in pairs(cells) do
        for _, dir in pairs(Direction) do
            local nearCells = gc:getNearCells(cell, dir);
            local tCell = getTargetCell(cell, nearCells);
            if (tCell) then
                return tCell;
            end
        end
    end
end

local function getEmptyCell()
    local statuses = {
        [1] = CellModel.Status.MARK_O,
        [2] = CellModel.Status.MARK_X,
    }

    for _, status in ipairs(statuses) do
        local objs = CellModel.getCellsByStatus(status);
        for _, cell in pairs(objs) do
            for _, dir in pairs(Direction) do
                local nearCells = gc:getNearCells(cell, dir);
                if (#nearCells >= gc.cols-1) then
                    local emptyCell;
                    for _, nCell in ipairs(nearCells) do
                        if (nCell.status == CellModel.Status.MARK_X) then
                            emptyCell = nil;
                            break;
                        end
                        if (not emptyCell and nCell.status == CellModel.Status.EMPTY) then
                            emptyCell = nCell;
                        end
                    end

                    if (emptyCell) then
                        return emptyCell;
                    end
                end
            end
        end
    end

    local cells = CellModel.getCellsByStatus(CellModel.Status.EMPTY);
    return cells[1];
end

function C:step(mark)
    local tCell = getHotCell(mark);

    if (tCell == nil) then
        local enemyMark = CellModel.Status.MARK_X;

        if (mark == enemyMark) then
            enemyMark = CellModel.Status.MARK_O;
        end

        tCell = getHotCell(enemyMark);
    end

    if (tCell == nil) then
        tCell = getEmptyCell();
    end

    if (tCell) then
        tCell.status = mark;
    end
    return tCell;
end

return C;