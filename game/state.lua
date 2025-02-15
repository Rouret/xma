local Camera = require("engine.camera")
local Config = require("config")
-- Global state table for all entities
GlobalState = {
    entities = {}
}

-- Function to add an entity to the global state
function GlobalState:addEntity(entity)
    table.insert(self.entities, entity)
    if Config.DEV_MODE and Config.DEBUG_GLOBAL_STATE then
        print("Entity added, current length: " .. #self.entities)
    end
end

-- Function to remove an entity from the global state
function GlobalState:removeEntity(entity)
    for i = #self.entities, 1, -1 do
        if self.entities[i] == entity then
            table.remove(self.entities, i)
            break
        end
    end

    if Config.DEV_MODE and Config.DEBUG_GLOBAL_STATE then
        print("Entity removed, current length: " .. #self.entities)
    end
end

-- Function to update all entities in the global state
function GlobalState:update(dt, world)
    for _, entity in ipairs(self.entities) do
        if entity.update then
            entity:update(dt, world)
        end
    end
end

-- Function to gell the number of enemiesType A in the global state
function GlobalState:getEnemiesByType(type) -- "A" or "B"
    local count = 0
    for _, entity in ipairs(self.entities) do
        if entity.type == "enemy" and entity.enemiesType == type then
            count = count + 1
        end
    end
    return count
end

function GlobalState:getAEnemies()
    return GlobalState:getEnemiesByType("A")
end

function GlobalState:getBEnemies()
    return GlobalState:getEnemiesByType("B")
end

-- Function to gell the number of enemiesType A in the global state
function GlobalState:getEntitiesByType(type) -- "A" or "B"
    local entities = {}
    for _, entity in ipairs(self.entities) do
        if entity.type == type then
            table.insert(entities, entity)
        end
    end
    return entities
end

-- Function to draw all entities in the global state
function GlobalState:draw()
    table.sort(
        self.entities,
        function(a, b)
            return (a.zindex or 0) < (b.zindex or 0)
        end
    )
    for _, entity in ipairs(self.entities) do
        local isOnScreen = Camera.isVisible(entity.x, entity.y, entity.width, entity.height)

        if entity.draw and isOnScreen then
            entity:draw()
        end
    end
end

return GlobalState
