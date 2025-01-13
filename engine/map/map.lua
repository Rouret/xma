local TileUtils = require("engine.map.tileUtils")
local LayerGenerator = require("engine.map.layerGenerator")
local Camera = require("engine.camera")

local Map = {}
Map.__index = Map

local TILE_SIZE = 32
local MAP_WIDTH = 1000
local MAP_HEIGHT = 1000
local BUSH_CLUSTER_COUNT = 3000
local BUSH_CLUSTER_SIZE_MIN = 3
local BUSH_CLUSTER_SIZE_MAX = 24

function Map.new(world)
    local self = setmetatable({}, Map)

    self.world = world
    self.layers = {}

    self.tileset = love.graphics.newImage("sprites/tilesets/v0.png")
    self.tileset:setFilter("nearest", "nearest")

    self.tileQuads = TileUtils.createTileQuads(self.tileset, TILE_SIZE)
    self.groundQuads = {self.tileQuads[1], self.tileQuads[2], self.tileQuads[3], self.tileQuads[4]}
    self.bushQuad = self.tileQuads[5]

    self:generate()
    return self
end

function Map:generate()
    self.layers[0] = LayerGenerator.generateGround(MAP_WIDTH, MAP_HEIGHT, self.groundQuads)
    self.layers[1] =
        LayerGenerator.generateBushClusters(
        MAP_WIDTH,
        MAP_HEIGHT,
        BUSH_CLUSTER_COUNT,
        BUSH_CLUSTER_SIZE_MIN,
        BUSH_CLUSTER_SIZE_MAX,
        self.bushQuad,
        self.world
    )
end

function Map:drawLayer(layer)
    local tiles = self.layers[layer]
    if not tiles then
        return
    end

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local scale = Camera.i.scale
    local startX = math.max(1, math.floor((Camera.i.x - screenWidth / (2 * scale)) / TILE_SIZE))
    local startY = math.max(1, math.floor((Camera.i.y - screenHeight / (2 * scale)) / TILE_SIZE))
    local endX = math.min(MAP_WIDTH, math.ceil((Camera.i.x + screenWidth / (2 * scale)) / TILE_SIZE))
    local endY = math.min(MAP_HEIGHT, math.ceil((Camera.i.y + screenHeight / (2 * scale)) / TILE_SIZE))

    for y = startY, endY do
        for x = startX, endX do
            if tiles[y] and tiles[y][x] then
                local tile = tiles[y][x]
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

function Map:draw()
    for layer = 0, #self.layers do
        self:drawLayer(layer)
    end
end

return Map
