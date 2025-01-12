-- Global state table for all entities
GlobalState = {
    entities = {}
}

-- Function to add an entity to the global state
function GlobalState:addEntity(entity)
    table.insert(self.entities, entity)
end

-- Function to remove an entity from the global state
function GlobalState:removeEntity(entity)
    for i, e in ipairs(self.entities) do
        if e == entity then
            table.remove(self.entities, i)
            break
        end
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

-- Function to draw all entities in the global state
function GlobalState:draw()
    for _, entity in ipairs(self.entities) do
        if entity.draw then
            entity:draw()
        end
    end
end

return GlobalState
