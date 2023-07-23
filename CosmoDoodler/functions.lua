functions = {}

function functions.loadImages()
    IMAGE[enum.imageCorridor] = love.graphics.newImage("assets/images/corridor.png")
    IMAGE[enum.image3x2Storage] = love.graphics.newImage("assets/images/3x2storage.png")
    IMAGE[enum.imageArmour] = love.graphics.newImage("assets/images/armor.png")
    IMAGE[enum.imageArmourTri] = love.graphics.newImage("assets/images/armor_tri.png")
    IMAGE[enum.imageThrusterHuge] = love.graphics.newImage("assets/images/thruster_huge.png")
    IMAGE[enum.imageThrusterMed] = love.graphics.newImage("assets/images/thruster_med.png")
    IMAGE[enum.imageShieldgenSmall] = love.graphics.newImage("assets/images/shieldgen_small.png")
    IMAGE[enum.imageReactorLarge] = love.graphics.newImage("assets/images/reactor_large.png")
    IMAGE[enum.imageControlroomSmall] = love.graphics.newImage("assets/images/controlroom_small.png")
end

function functions.loadFonts()
    FONT[enum.fontDefault] = love.graphics.newFont("assets/fonts/Vera.ttf", 12)
    FONT[enum.fontMedium] = love.graphics.newFont("assets/fonts/Vera.ttf", 14)
    FONT[enum.fontLarge] = love.graphics.newFont("assets/fonts/Vera.ttf", 18)
    FONT[enum.fontCorporate] = love.graphics.newFont("assets/fonts/CorporateGothicNbpRegular-YJJ2.ttf", 36)
    FONT[enum.fontalienEncounters48] = love.graphics.newFont("assets/fonts/aliee13.ttf", 48)

    love.graphics.setFont(FONT[enum.fontDefault])
end

function functions.loadAudio()
    -- AUDIO[enum.audioMainMenu] = love.audio.newSource("assets/audio/XXX.mp3", "stream")
end

-- Returns the closest multiple of 'size' (defaulting to 10).
local function multiple(n, size)
    size = size or 10
    return cf.round(n/size)*size
end

function functions.createObjects(mousex, mousey)
    -- if a tool group is selected then place that tool group on the grid
    -- a group with multiple icons is broken

    for k, group in pairs(TOOLBAR) do
        if group.isSelected then
            -- found the selected group. Dissect all the icons in it
            for j, icon in pairs(group) do
                if type(icon) == "table" then              -- idk why this is necessary but it is
                    local newobject = {}
                    newobject.x = mousex + icon.x
                    newobject.y = mousey + icon.y
                    newobject.type = icon.type
                    newobject.index = #OBJECTS + 1
                    table.insert(OBJECTS, newobject)
                end
            end
        end
    end
end

function functions.getLastIndex()
    -- gets the last index in OBJECTS table. Useful for deleting the last object.
    -- Output: nil means empty table.
    local highestindex = nil
    for k, v in pairs(OBJECTS) do
        if highestindex == nil or v.index > highestindex then
            highestindex = v.index
        end
    end
    return highestindex
end

function functions.deleteLastObject()

    local lastindex = fun.getLastIndex()
    for k, v in pairs(OBJECTS) do
        if v.index == lastindex then
            OBJECTS[k] = nil
        end
    end
end

function functions.initialiseToolbar2()

    local x = 50    -- the x/y is for the group - not the icons
    local y = 33

    for i = 1, #IMAGE do
        -- create an empty group
        local toolgroup = {}
        toolgroup.x = x
        toolgroup.y = y
        toolgroup.index = #TOOLBAR + 1

        -- create and addthe icons
        local toolbaritem = {}
        toolbaritem.type = i
        toolbaritem.x = 0
        toolbaritem.y = 0
        table.insert(toolgroup, toolbaritem)

        table.insert(TOOLBAR, toolgroup)
        local groupwidth, groupheight = fun.getWidthHeightofToolGroup(toolgroup)
        x = x + groupwidth + 20
    end

    local toolgroup = {}
    toolgroup.x = x
    toolgroup.y = y
    toolgroup.index = #TOOLBAR + 1

    local toolbaritem = {}
    toolbaritem.type = 1
    toolbaritem.x = 0
    toolbaritem.y = 0
    table.insert(toolgroup, toolbaritem)

    local toolbaritem = {}
    toolbaritem.type = 1
    toolbaritem.x = 64
    toolbaritem.y = 0
    table.insert(toolgroup, toolbaritem)

    table.insert(TOOLBAR, toolgroup)
    x = x + 100
end

function functions.selectObject(x, y)

    for k, v in pairs(OBJECTS) do
        -- do bounding box
        local x1 = v.x
        local y1 = v.y

        local imagewidth = IMAGE[v.type]:getWidth()
        local imageheight = IMAGE[v.type]:getHeight()

        local x2 = x1 + imagewidth
        local y2 = y1 + imageheight

        if x > x1 and x < x2 and y > y1 and y < y2 then
            v.isSelected = true
        else
            v.isSelected = false
        end
    end
end


function functions.getSelectedObject()
    -- returns the INDEX of the selected object or nil

    for k, v in pairs(OBJECTS) do
        if v.isSelected then
            return v.index
        end
    end
    return nil
end

function functions.getNearestNode(x, y)
    -- take any x, y value and return the x and y of the nearest node/cell
    local nearestx = cf.multiple(x, 64) - 32
    local nearesty = cf.multiple(y, 64) - 32
    return nearestx, nearesty
end

function functions.updateObjectXY(index, x, y)

    for k, v in pairs(OBJECTS) do
        if v.index == index then
            v.x = x
            v.y = y
        end
    end
end

function functions.clearAllSelectedObjects()

    for k, v in pairs(OBJECTS) do
        v.isSelected = false
    end
end

function functions.deleteObject(index)

    for k, v in pairs(OBJECTS) do
        if v.index == index then
            OBJECTS[k] = nil
        end
    end
end

function functions.deleteSelectedObject()
    for k, v in pairs(OBJECTS) do
        if v.isSelected then
            OBJECTS[k] = nil
        end
    end
end

function functions.getWidthHeightofToolGroup(group)
    -- checks all the x's and widths of all the tools and returns the rightmost x2 value
    -- input: a tool group
    -- output: width and height

    local xresult, yresult = 0, 0
    for k, tool in pairs(group) do
        if type(tool) == "table" then              -- idk why this is necessary but it is
            local imagewidth = IMAGE[tool.type]:getWidth()
            local imageheight = IMAGE[tool.type]:getHeight()

            local x2 = tool.x + imagewidth
            local y2 = tool.y + imageheight

            if x2 > xresult then xresult = x2 end
            if y2 > yresult then yresult = y2 end
        end
    end
    return xresult, yresult
end

function functions.getSelectedToolbarGroup()
    -- returns the group of icons selected on the toolbar else returns nil
    for k, group in pairs(TOOLBAR) do
        if group.isSelected then return group end
    end
    return nil
end


return functions
