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
    if OBJECTS ~= nil then
        for k, v in pairs(OBJECTS) do
            if v.isSelected then
                love.graphics.setColor(0,1,0,1)
            else
                love.graphics.setColor(1,1,1,1)
            end

            local imagetype = v.type    -- a number that is also an enum
            love.graphics.draw(IMAGE[imagetype], v.x, v.y, v.rotation, 1, 1, 0,0)
        end
    end
end

function draw.drawToolbar()
    -- draws the top toolbar that has the objects

    love.graphics.setColor(1, 1, 1, 0.25)
    love.graphics.rectangle("fill", 0,0, SCREEN_WIDTH, TOOLBAR_HEIGHT)

    love.graphics.setColor(1, 1, 1, 1)

    for k, toolgroup in pairs(TOOLBAR) do
        if toolgroup.isSelected then
            love.graphics.setColor(0,1,0,1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end

        -- scale down if tool or group is larger than the toolbar
        local w, h = fun.getWidthHeightofToolGroup(toolgroup)
        local scale = 1
        local maxheight = TOOLBAR_HEIGHT * 0.9      -- the max height allowed before scaling is forced
        if h > (maxheight) then
            -- scale
            scale = cf.round(maxheight / h, 2)
        end
        for j, tool in pairs(toolgroup) do
            if type(tool) == "table" then
                love.graphics.draw(IMAGE[tool.type], (toolgroup.x + tool.x) + scale, (toolgroup.y + tool.y) * scale, 0, scale, scale)
            end
        end
    end
end


function draw.trashcan()
    love.graphics.setColor(1, 0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("fill", 0, TOOLBAR_HEIGHT, 100, SCREEN_HEIGHT)
end

return draw
