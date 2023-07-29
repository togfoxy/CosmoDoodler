functions = {}

function functions.loadImages()
    -- need to be loaded in correct order
    IMAGE[enum.imageLaserblasterSmall] = love.graphics.newImage("assets/images/laserblaster_small.png")
    IMAGE[enum.imageLaserblasterLarge] = love.graphics.newImage("assets/images/laserblaster_large.png")
    IMAGE[enum.imageDisrupter] = love.graphics.newImage("assets/images/disrupter.png")
    IMAGE[enum.imagePointDefence] = love.graphics.newImage("assets/images/point_defence.png")
    IMAGE[enum.imageMininglaserSmall] = love.graphics.newImage("assets/images/mininglaser_small.png")

    IMAGE[enum.imageCorridor] = love.graphics.newImage("assets/images/corridor.png")
    IMAGE[enum.image3x2Storage] = love.graphics.newImage("assets/images/3x2storage.png")
    IMAGE[enum.imageArmour] = love.graphics.newImage("assets/images/armor.png")
    IMAGE[enum.imageArmourTri] = love.graphics.newImage("assets/images/armor_tri.png")
    IMAGE[enum.imageThrusterHuge] = love.graphics.newImage("assets/images/thruster_huge.png")
    IMAGE[enum.imageThrusterMed] = love.graphics.newImage("assets/images/thruster_med.png")
    IMAGE[enum.imageShieldgenSmall] = love.graphics.newImage("assets/images/shieldgen_small.png")
    IMAGE[enum.imageReactorLarge] = love.graphics.newImage("assets/images/reactor_large.png")
    IMAGE[enum.imageControlroomSmall] = love.graphics.newImage("assets/images/controlroom_small.png")
    IMAGE[enum.imageHyperdriveSmall] = love.graphics.newImage("assets/images/hyperdrive_small.png")


    IMAGE[enum.imageCrewQuartersMed] = love.graphics.newImage("assets/images/crewquarters_med.png")




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

    if OBJECTS == nil then OBJECTS = {} end

    for k, group in pairs(TOOLBAR) do
        if group.isSelected then
            -- found the selected group. Dissect all the icons in it
            for j, icon in pairs(group) do
                if type(icon) == "table" then              -- idk why this is necessary but it is
                    local newobject = {}
                    newobject.x = mousex + icon.x
                    newobject.y = mousey + icon.y
                    newobject.type = icon.type
                    local newindex = fun.getLastOBjectsIndex()
                    newindex = newindex + 1
                    newobject.index = newindex
                    table.insert(OBJECTS, newobject)
                end
            end
        end
    end
end

function functions.getLastToolbarIndex()
    -- gets the last index in toolbar table. Useful for deleting the last object.
    -- Output: nil means empty table.
    local highestindex = 0
    for k, v in pairs(TOOLBAR) do
        if highestindex == nil or v.index > highestindex then
            highestindex = v.index
        end
    end
    return highestindex
end

function functions.getLastOBjectsIndex()
    -- gets the last index in OBJECTS table. Useful for deleting the last object.
    -- Output: nil means empty table.
    local highestindex = 0
    if OBJECTS ~= nil then
        for k, v in pairs(OBJECTS) do
            if highestindex == nil or v.index > highestindex then
                highestindex = v.index
            end
        end
    end
    return highestindex
end

function functions.deleteLastObject()
    local lastindex = fun.getLastOBjectsIndex()
    for k, v in pairs(OBJECTS) do
        if v.index == lastindex then
            OBJECTS[k] = nil
        end
    end
end

function functions.initialiseToolbar2()

    local x = 50    -- the x/y is for the group - not the icons
    local y = 33

    -- add each icon as a single item group
    -- for i = 1, #IMAGE do
    for k, v in pairs(IMAGE) do
        -- create an empty group
        local toolgroup = {}
        toolgroup.x = x
        toolgroup.y = y
        toolgroup.isVanilla = true
        toolgroup.index = fun.getLastToolbarIndex() + 1

        -- create and add the icons
        local toolbaritem = {}
        toolbaritem.type = k
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
    toolgroup.index = fun.getLastToolbarIndex() + 1

    local toolbaritem = {}
    toolbaritem.type = enum.imageCorridor
    toolbaritem.x = 0
    toolbaritem.y = 0
    table.insert(toolgroup, toolbaritem)

    local toolbaritem = {}
    toolbaritem.type = enum.imageCorridor
    toolbaritem.x = 64
    toolbaritem.y = 0
    table.insert(toolgroup, toolbaritem)

    table.insert(TOOLBAR, toolgroup)
    x = x + 20
end

