local DrawUtils = {}

function DrawUtils.lifeBar(x, y, width, height, life, maxLife)
    local lifeWidth = width * life / maxLife

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", x, y, width, height)

    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", x, y, lifeWidth, height)

    love.graphics.setColor(1, 1, 1)
end

return DrawUtils
