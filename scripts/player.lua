local gl = require"scripts/global"
local player = {
	x = 0,
	y = 0,
	width = gl.cellSize, height = gl.cellSize,
	xdir = 0, ydir = 0, dir = 0,
}
function player:init(room)
	self.room = room
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
	--adding widthbuffer/heightbuffer to x/y gives us the forwardmost edge in direction of movement
	local widthbuffer, heightbuffer = 0, 0
	if x > 0 then widthbuffer = self.width end
	if y > 0 then heightbuffer = self.width end

	
	--move x first
	self.x = gl.clamp(self.x + x, 0, (self.room.width - 1) * gl.cellSize)
	--if inside a wall, then move to appropriate edge
	if self:checkTouchingTilemap() then
		self.x = gl.clamp(
			(math.floor(self.x / gl.cellSize) + ((x < 0) and 1 or 0)) * gl.cellSize, 
			0, (self.room.height - 1) * gl.cellSize
		)
	end
	--same for y
	self.y = gl.clamp(self.y + y, 0, (self.room.height - 1) * gl.cellSize)
	if self:checkTouchingTilemap() then
		self.y = self.y - y gl.clamp(
			(math.floor(self.y / gl.cellSize) + ((y < 0) and 1 or 0)) * gl.cellSize,
			0, (self.room.height - 1) * gl.cellSize
		)
	end

	--find grid x and grid y
	self.gridX, self.gridY = gl.screenToGrid(self.x, self.y, self.room)
end

return player
