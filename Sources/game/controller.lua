local CellModel = require ("models.cell.model");
local GameViewer = require ("game.viewer");
local CpuAI = require ("game.cpu");
local SettingsModel = require ("models.settings.model")

local C = {};
local cpuAI;
local settings;
local cols;
local rows;
local size;
local isCpuStep = false;

C.Direction = { RL=9, UD=10, D1=11, D2=12, };

local usedCells = { }

local function createMap()
    local offsetX, offsetY = 10,100;
    local idx = 0;
    for y = 1, rows do
        for x = 1, cols do
            idx = idx + 1;
            local posX = offsetX + x*size - size/2;
            local posY = offsetY + y*size - size/2;
            local _, err = CellModel.createCell(idx, posX, posY);
            if (err) then
                return err;
            end
        end
    end
end

function C:new(cellSize)
    cols, rows, size = 3, 3, cellSize;

    local o = {};
    local err;
    cpuAI = CpuAI:new(o);

    settings, err = SettingsModel.getSettings();
    if (err) then print(err); end

    settings.status = SettingsModel.Status.GAME_RUN;
    if (settings.mapMode == SettingsModel.MapMode.BIG) then
        cols, rows = 5, 5;
    end
    local cpu1 = SettingsModel.StepBy.CPU_1;
    local cpu2 = SettingsModel.StepBy.CPU_2;
    isCpuStep = settings.stepBy == cpu1 or settings.stepBy == cpu2;

    o.viewer = GameViewer:new();
    o.cols = cols;
    o.rows = rows;
    o.cellSize = cellSize;

    err = createMap();
    if (err) then print(err); end

    usedCells[CellModel.Status.MARK_O] = {}
    usedCells[CellModel.Status.MARK_X] = {}

    setmetatable(o, self);
    self.__index = self;
    return o;
end

function C:getCellByPos(x, y)
    local half = self.cellSize / 2;
    local cells = CellModel.getCells();
    for _, cell in pairs(cells) do
        if (x > cell.x - half and x < cell.x + half) then
            if (y > cell.y - half and y < cell.y + half) then
                return cell;
            end
        end
    end
end

