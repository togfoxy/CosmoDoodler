constants = {}

function constants.load()

    GAME_VERSION = "dev version 0.02"
    love.window.setTitle("CosmoDoodler " .. GAME_VERSION)

    SCREEN_STACK = {}

    -- SCREEN_WIDTH, SCREEN_HEIGHT = love.window.getDesktopDimensions(1)
    SCREEN_WIDTH, SCREEN_HEIGHT = res.getGame()

    -- camera
    ZOOMFACTOR = 0.7
    TRANSLATEX = cf.round(SCREEN_WIDTH / 2)		-- starts the camera in the middle of the ocean
    TRANSLATEY = cf.round(SCREEN_HEIGHT / 2)	-- need to round because this is working with pixels

    cam = nil       -- camera
    AUDIO = {}
    MUSIC_TOGGLE = true     --! will need to build these features later
    SOUND_TOGGLE = true

    IMAGE = {}
    FONT = {}

    -- set the folders based on fused or not fused
    savedir = love.filesystem.getSourceBaseDirectory()
    if love.filesystem.isFused() then
        savedir = savedir .. "\\savedata\\"
    else
        savedir = savedir .. "/CosmoDoodler/savedata/"
    end

    enums.load()
    -- add extra items below this line

    TOOLBAR_HEIGHT = 350
    CURRENT_SELECTION = 1           -- the type of object that will be placed with a mouse click. Algins to enum.image...

    TRANSLATE_TOOLBAR_X = 0
    TRANSLATE_TOOLBAR_Y = 0

    MOUSE_MODE = enum.mousemodeNormal       -- controls the state of the mouse
    MOUSE_DOWN = {}                         -- used to remember and track mouse dragging

    OBJECTS = {}
    TOOLBAR = {}             -- the toolbar contains all the images

end

return constants
