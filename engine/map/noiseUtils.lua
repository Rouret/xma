local love = require("love")

local NoiseUtils = {}

function NoiseUtils.generateNoiseMap(width, height, scale)
    local noiseMap = {}

    local baseX = 10000 * love.math.random()
    local baseY = 10000 * love.math.random()

    for y = 1, height do
        noiseMap[y] = {}
        for x = 1, width do
            local nx = (x / width) * scale + baseX
            local ny = (y / height) * scale + baseY
            noiseMap[y][x] = love.math.noise(nx, ny)
        end
    end

    return noiseMap
end

return NoiseUtils
