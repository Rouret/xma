local Desert = {}

Desert.name = "Desert"
Desert.groundQuad = 1
Desert.elements = {"Cactus", "Rock"}
Desert.spawnProbability = 0.7 -- Moins denses que la forêt

function Desert.generateElement(x, y)
    local elementType = love.math.random() > 0.8 and "Cactus" or "Rock"
    return {
        type = elementType,
        x = (x - 0.5) * 32,
        y = (y - 0.5) * 32,
        properties = {spiky = elementType == "Cactus"}
    }
end

return Desert
