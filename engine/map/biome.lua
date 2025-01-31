local Object = require("engine.object")
local TileUtils = require("engine.map.tileUtils")
local World = require("game.world")

Biome = Object:extend()
Biome.__index = Biome

function Biome:new(params)
    local instance = setmetatable({}, self)
    instance:init(params)
    return instance
end

function Biome:init(params)
    params = params or {}

    if not params.name then
        error("Name parameter is required")
    end

    if not params.minAltitude or not params.maxAltitude or not params.minHumidity or not params.maxHumidity then
        error("Altitude and humidity parameters are required")
    end

    if not params.terrainPath or not params.elementsPath then
        error("Terrain and elements paths are required")
    end

    -- Général
    self.name = params.name

    self.minAltitude = params.minAltitude
    self.maxAltitude = params.maxAltitude
    self.minHumidity = params.minHumidity
    self.maxHumidity = params.maxHumidity
    self.color = params.color or {0, 1, 0}

    --[[
    2 types of spawn strategies:
        - perlin: spawn based on perlin noise (perlinMeta)
            minAltitude
            maxAltitude
            minHumidity
            maxHumidity
            probability
        - random: spawn randomly (randomMeta)
            probability
    ]]
    self.sub = params.sub or {}

    -- Terrain
    self.terrainPath = params.terrainPath
    self.terrainTileSize = 32

    -- Éléments
    self.elementsPath = params.elementsPath

    -- Terrain
    self.terrain = love.graphics.newImage(self.terrainPath)
    self.terrain:setFilter("nearest", "nearest")
    self.terrainQuads = TileUtils.createTileQuads(self.terrain, self.terrainTileSize) or {}

    -- Éléments
    self.element = love.graphics.newImage(self.elementsPath)
    self.element:setFilter("nearest", "nearest")
    self.elementQuads = {}
    local elementWidth = self.element:getWidth()
    local elementHeight = self.element:getHeight()
    self.elements = {}

    for _, subElement in ipairs(self.sub) do
        subElement.quad =
            love.graphics.newQuad(
            subElement.element.x,
            subElement.element.y,
            subElement.element.width,
            subElement.element.height,
            elementWidth,
            elementHeight
        )
    end

    return self
end

function Biome:generateTerrain()
    local groundQuadIndex = love.math.random(#self.terrainQuads)
    return {
        quad = self.terrainQuads[groundQuadIndex],
        collision = false -- Pas d'obstacle par défaut
    }
end

function Biome:generateElement(x, y, altitude, humidity)
    for _, subElement in ipairs(self.sub) do
        local temp = nil
        for _, spawnType in ipairs(subElement.types) do
            if spawnType == "perlin" then
                temp = self:generateElementPerlin(subElement, x, y, altitude, humidity)
            end

            if temp then
                return temp
            end

            if spawnType == "random" then
                temp = self:generateElementRandom(subElement, x, y)
            end

            if temp then
                return temp
            end
        end
    end

    return nil
end

function Biome:generateElementPerlin(subElement, x, y, altitude, humidity)
    local probability = love.math.random()

    if (probability > subElement.perlinMeta.probability) then
        return nil
    end

    if
        altitude > subElement.perlinMeta.minAltitude and altitude < subElement.perlinMeta.maxAltitude and
            humidity > subElement.perlinMeta.minHumidity and
            humidity < subElement.perlinMeta.maxHumidity
     then
        return self:initElement(subElement, x, y)
    end

    return nil
end

function Biome:generateElementRandom(subElement, x, y)
    local probability = love.math.random()

    if (probability > subElement.randomMeta.probability) then
        return nil
    end

    return Biome:initElement(subElement, x, y)
end

function Biome:initElement(element, x, y)
    local elementType = element.elementName
    local elementData = element.element

    -- Conversion des coordonnées en pixels
    x = x * 32
    y = y * 32

    -- Création de l'élément
    local elementCreated = {
        quad = element.quad,
        type = elementType,
        x = x,
        y = y,
        collision = elementData.collision,
        hitbox = elementData.hitbox and
            {
                x = x + (elementData.hitbox.x or 0),
                y = y + (elementData.hitbox.y or 0) - (elementData.hitbox.height or 0), -- Centrer verticalement
                width = elementData.hitbox.width or 0,
                height = elementData.hitbox.height or 0
            } or
            nil
    }

    -- Si l'élément a une hitbox et collision, création du body physique
    if elementCreated.hitbox and elementCreated.collision then
        local body =
            love.physics.newBody(
            World.world,
            elementCreated.hitbox.x + elementCreated.hitbox.width / 2,
            elementCreated.hitbox.y + elementCreated.hitbox.height / 2,
            "static"
        )
        local shape = love.physics.newRectangleShape(elementCreated.hitbox.width, elementCreated.hitbox.height)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setUserData({name = "wall", type = "wall"})
    end

    return elementCreated
end

function Biome:drawElement(element)
    love.graphics.draw(self.element, element.quad, element.x, element.y - element.hitbox.height)
end

return Biome
