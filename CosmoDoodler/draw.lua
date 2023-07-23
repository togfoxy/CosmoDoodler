draw = {}

function draw.drawGrid()
    local x1 = -480
    local y1 = 288
    local x2 = SCREEN_WIDTH + 500
    local y2 = SCREEN_HEIGHT + 500

    love.graphics.setColor(1, 1, 1, 0.25)
    for x = x1, x2, 64 do
        love.graphics.line(x, y1, x, y2)
    end

    love.graphics.setColor(1, 1, 1, 0.25)
    for y = y1, y2, 64 do
        love.graphics.line(x1, y, x2, y)
    end
end

function draw.drawObjects()
    love.graphics.setColor(1,1,1,1)
    for k, v in pairs(OBJECTS) do
        if v.isSelected then
            love.graphics.setColor(0,1,0,1)
        else
            love.graphics.setColor(1,1,1,1)
        end

        local imagetype = v.type    -- a number that is also an enum
        love.graphics.draw(IMAGE[imagetype], v.x, v.y, 0, 1, 1, 0,0)
    end
end

function draw.drawToolbar()
    -- draws the top toolbar that has the objects

    love.graphics.setColor(1, 1, 1, 0.25)
    love.graphics.rectangle("fill", 0,0, SCREEN_WIDTH, TOOBAR_HEIGHT)

    love.graphics.setColor(1, 1, 1, 1)

    for k, toolgroup in pairs(TOOLBAR) do
        if toolgroup.isSelected then
            love.graphics.setColor(0,1,0,1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end

        for j, tool in pairs(toolgroup) do
            if type(tool) == "table" then
                love.graphics.draw(IMAGE[tool.type], toolgroup.x + tool.x, toolgroup.y + tool.y)
            end
        end
    end
end


function draw.trashcan()
    love.graphics.setColor(1, 0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("fill", 0, TOOBAR_HEIGHT, 100, SCREEN_HEIGHT)
end

return draw
