local NoiseUtils = {}

function NoiseUtils.generateNoiseMap(width, height, scale, seed)
    local noiseMap = {}
    love.math.setRandomSeed(seed or os.time())

    for y = 1, height do
        noiseMap[y] = {}
        for x = 1, width do
            local nx = x / width * scale
            local ny = y / height * scale
            noiseMap[y][x] = love.math.noise(nx, ny)
        end
    end

    return noiseMap
end

return NoiseUtils
