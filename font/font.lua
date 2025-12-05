function newFont(img, width, height)
	local font = {
		chars = {
			"ABCDEFGHIJKLM",
			"NOPQRSTUVWXYZ",
			"abcdefghijklm",
			"nopqrstuvwxyz",
			"1234567890.,;",
			":\'\"!@#$%^&*()",
			"-_=+/\\|?<>[]~",
			"{}` "
		},
	}
	font.img = love.graphics.newImage(img)
	font.width, font.height = width, height
	font.quads = {}
	for y = 1, #font.chars do
		for x = 1, string.len(font.chars[y]) do
			font.quads[font.chars[y]:sub(x, x)] = love.graphics.newQuad(
				(x - 1) * width, (y - 1) * height, width, height,
				font.img:getWidth(), font.img:getHeight()
			)
		end
	end
	font.quads['invalid'] = love.graphics.newQuad(
		13 * width, 0, width, height, 
		font.img:getDimensions()
	)
	function font:print(str, tx, ty, scale)
		local batch = love.graphics.newSpriteBatch(self.img)
		x = 0
		y = 0
		for n = 1, string.len(str) do
			x = x + 1
			char = str:sub(n, n)
			if char == ' ' then --do nothing and skip to next character
			elseif char == '\n' then --new line
				y = y + 1
				x = 0
			elseif self.quads[char] == nil then --display question box if character is not in font
				batch:add(self.quads['invalid'], (x - 1) * (self.width + 1), y + self.height)
			else --write the character
				batch:add(self.quads[char], (x - 1) * (self.width + 1), y * self.height)
			end
		end
		love.graphics.draw(batch, tx, ty, 0, scale, scale)
	end
	function font:getWidth(text, scale)
		local out = 0
		for i in text:gmatch("([^\n]+)") do
			if string.len(i) > out then out = string.len(i) end
		end
		return out * (self.width + 1)
	end
	function font:getHeight(text, scale)
		local out = 0
		for i in text:gmatch("([^\n]+)") do
			out = out + 1
		end
		return out * (self.height)
	end

	return font
end

local pixel = newFont('font/pixel.png', 4, 7)

return {
	pixel = pixel
}
