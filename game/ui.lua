local State = require("player.state")
local UIEffect = require("ui.effect")
local UIPlayer = require("ui.player")
local UI = {}

function UI.load()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    UI.screenWidth = screenWidth
    UI.screenHeight = screenHeight

    UI.font = {}
    UI.font.XL = love.graphics.newFont(48)
    UI.font.big = love.graphics.newFont(36)
    UI.font.medium = love.graphics.newFont(24)
    UI.font.small = love.graphics.newFont(16)

    return UI
end

function UI.update()
end

function UI:draw()
    UIPlayer.draw(UI)
    UIEffect.draw(UI)
end

function UI.formatTime(seconds)
    local remainingSeconds = seconds % 60
    return string.format("%d", remainingSeconds)
end

function UI.formatValue(value)
    return string.format("%d", math.floor(value))
end

return UI
