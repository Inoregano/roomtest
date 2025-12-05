local gl = require"scripts/global"
local player = {
	x = 0,
	y = 0,
	width = 10, height = 13,
	xdir = 0, ydir = 0,
	direction = "right", state = "idle",
	frame = 0, maxFrame = 4, animSpeed = 4,
}
function player:init(room)
	self.room = room
end
function player:updateState()
	if self.xdir ~= 0 or self.ydir ~= 0 then 
		if self.state ~= "moving" then
			self.frame = 0
		end
		self.state = "moving"
		if self.ydir ~= 0 then
			self.direction = (self.ydir == -1) and "up" or "down"
		else
			self.direction = (self.xdir == -1) and "left" or "right"
		end
	else
		self.state = "idle"
	end
end

function player:updateFrame(dt)
	self.frame = (self.frame + dt * self.animSpeed) % self.maxFrame
end

function player:checkTouchingTilemap(field, status)
	field = field or "canWalk"
	status = status or false
	--turn top left and bottom right of self into grid positions
	local x1, y1 = gl.screenToGrid(self.x, self.y, self.room)
	local x2, y2 = gl.screenToGrid(self.x + self.width, self.y + self.height, self.room)

	for x, y in gl.iterateTiles(x1, y1, x2, y2) do
		if self.room.tiles[y][x][field] == status then
			--we can't just return true because that'll make a slightly bigger
			--section of the tile count as wall, which will have adverse effects
			return (
				self.x < (x) * gl.cellSize and 
				self.y < (y) * gl.cellSize and
				self.x + self.width > (x - 1) * gl.cellSize and
				self.y + self.height > (y - 1) * gl.cellSize
			)
		end
	end
	return false
end

function player:move(x, y)
	--move x first
	self.x = gl.clamp(self.x + x, 0, (self.room.width) * gl.cellSize - self.width)
	--if inside a wall, then move to appropriate edge
	if self:checkTouchingTilemap() then
		self.x = gl.clamp(
			(math.floor(self.x / gl.cellSize) + 1) * gl.cellSize - (x > 0 and self.width or 0),
			0, (self.room.height) * gl.cellSize - self.width
		)
	end
	--same for y
	self.y = gl.clamp(self.y + y, 0, (self.room.height) * gl.cellSize - self.height)
	if self:checkTouchingTilemap() then
		self.y = self.y - y gl.clamp(
			(math.floor(self.y / gl.cellSize + 1)) * gl.cellSize - (y > 0 and self.height or 0),
			0, (self.room.height) * gl.cellSize - self.height
		)
	end

	--find grid x and grid y
	self.gridX, self.gridY = gl.screenToGrid(self.x, self.y, self.room)
end

return player
