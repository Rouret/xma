local BiomeRegistry = {}

BiomeRegistry.biomes = {}

function BiomeRegistry.register(name, biomeModule)
    BiomeRegistry.biomes[name] = biomeModule
end

function BiomeRegistry.getBiome(name)
    return BiomeRegistry.biomes[name]
end

return BiomeRegistry
