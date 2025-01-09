-- Load the necessary libraries
local ui = {}

-- Initialize the spell bar
function ui:init()
    screen_width, screen_height = love.graphics.getDimensions()
    ui.image = love.graphics.newImage("sprites/auto.png")
    ui.x = screen_width / 2 - ui.image:getWidth() / 2
    ui.y = screen_height - ui.image:getHeight()
    ui.width = ui.image:getWidth()
    ui.height = ui.image:getHeight()
end

-- Draw the spell bar
function ui:draw()
    love.graphics.draw(ui.image, ui.x, ui.y)
end

return ui
