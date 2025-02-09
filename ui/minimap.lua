local State = require("player.state")
local Map = require("engine.map.map")

local Minimap = {
    isOpen = false
}
local visionRadius = 30 -- Rayon de découverte en tuiles

function Minimap.load()
    Minimap.width = 600
    Minimap.height = 600

    -- calculate the center of the minimap
    Minimap.x = (love.graphics.getWidth() / 2) - (Minimap.width / 2)
    Minimap.y = (love.graphics.getHeight() / 2) - (Minimap.height / 2)

    -- Stocker les tuiles explorées sous forme d'une table
    Minimap.discoveredTiles = {}
end

function Minimap.keypressed(key)
    if key == "tab" then
        Minimap.isOpen = true
    end
end

function Minimap.keyreleased(key)
    if key == "tab" then
        Minimap.isOpen = false
    end
end

function Minimap.update(dt)
    local playerTileX, playerTileY = Map.worldToGrid(State.x, State.y)

    -- Explorer une zone carrée de 60x60 autour du joueur
    for dx = -visionRadius, visionRadius do
        for dy = -visionRadius, visionRadius do
            local tileX, tileY = playerTileX + dx, playerTileY + dy

            -- Vérifier que la tuile est bien dans les limites de la carte
            if tileX >= 1 and tileY >= 1 and tileX <= Map.MAP_WIDTH and tileY <= Map.MAP_HEIGHT then
                if not Minimap.discoveredTiles[tileX] then
                    Minimap.discoveredTiles[tileX] = {}
                end

                if not Minimap.discoveredTiles[tileX][tileY] then
                    local biome = Map.getBiomeAtPosition(tileX * Map.TILE_SIZE, tileY * Map.TILE_SIZE)
                    if biome then
                        Minimap.discoveredTiles[tileX][tileY] = biome.color
                    end
                end
            end
        end
    end
end

function Minimap.translateWorldToMinimap(x, y)
    -- Facteur d'échelle basé sur la taille du monde
    local scaleX = Minimap.width / Map.WORLD_WIDTH
    local scaleY = Minimap.height / Map.WORLD_HEIGHT

    -- Transformation du monde à la minimap
    local mx = Minimap.x + (x * scaleX)
    local my = Minimap.y + (y * scaleY)

    return mx, my
end
function Minimap.draw()
    if not Minimap.isOpen then
        return
    end

    -- Dessiner la minimap (fond semi-transparent)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", Minimap.x, Minimap.y, Minimap.width, Minimap.height)

    -- Dessiner les zones découvertes
    for tileX, row in pairs(Minimap.discoveredTiles) do
        for tileY, color in pairs(row) do
            local mx, my = Minimap.translateWorldToMinimap(tileX * Map.TILE_SIZE, tileY * Map.TILE_SIZE)
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", mx, my, 3, 3) -- Dessiner un carré pour représenter la tuile
        end
    end

    -- Dessiner le joueur en blanc
    local playerMiniX, playerMiniY = Minimap.translateWorldToMinimap(State.x, State.y)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", playerMiniX, playerMiniY, 4)

    -- Dessiner les ennemis en rouge
    local enemies = GlobalState:getEntitiesByType("enemy")
    for _, enemy in ipairs(enemies) do
        local enemyMiniX, enemyMiniY = Minimap.translateWorldToMinimap(enemy.x, enemy.y)
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", enemyMiniX, enemyMiniY, 4)
    end

    -- Dessiner le beacon en jaune
    local beacon = Map.beacon
    if beacon then
        local beaconMiniX, beaconMiniY = Minimap.translateWorldToMinimap(beacon.x, beacon.y)
        love.graphics.setColor(1, 1, 0)
        love.graphics.circle("fill", beaconMiniX, beaconMiniY, 4)
    end

    love.graphics.setColor(1, 1, 1)
end

-- Ensure the Minimap is loaded
Minimap.load()

return Minimap
