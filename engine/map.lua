local Camera = require("engine.camera")

local Map = {}
Map.__index = Map

local TILE_SIZE = 32
local MAP_WIDTH = 1000
local MAP_HEIGHT = 1000

-- Crée une nouvelle instance de carte
function Map.new(world, tileQuads)
    local self = setmetatable({}, Map)
    self.tiles = {}
    self.world = world
    self.tileset = love.graphics.newImage("sprites/tilesets/v0.png")
    self.tileset:setFilter("nearest", "nearest")
    self.tileQuads = createTileQuads(self.tileset, 32)
    self.groundQuad = self.tileQuads[1]
    self.bushQuad = self.tileQuads[5]
    self:generate()
    return self
end

-- Génère la carte procédurale avec collisions
function Map:generate()
    for y = 1, MAP_HEIGHT do
        self.tiles[y] = {}
        for x = 1, MAP_WIDTH do
            local isBush = love.math.random(1, 10) == 1
            if isBush then
                self.tiles[y][x] = {quad = self.bushQuad, collision = true}
                local body = love.physics.newBody(self.world, (x - 0.5) * TILE_SIZE, (y - 0.5) * TILE_SIZE, "static")
                local shape = love.physics.newRectangleShape(TILE_SIZE, TILE_SIZE)
                local fixture = love.physics.newFixture(body, shape)
                fixture:setUserData("wall")
            else
                self.tiles[y][x] = {quad = self.groundQuad, collision = false}
            end
        end
    end
end

-- Dessine la carte (vue basée sur une caméra)
function Map:draw()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local scale = Camera.i.scale

    -- Calculer les coordonnées de début et de fin en fonction de la position de la caméra et de la taille de l'écran
    local startX = math.floor((Camera.i.x - screenWidth / (2 * scale)) / TILE_SIZE)
    local startY = math.floor((Camera.i.y - screenHeight / (2 * scale)) / TILE_SIZE)
    local endX = math.ceil((Camera.i.x + screenWidth / (2 * scale)) / TILE_SIZE)
    local endY = math.ceil((Camera.i.y + screenHeight / (2 * scale)) / TILE_SIZE)

    -- Limite le rendu à la zone visible
    for y = startY, endY do
        for x = startX, endX do
            if self.tiles[y] and self.tiles[y][x] then
                local tile = self.tiles[y][x]
                love.graphics.draw(
                    self.tileset,
                    tile.quad,
                    math.floor((x - 1) * TILE_SIZE),
                    math.floor((y - 1) * TILE_SIZE)
                )
            end
        end
    end
end

function createTileQuads(tileset, tileSize)
    local quads = {}
    local tilesetWidth = tileset:getWidth()
    local tilesetHeight = tileset:getHeight()
    for y = 0, tilesetHeight / tileSize - 1 do
        for x = 0, tilesetWidth / tileSize - 1 do
            table.insert(
                quads,
                love.graphics.newQuad(x * tileSize, y * tileSize, tileSize, tileSize, tileset:getDimensions())
            )
        end
    end
    return quads
end

return Map
