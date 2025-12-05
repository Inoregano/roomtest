local gl = {
	cellSize = 16,
	windowWidth = 240,
	windowHeight = 160,
	windowScale = 3,
}
function gl.clamp(val, min, max) 
	if val < min then return min elseif val > max then return max end return val 
end
function gl.screenToGrid(x, y, room, returntable)
	local returnx = gl.clamp(math.floor((x) / gl.cellSize) + 1, 1, room.width)
	local returny = gl.clamp(math.floor((y) / gl.cellSize) + 1, 1, room.height)
	
	if returntable then return {x = returnx, y = returny} end
	return returnx, returny
end

function gl.iterateTiles(x1, y1, x2, y2)
	local x, y = x1 - 1, y1
	return function()
		x = x + 1
		if x > x2 then
			x = x1
			y = y + 1
			if y > y2 then
				return nil
			end
		end
		return x, y
	end
end

function gl.switch(val, tbl)
	if not tbl[val] then return nil end
	if type(tbl[val]) == "function" then return tbl[val]() end
	return tbl[val]
end

return gl
