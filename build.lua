local lines = 0
local detect = false
local rows = 0
local ifUp = false
local tR = false

local left = turtle.turnLeft
local right = turtle.turnRight

local function forward()
	while not turtle.forward() do
		sleep(1)
	end
end

local function place()
	if ifUp then
		return turtle.placeUp()
	else
		return turtle.placeDown()
	end
end

lines = math.abs(readNumber("Which length?"))
detect = lines == 0
rows = math.abs(readNumber("Which width?"))
if rows == 0 then
	rows = 1
end
ifUp = readPos("Where?","up","down") == "up"
tR = readPos("First turn?","left","right") == "right"

turtle.select(1)
local item = turtle.getItemDetail(1)
print("Using block "..item.name..":"..item.damage)

local function selectItem()
	local msg = true
	while true do
		for i = 1,16,1 do
			local d = turtle.getItemDetail(i)
			if d and d.name == item.name and d.damage == item.damage then
				turtle.select(i)
				return
			end
		end
		if msg then
			print("Please insert more units of the block to use.")
			msg = false
		end
		sleep(1)
	end
end

while rows > 0 do
	if lines == 0 then
		local c = 1
		selectItem()
		place()
		while turtle.forward() do
			c = c + 1
			selectItem()
			place()
		end
		lines = c
		print("Detected length "..lines)
	else
		local c = lines
		while c > 0 do
			selectItem()
			place()
			c = c - 1
			if c > 0 then
				forward()
			end
		end
	end
	rows = rows - 1
	if rows > 0 then
		if tR then
			right()
			forward()
			right()
		else
			left()
			forward()
			left()
		end
		tR = not tR
	end
end