function functions.selectObject(x, y)
    -- finds the object under the x/y and makes it selected
    -- does not unselect already selected items
    -- input: x,y
    -- output: returns true if something is under the mouse
    local result = false
    if OBJECTS ~= nil then
        for k, v in pairs(OBJECTS) do
            -- do bounding box
            -- this is the image height/width as saved on file (i.e. without any transformation)

            local x1, y1, x2, y2
            local imagewidth = IMAGE[v.type]:getWidth()
            local imageheight = IMAGE[v.type]:getHeight()
            -- need to transform x's and y's if image is rotated
            if v.rotation == nil or v.rotation == 0 then
                x1 = v.x
                y1 = v.y
                x2 = x1 + imagewidth
                y2 = y1 + imageheight
            elseif v.rotation == math.pi/2 then
                local imgheight = imagewidth
                local imgwidth = imageheight
                x1 = v.x - imgwidth
                y1 = v.y
                x2 = v.x
                y2 = v.y + imgheight
            elseif v.rotation == 2 * (math.pi / 2) then
                x1 = v.x - imagewidth
                y1 = v.y - imageheight
                x2 = v.x
                y2 = v.y
            elseif v.rotation == 3 * (math.pi / 2) then
                local imgheight = imagewidth
                local imgwidth = imageheight
                x1 = v.x
                y1 = v.y - imgwidth
                x2 = v.x + imgwidth
                y2 = v.y
            else
                print("v.rotation is " .. v.rotation)
                error()         -- should never happen
            end
            if x > x1 and x < x2 and y > y1 and y < y2 then
                v.isSelected = true
                result = true
            end
        end
    end
    return result
end

function functions.getSelectedObject()
    -- returns the INDEX of the selected object or nil
    --! only returns first object if more than one is selected

    for k, v in pairs(OBJECTS) do
        if v.isSelected then
            return v.index
        end
    end
    return nil
end

function functions.getSelectedObjects()
    -- returns the INDEX of the selected object or nil
    --! only returns first object if more than one is selected

    local result = {}           -- a list of indexes for all selected objects
    for k, v in pairs(OBJECTS) do
        if v.isSelected then
            table.insert(result, v.index)
        end
    end
    return result
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
    -- output: the width and height of the group
    --! suspects it returns the x2/y2 value and not the group height

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

function functions.rotateObject(selectedIndex)
    for k, object in pairs(OBJECTS) do
        if object.isSelected then
            if object.rotation == nil then object.rotation = 0 end

            -- the rotation is around the top left corner of the image. This makes the rotation seem odd. Compensate by moving the image one cell and then rotating
            -- math.pi/2 = 90 degrees
            if object.rotation == 0 then object.x = object.x + 64 end               -- move to the right one cell
            if object.rotation == math.pi/2 then object.y = object.y + 64 end       -- move down
            if object.rotation == 2 * (math.pi / 2) then object.x = object.x - 64 end
            if object.rotation == 3 * (math.pi / 2) then object.y = object.y - 64 end

            object.rotation = object.rotation + math.pi/2

            -- check for a full rotation
            while object.rotation >= (math.pi * 2) do
                object.rotation = object.rotation - (math.pi * 2)
            end

            assert(object.rotation < math.pi * 2)
        end
    end
end

function functions.saveModule()
    -- saves all selected items as a group to the toolbar

    -- these values capture the upper leftmost item in the group
    local minx
    local miny

    local x, y = fun.getToolbarLength()         -- only care about x

    local toolgroup = {}
    toolgroup.x = x + 20
    toolgroup.y = 33
    toolgroup.isVanilla = false
    toolgroup.index = fun.getLastToolbarIndex() + 1

    -- find all selected items and add them to the group
    for k, object in pairs(OBJECTS) do
        if object.isSelected then
            local toolbaritem = {}
            toolbaritem.type = object.type
            toolbaritem.x = object.x                -- this will get modified below
            toolbaritem.y = object.y
            table.insert(toolgroup, toolbaritem)

            if minx == nil or object.x < minx then minx = object.x end
            if miny == nil or object.y < miny then miny = object.y end
        end
    end

    -- now cycle through that toolgrou and rationalise the x/y values so they are all relative to the upper leftmost item
    -- minx/y is understood. Make all value relative to that
    for k, object in pairs(toolgroup) do
        if type(object) == "table" then
            object.x = object.x - minx
            object.y = object.y - miny
        end
    end
    table.insert(TOOLBAR, toolgroup)
end

function functions.getHighestIndex()
    --!
    local result = nil
    for k, group in pairs(TOOLBAR) do
        if result == nil or group.index > result then result = group.index end
    end
    return result
end

function functions.getToolbarGroup(index)
    -- returns the toolbar group (table) with the provided index

    for k, group in pairs(TOOLBAR) do
        if group.index == index then
            return group
        end
    end
    return nil
end

function functions.getToolbarLength()
    -- gets the right margin of the toolbar. Used to know where next group should be placed
    -- returns x and y
    local highestindex = fun.getHighestIndex()      -- scans toolbar groups.  --! should trap for a nil that never happens
    local group = fun.getToolbarGroup(highestindex)                             --! could be nil?
    local groupwidth, groupheight = fun.getWidthHeightofToolGroup(group)
    return group.x + groupwidth, group.y + groupheight
end

return functions
