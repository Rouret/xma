local Biome = require("engine.map.biome")

Forest = Biome:extend()
Forest.__index = Forest

function Forest:init()
    local params = {}
    params.name = "Forest"
    params.minAltitude = 0
    params.maxAltitude = 0.5
    params.minHumidity = 0.5
    params.maxHumidity = 1
    params.color = {0, 1, 0}
    params.terrainPath = "sprites/tilesets/forest/forest_ground.png"
    params.terrainTileSize = 32
    params.elementsPath = "sprites/tilesets/forest/forest_elements.png"
    params.sub = {
        {
            elementName = "Big_tree",
            name = "Forest",
            color = {144 / 255, 203 / 255, 162 / 255},
            types = {"perlin", "random"},
            perlinMeta = {
                minAltitude = 0.1,
                maxAltitude = 0.20,
                minHumidity = 0.5,
                maxHumidity = 0.7,
                probability = 0.44
            },
            randomMeta = {
                probability = 0.01
            },
            element = {
                width = 55,
                height = 85,
                x = 0,
                y = 66,
                collision = true,
                hitbox = {x = 0, y = 0, width = 55, height = 85}
            }
        },
        {
            elementName = "Big_stone",
            name = "Big_stone",
            types = {"random"},
            randomMeta = {
                probability = 0.001
            },
            color = {144 / 255, 203 / 255, 162 / 255},
            element = {
                width = 50,
                height = 50,
                x = 49,
                y = 0,
                collision = true,
                hitbox = {x = 0, y = 0, width = 50, height = 50}
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
                x = 0,
                y = 0,
                collision = true,
                hitbox = {x = 0, y = 0, width = 40, height = 30}
            }
        },
        {
            elementName = "Big_bush",
            name = "Big_bush",
            types = {"random"},
            randomMeta = {
                probability = 0.001
            },
            color = {144 / 255, 203 / 255, 162 / 255},
            element = {
                width = 50,
                height = 50,
                x = 0,
                y = 181,
                collision = true,
                hitbox = {x = 0, y = 0, width = 50, height = 50}
            }
        }
    }

    Biome.init(self, params)

    return self
end

return Forest
