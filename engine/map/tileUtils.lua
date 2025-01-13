local TileUtils = {}

-- Fonction utilitaire pour découper un tileset en quads
function TileUtils.createTileQuads(tileset, tileSize)
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

return TileUtils
