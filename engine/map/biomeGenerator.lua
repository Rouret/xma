local BiomeGenerator = {}

BiomeGenerator.BIOMES = {
    {name = "Forest", minAltitude = 0, maxAltitude = 0.5, minHumidity = 0.5, maxHumidity = 1},
    {name = "Desert", minAltitude = 0, maxAltitude = 0.5, minHumidity = 0, maxHumidity = 0.5},
    {name = "Taiga", minAltitude = 0.5, maxAltitude = 1, minHumidity = 0, maxHumidity = 1}
}
function BiomeGenerator.assignBiomes(width, height, altitudeMap, humidityMap)
    local biomes = {}

    for y = 1, height do
        biomes[y] = {}
        for x = 1, width do
            local altitude = altitudeMap[y][x]
            local humidity = humidityMap[y][x]
            local assignedBiome = nil

            for _, biome in ipairs(BiomeGenerator.BIOMES) do
                if
                    (not biome.minAltitude or altitude >= biome.minAltitude) and
                        (not biome.maxAltitude or altitude <= biome.maxAltitude) and
                        (not biome.minHumidity or humidity >= biome.minHumidity) and
                        (not biome.maxHumidity or humidity <= biome.maxHumidity)
                 then
                    assignedBiome = biome
                    break
                end
            end

            -- Assigner un biome par défaut si aucun n'est trouvé
            if not assignedBiome then
                assignedBiome = {name = "Default"}
            end

            biomes[y][x] = assignedBiome
        end
    end

    return biomes
end

return BiomeGenerator