local function stepFinished()
    local emptyCells = CellModel.getCellsByStatus(CellModel.Status.EMPTY);
    if (#emptyCells == 0) then
        settings.status = SettingsModel.Status.GAME_FINISHED;
    end

    if (settings.status == SettingsModel.Status.GAME_FINISHED) then
        isCpuStep = false;
        return;
    end

    local p1 = SettingsModel.StepBy.PLAYER_1;
    local p2 = SettingsModel.StepBy.PLAYER_2;
    local c1 = SettingsModel.StepBy.CPU_1;
    local c2 = SettingsModel.StepBy.CPU_2;
    local cur = settings.stepBy;

    if (settings.gameMode == SettingsModel.GameMode.PVC) then
        if (cur == p1) then cur = c1;
        else cur = p1; end
    elseif (settings.gameMode == SettingsModel.GameMode.PVP) then
        if (cur == p1) then cur = p2;
        else cur = p1; end
    elseif (settings.gameMode == SettingsModel.GameMode.CVC) then
        if (cur == c1) then cur = c2;
        else cur = c1; end
    end
    settings.stepBy = cur;
    isCpuStep = cur == c1 or cur == c2;
end

local function getId_R(curId)
    if (curId%cols > 0) then return curId + 1; end
end

local function getId_L(curId)
    if ((curId-1)%cols > 0) then return curId - 1; end
end

local function getId_U(curId)
    if (curId > cols) then return curId - cols; end
end

local function getId_D(curId)
    local id = curId + cols;
    if (id <= cols * rows) then return id end;
end

local function getId_RU(curId)
    if (curId%cols > 0 and curId > cols) then return curId - cols + 1; end
end

local function getId_RD(curId)
    if (curId%cols > 0) then
        local id = curId + cols + 1;
        if (id <= cols * rows) then return id; end
    end
end

local function getId_LU(curId)
    if ((curId-1)%cols > 0 and curId > cols) then return curId - cols - 1; end
end

local function getId_LD(curId)
    if ((curId-1)%cols > 0) then
        local id = curId + cols - 1;
        if (id <= cols * rows) then return id; end
    end
end

local function getDirCells(dirMethod, curId, deep, container)
    deep = deep - 1;
    local id = dirMethod(curId);
    if (id) then
        local cell = CellModel.getCell(id);
        table.insert(container, cell);

        if (deep > 0) then
            getDirCells(dirMethod, id, deep, container);
        end
    end
end

function C:getNearCells(curCell, dir)
    local dirMethods = {};
    local cells = {};

    if (dir == C.Direction.RL) then
        table.insert(dirMethods, getId_R);
        table.insert(dirMethods, getId_L);
    elseif (dir == C.Direction.UD) then
        table.insert(dirMethods, getId_U);
        table.insert(dirMethods, getId_D);
    elseif (dir == C.Direction.D1) then
        table.insert(dirMethods, getId_RU);
        table.insert(dirMethods, getId_LD);
    elseif (dir == C.Direction.D2) then
        table.insert(dirMethods, getId_RD);
        table.insert(dirMethods, getId_LU);
    end

    for _, method in ipairs(dirMethods) do
        getDirCells(method, curCell.id, cols, cells);
    end

    return cells;
end

function C:checkUsedCells(curCell)
    local curStatus = curCell.status;
    local used = CellModel.Status.USED;

    for _, dir in pairs(C.Direction) do
        local cells = self:getNearCells(curCell, dir);
        if (#cells >= cols-1) then
            local selected = {};
            table.insert(selected, curCell);
            for i, cell in pairs(cells) do
                if (cell.status == curCell.status) then
                    table.insert(selected, cell);
                end
            end

            local group = {};
            if (#selected >= cols) then
                curCell.status = used;
                table.insert(group, curCell);
                for i, cell in ipairs(selected) do
                    if (i > cols) then break; end
                    cell.status = used;
                    table.insert(group, cell);
                end
                table.insert(usedCells[curStatus], group);
                settings.status = SettingsModel.Status.GAME_FINISHED;
                break;
            end
        end
    end
end

function C:onClick(x, y)
    if (settings.status ~= SettingsModel.Status.GAME_RUN) then
        return;
    end

    if (isCpuStep) then
        return;
    end

    local cellX = self:getCellByPos(x, y);
    if (cellX == nil or cellX.status ~= CellModel.Status.EMPTY) then
        return;
    end

    cellX.status = CellModel.Status.MARK_X;
    if (settings.stepBy == SettingsModel.StepBy.PLAYER_2) then
        cellX.status = CellModel.Status.MARK_O;
    end

    settings:incStep();
    self:checkUsedCells(cellX);

    if (settings.status ~= SettingsModel.Status.GAME_RUN) then
        return;
    end

    stepFinished();
end

local stepCpuTimer = 0;
function C:onUpdate(dt)
    if (not isCpuStep) then
        return;
    end

    stepCpuTimer = stepCpuTimer + dt;
    if (stepCpuTimer > 2) then
        stepCpuTimer = 0;

        local marak = CellModel.Status.MARK_O;
        if (settings.stepBy == SettingsModel.StepBy.CPU_2) then
            marak = CellModel.Status.MARK_X;
        end

        local cellO = cpuAI:step(marak);
        if (cellO) then
            self:checkUsedCells(cellO);
        end

        stepFinished();
    end
end

function C:onDraw()
    local cells = CellModel.getCells();
    local size = self.cellSize;

    --draw cells
    for _, cell in pairs(cells) do
        self.viewer:drawCell(cell.x-size/2, cell.y-size/2, size);

        if (cell.status == CellModel.Status.MARK_O) then
            self.viewer:drawO(cell.x, cell.y, self.viewer.Color.RED);
        elseif (cell.status == CellModel.Status.MARK_X) then
            self.viewer:drawX(cell.x, cell.y, self.viewer.Color.GREEN);
        elseif (cell.status == CellModel.Status.USED) then
            self.viewer:drawUsed(cell.x-size/2, cell.y-size/2, size);
        end
    end

    --draw lines
    for key, value in pairs(usedCells) do
        local color = self.viewer.Color.RED;
        if (key == CellModel.Status.MARK_X) then
            color = self.viewer.Color.GREEN;
        end

        for _, group in ipairs(value) do
            local prevCell;
            for _, cell in ipairs(group) do
                if (prevCell == nil) then
                    prevCell = cell;
                else
                    self.viewer:drawLine(prevCell.x, prevCell.y, cell.x, cell.y, color);
                end
            end
        end
    end
end

return C;