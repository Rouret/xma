local Forest = {}

Forest.name = "Forest"
Forest.groundQuad = 2
Forest.elements = {"Tree", "Bush"}
Forest.spawnProbability = 0.2

-- Comportement spécifique de la forêt
function Forest.generateElement(x, y)
    local elementType = love.math.random() > 0.5 and "Tree" or "Bush"
    return {
        type = elementType,
        x = (x - 0.5) * 32,
        y = (y - 0.5) * 32,
        properties = {harvestable = elementType == "Tree"}
    }
end

return Forest
