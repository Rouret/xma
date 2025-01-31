local Biome = require("engine.map.Biome")

Taiga = Biome:extend()
Taiga.__index = Taiga

function Taiga:init()
    local params = {}
    params.name = "Taiga"
    params.minAltitude = 0.5
    params.maxAltitude = 1
    params.minHumidity = 0
    params.maxHumidity = 1
    params.color = {1, 1, 1}
    params.terrainPath = "sprites/tilesets/taiga/taiga_ground.png"
    params.terrainTileSize = 32
    params.elementsPath = "sprites/tilesets/taiga/taiga_elements.png"
    params.sub = {
        {
            elementName = "Big_tree",
            name = "Taiga",
            types = {"perlin", "random"},
            perlinMeta = {
                minAltitude = 0.65,
                maxAltitude = 0.85,
                minHumidity = 0.4,
                maxHumidity = 0.6,
                probability = 0.5
            },
            randomMeta = {
                probability = 0.01
            },
            color = {236 / 255, 240 / 255, 243 / 255},
            element = {
                width = 55,
                height = 85,
                x = 0,
                y = 0,
                collision = true,
                hitbox = {x = 0, y = 0, width = 55, height = 85}
            }
        }
    }

    Biome.init(self, params)

    self.terrainQuads = {
        self.terrainQuads[1],
        self.terrainQuads[2],
        self.terrainQuads[3],
        self.terrainQuads[4],
        self.terrainQuads[5]
    }

    return self
end

return Taiga
