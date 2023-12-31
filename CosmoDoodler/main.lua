GAME_VERSION = "0.01"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

Camera = require 'lib.cam11.cam11'
-- https://notabug.org/pgimeno/cam11

bitser = require 'lib.bitser'
-- https://github.com/gvx/bitser

nativefs = require 'lib.nativefs'
-- https://github.com/EngineerSmith/nativefs

lovelyToasts = require 'lib.lovelyToasts'
-- https://github.com/Loucee/Lovely-Toasts

-- these are core modules
require 'lib.buttons'
require 'enums'
require 'constants'
fun = require 'functions'
cf = require 'lib.commonfunctions'
require 'draw'

function love.resize(w, h)
	res.resize(w, h)
end

function love.mousepressed( x, y, button, istouch, presses)
	local camx, camy = cam:toWorld(x, y)	-- converts screen x/y to world x/y
	local resx, resy = res.toGame(x, y)

	if button == 1 then
		-- this is used to detect mouse drags
		if #MOUSE_DOWN == 0 then
			MOUSE_DOWN = {}
			MOUSE_DOWN.x = camx
			MOUSE_DOWN.y = camy
		end
	end

	if y <= TOOLBAR_HEIGHT then
		-- toolbar. Clear selected objects
		fun.clearAllSelectedObjects()
	elseif button == 1 and camx > 100 and camy > TOOLBAR_HEIGHT then		-- not trash can
		local objectclicked = fun.selectObject(camx, camy)		-- will select or clear depending on mouse click
		if not objectclicked then
			-- no object selected so create an object
			local selectedtoolbargroup = fun.getSelectedToolbarGroup()
			if selectedtoolbargroup == nil then
				-- do nothing and clear selection
				fun.clearAllSelectedObjects()
			else
				local nearestx = cf.multiple(camx, 64) - 32		--! there is a function that does this
				local nearesty = cf.multiple(camy, 64) - 32
				fun.clearAllSelectedObjects()
				fun.createObjects(nearestx, nearesty, true)

				-- fun.selectObject(camx, camy)		-- will select or clear depending on mouse click
			end
		else
			-- existing object is clicked
			if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
				-- multi-select
				fun.selectObject(camx, camy)
			elseif love.keyboard.isDown("lshift") == false and love.keyboard.isDown("rshift") == false then
				-- single select
				fun.clearAllSelectedObjects()
				fun.selectObject(camx, camy)
			end
		end
	end
end

function love.mousereleased(x, y, button, isTouch)
	local camx, camy = cam:toWorld(x, y)	-- converts screen x/y to world x/y
	local resx, resy = res.toGame(x, y)

	if button == 1 then
		-- stop tracking mouse dragging
		MOUSE_DOWN = {}
	end

	if button == 1 and y <= TOOLBAR_HEIGHT then
	-- if button == 1 and resy <= TOOLBAR_HEIGHT then
	-- if button == 1 and resy <= res.toScreenY(TOOLBAR_HEIGHT) then

		-- toolbar is clicked
		-- do bounding box things
		for k, group in pairs(TOOLBAR) do
			local groupwidth, groupheight = fun.getWidthHeightofToolGroup(group)
			local x1 = group.x
			local x2 = x1 + groupwidth

			local y1 = group.y
			local y2 = y1 + groupheight

			-- if x >= x1 and x <= x2 and y >= y1 and y <= y2 then
			-- if camx >= x1 and camx <= x2 and camy >= y1 and camy <= y2 then
			if resx >= x1 and resx <= x2 and resy >= y1 and resy <= y2 then
				-- click detected
				group.isSelected = not group.isSelected
			else
				group.isSelected = false
			end
		end
	elseif button == 1 and x < 100 then
		-- trashcan. Destroy object
		local selectedIndexes = fun.getSelectedObjects()			-- returns a list of selected indexes
		for i = 1, #selectedIndexes do
			fun.deleteObject(selectedIndexes[i])
		end
	elseif button == 2 then
		if love.mouse.isDown(1) then
			-- rotate current item
			local selectedIndex = fun.getSelectedObject() 			--! only rotates the first selected object
			fun.rotateObject(selectedIndex)
		elseif y <= TOOLBAR_HEIGHT then
			-- maybe delete a group
			-- do bounding box things
			for k, group in pairs(TOOLBAR) do
				local groupwidth, groupheight = fun.getWidthHeightofToolGroup(group)
				local x1 = group.x
				local x2 = x1 + groupwidth

				local y1 = group.y
				local y2 = y1 + groupheight

				if x >= x1 and x <= x2 and y >= y1 and y <= y2 then
					-- click detected
					if group.isVanilla then
						-- delete is not allowed
					else
						TOOLBAR[k] = nil
					end
				end
			end
		else
			fun.clearAllSelectedObjects()
		end
	else
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	local camx, camy = cam:toWorld(x, y)	-- converts screen x/y to world x/y

	if love.mouse.isDown(1) and y > TOOLBAR_HEIGHT then
		-- detecting a drag event
		if MOUSE_DOWN.x ~= nil then
			-- get original and new node
			local nodex1, nodey1 = fun.getNearestNode(MOUSE_DOWN.x, MOUSE_DOWN.y)
			local nodex2, nodey2 = fun.getNearestNode(camx, camy)

			-- now get the distance to move all selected object by
			local deltax = nodex2 - nodex1
			local deltay = nodey2 - nodey1

			-- now move all the objects this much
			for k, object in pairs(OBJECTS) do
				if object.isSelected then
					object.x = object.x + deltax
					object.y = object.y + deltay
				end
			end
		end

		MOUSE_DOWN.x = camx
		MOUSE_DOWN.y = camy
	end

    if love.mouse.isDown(2) or love.mouse.isDown(3) then
        TRANSLATEX = TRANSLATEX - dx
        TRANSLATEY = TRANSLATEY - dy
    end
