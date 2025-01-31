local Biome = require("engine.map.biome")

Desert = Biome:extend()
Desert.__index = Desert

function Desert:init()
    local params = {}
    params.name = "Desert"
    params.minAltitude = 0
    params.maxAltitude = 0.5
    params.minHumidity = 0
    params.maxHumidity = 0.5
    params.color = {1, 1, 0}
    params.terrainPath = "sprites/tilesets/desert/desert_ground.png"
    params.terrainTileSize = 32
    params.elementsPath = "sprites/tilesets/desert/desert_elements.png"
    params.sub = {
        {
            elementName = "Cactus",
            name = "Cactus",
            color = {144 / 255, 203 / 255, 162 / 255},
            types = {"perlin", "random"},
            perlinMeta = {
                minAltitude = 0.1,
                maxAltitude = 0.20,
                minHumidity = 0.1,
                maxHumidity = 0.2,
                probability = 0.44
            },
            randomMeta = {
                probability = 0.01
            },
            element = {
                width = 45,
                height = 60,
                x = 0,
                y = 0,
                collision = true,
                hitbox = {x = 0, y = 0, width = 45, height = 60}
            }
        },
        {
            elementName = "Small_stone",
            name = "Small_stone",
            types = {"random"},
            randomMeta = {
                probability = 0.001
            },
            color = {144 / 255, 203 / 255, 162 / 255},
            element = {
                width = 40,
                height = 30,
                x = 48,
                y = 0,
                collision = true,
                hitbox = {x = 0, y = 0, width = 40, height = 30}
            }
        }
    }

    Biome.init(self, params)

    self.terrainQuads = {self.terrainQuads[1]}

    return self
end

return Desert
