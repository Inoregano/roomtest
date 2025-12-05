local font = require"font/font".pixel
local bump = require"bump/bump"
local gl = require"scripts/global"
local player = require"scripts/player"

love.graphics.setDefaultFilter("nearest")
math.randomseed(os.time())

love.window.setMode(gl.windowWidth * gl.windowScale, gl.windowHeight * gl.windowScale)

function newSheet(img, cellSize)
	local sheet = {
		img = love.graphics.newImage(img),
		quads = {},
	}
	sheet.width = sheet.img:getWidth() / cellSize
	sheet.height = sheet.img:getHeight() / cellSize
	sheet.batch = love.graphics.newSpriteBatch(sheet.img)
	for y = 1, sheet.height do
		sheet.quads[y] = {}
		for x = 1, sheet.width do
			sheet.quads[y][x] = love.graphics.newQuad(
				(x - 1) * cellSize,
				(y - 1) * cellSize,
				cellSize, cellSize,
				sheet.img
			)
		end
	end

	return sheet
end

local a = {
	tiles = newSheet("assets/tiles.png", gl.cellSize),
}

function newEntity(name)
	local entity = {
		occupies = {1, 1},
		check = "hello and welcome to the test entity.\ni hope you have a great day"
	}
	entity.name = name
	return entity
end
function newRoom(width, height)
	local room = {
		width = width,
		height = height,
		tiles = {},
		entities = {},
	}
	for y = 1, room.height do
		room.tiles[y] = {}
		for x = 1, room.width do
			room.tiles[y][x] = {
				value = 2,
				type = 1,
				canWalk = true,
			}
		end
	end
	
	function room:addEntity(name, x, y)
		local key 
		--this is surely the cleanest way of generating a random string
		while true do
			key =
				string.char(math.random(65, 65 + 25)):lower()..
				string.char(math.random(65, 65 + 25)):lower()..
				string.char(math.random(65, 65 + 25)):lower()..
				string.char(math.random(65, 65 + 25)):lower()..
				string.char(math.random(65, 65 + 25)):lower()..
				string.char(math.random(65, 65 + 25)):lower()
			if self.entities[key] == nil then
				break
			end
		end
		self.entities[key] = newEntity(name)
		self.entities[key].x, self.entities[key].y = x, y
	end
	
	function room:getEntity(x, y, type)
		for i, v in pairs(self.entities) do
			if self.entities[i].x == x and self.entities[i].y == y then
				if type == "key" then return i else return v end
			end
		end
	end

	return room
end

local room = newRoom(8, 8)
room.tiles[3][3].value, room.tiles[3][3].canWalk = 1, false
room:addEntity("test", 1, 1)

player:init(room)

local mouse = {
	x = 1,
	absx = 1,
	y = 1,
	absy = 1,
}

function love.update(dt)
	mouse.absx = math.floor(love.mouse.getX() / gl.windowScale)
	mouse.absy = math.floor(love.mouse.getY() / gl.windowScale)
	
	mouse.x = math.floor(mouse.absx / gl.cellSize) + 1
	mouse.y = math.floor(mouse.absy / gl.cellSize) + 1

	player.xdir = (love.keyboard.isDown("t") and 1 or 0) - (love.keyboard.isDown("r") and 1 or 0)
	player.ydir = (love.keyboard.isDown("s") and 1 or 0) - (love.keyboard.isDown("f") and 1 or 0)
	if player.ydir ~= 0 then player.dir = player.ydir * 2 else player.dir = player.xdir end
	player:move(player.xdir, player.ydir)
end
function love.keypressed(key)
	player:move(
		(love.keyboard.isDown("right") and 1 or 0) - (love.keyboard.isDown("left") and 1 or 0),
		(love.keyboard.isDown("down") and 1 or 0) - (love.keyboard.isDown("up") and 1 or 0)
	)
end


local fullCanvas = love.graphics.newCanvas(gl.windowWidth, gl.windowHeight)
love.graphics.setLineWidth(1)
function love.draw()
	love.graphics.setCanvas(fullCanvas)
	love.graphics.clear()
	
	a.tiles.batch:clear()
	for y = 1, room.height do
		for x = 1, room.width do
			a.tiles.batch:add(a.tiles.quads[room.tiles[y][x].value][room.tiles[y][x].type],
				(x - 1) * gl.cellSize, (y - 1) * gl.cellSize
			)
		end
	end
	love.graphics.draw(a.tiles.batch)
	
	love.graphics.rectangle("fill",
		player.x, player.y, player.width, player.height
	)
	love.graphics.setColor(0, 1, 1)

	love.graphics.rectangle("line",
		(mouse.x - 1) * gl.cellSize, (mouse.y - 1) * gl.cellSize,
		gl.cellSize, gl.cellSize
	)
	--[[
	love.graphics.setColor(0, 1, 0)
	love.graphics.rectangle("line",
		(player.gridX - 1) * gl.cellSize, (player.gridY - 1) * gl.cellSize, gl.cellSize, gl.cellSize
	)
	]]
	
	love.graphics.setColor(1, 1, 1)
	
	if room:getEntity(mouse.x, mouse.y) then
		font:print(
			room:getEntity(mouse.x, mouse.y).check,
			0, room.height * gl.cellSize
		)
	end
	font:print(
		("%d, %d\n%d, %d"):format(player.x, player.y, player.gridX, player.gridY),
		room.width * gl.cellSize, 0
	)
	
	love.graphics.setCanvas()
	love.graphics.draw(fullCanvas, 0, 0, 0, gl.windowScale, gl.windowScale)
end