end

function love.wheelmoved(x, y)

	local mousex, mousey = love.mouse.getPosition()

	if mousey <= TOOLBAR_HEIGHT then
		-- scroll toolbar
		for k, v in pairs(TOOLBAR) do
			if y > 0 then
				v.x = v.x - 100
			else
				v.x = v.x + 100
			end
		end
	else
		if y > 0 then
			-- wheel moved up. Zoom in
			ZOOMFACTOR = ZOOMFACTOR + 0.05
		end
		if y < 0 then
			ZOOMFACTOR = ZOOMFACTOR - 0.05
		end
		if ZOOMFACTOR > 3 then ZOOMFACTOR = 3 end
		print("Zoom factor = " .. ZOOMFACTOR)
	end
end

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.removeScreen(SCREEN_STACK)
	end

	if key == "z" then
		if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
			fun.deleteLastObject()
		end
	end

	if key == "delete" then
		fun.deleteSelectedObject()
	end

	if key == "s" then
		if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
			-- save toolbar and objects
			cf.saveTableToFile("toolbar.dat", TOOLBAR)
			cf.saveTableToFile("objects.dat", OBJECTS)
		elseif love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
			-- save the selected items as a module
			fun.saveModule()
		end
	end

	if key == "n" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		OBJECTS = {}
	end
end

function love.load()

	res.init({width = 1920, height = 1080, mode = 2})

	local width, height = love.window.getDesktopDimensions( 1 )
	res.setMode(width, height, {resizable = true})

	love.graphics.setBackgroundColor(50/255, 50/255, 50/255, 1)

	constants.load()		-- also loads enums
	fun.loadFonts()
    fun.loadAudio()
	fun.loadImages()

	-- mainmenu.loadButtons()

	cam = Camera.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 1)
	cam:setZoom(ZOOMFACTOR)
	cam:setPos(TRANSLATEX,	TRANSLATEY)

	love.keyboard.setKeyRepeat(true)

	cf.addScreen(enum.sceneMainMenu, SCREEN_STACK)

	lovelyToasts.canvasSize = {SCREEN_WIDTH, SCREEN_HEIGHT}
	lovelyToasts.options.tapToDismiss = true
	lovelyToasts.options.queueEnabled = true
	-- =============================================

	fun.initialiseToolbar2()
	OBJECTS = cf.loadTableFromFile("objects.dat")
	-- TOOLBAR = cf.loadTableFromFile("toolbar.dat")
end

function love.draw()
    res.start()
	cam:attach()

	draw.drawGrid()
	draw.drawObjects()

	cam:detach()

	draw.drawToolbar()		-- after cam
	draw.trashcan()

    res.stop()
end

function love.update(dt)

	cam:setZoom(ZOOMFACTOR)
    cam:setPos(TRANSLATEX, TRANSLATEY)
end
