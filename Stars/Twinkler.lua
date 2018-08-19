--[[
   |--------------------------------------------|
   |	   TheIcyStar's snowing script			|
   |	 	    Realistic  version				|
   |--------------------------------------------|
   	BTC: 1GvHH4SXiMtyCGJ3iLtXEcBmFVM4Lc37ze
	
	Part of TwinklyStars
	
	All configuration variables are in Stars.ini
	
	This script handles the placement and twinkling of all of the stars.
		
--]]
local particleTable = {}
local tints = {}
local tintsActive

--Linearly eases between values.
--t: time, b: begining value, _c: ending value, d: duration
function linear(t,b,_c,d)
	local c = _c - b
	return c * t / d + b
end


--Aquires variables and skins on refresh
function Initialize()
	UpdateRate = tonumber(SKIN:GetVariable("UpdateRate"))
	NumStars = tonumber(SKIN:GetVariable("NumStars"))
	RandomSeed = tonumber(SKIN:GetVariable("RandomSeed"))
	TwinkleFrequency = tonumber(SKIN:GetVariable("TwinkleFrequency"))
	--TwinkleVariation = tonumber(SKIN:GetVariable("TwinkleVariation"))
	StaticStarChance = tonumber(SKIN:GetVariable("StaticStarChance"))
	StartX = tonumber(SKIN:GetVariable("StartX"))
	EndX = tonumber(SKIN:GetVariable("EndX"))
	StartY = tonumber(SKIN:GetVariable("StartY"))
	EndY = tonumber(SKIN:GetVariable("EndY"))

	MinSize = tonumber(SKIN:GetVariable("MinSize"))
	MaxSize = tonumber(SKIN:GetVariable("MaxSize"))
	MinTransparency = tonumber(SKIN:GetVariable("MinTransparency"))
	MaxTransparency = tonumber(SKIN:GetVariable("MaxTransparency"))
	TwinkleTransparency = tonumber(SKIN:GetVariable("TwinkleTransparency"))
	
	--Variables used for timing and other things
	fps = 1000/UpdateRate
	framesPerCycle = TwinkleFrequency*fps
	
	
	--random seed set
	if RandomSeed ~= 0 then
		math.randomseed(RandomSeed)
	end


	NumImageTints = tonumber(SKIN:GetVariable("NumImageTints"))
	if NumImageTints ~= 0 then
		for i=1,NumImageTints do
			tints[i] = SKIN:GetVariable("ImageTint"..i)
		end
		tintsActive = true
	end
	
	--Acquires Meters, creates snowflake objects
	for i=1,NumStars do
		local newMeter = {
			["meter"] = SKIN:GetMeter("MeterStar"..i),
			["name"] = "MeterStar"..i,
			["size"] = 0,
			["tint"] = "255,255,255",
			["static"] = false,
			["minBrightness"] = 255,
			["maxBrightness"] = 255,
			["twinkleOffset"] = 0,
		}
		
		--set values for the meter
		newMeter.size = math.random(MinSize,MaxSize)
		if tintsActive then
			newMeter.tint = tints[math.random(1,#tints)]
		end
		if math.random(0,100) < StaticStarChance then
			newMeter.static = true
		end
		newMeter.minBrightness = math.random(MinTransparency, MaxTransparency)
		newMeter.maxBrightness = TwinkleTransparency --maybe make this a range later?
		newMeter.twinkleOffset = math.random(0,framesPerCycle)
		--temp
		newMeter.twinkleOffset = 35
		
		
		--apply values for meter
		if tintsActive then
			SKIN:Bang("!SetOption",newMeter.name,"ImageTint",newMeter.tint..","..newMeter.minBrightness)
		else
			SKIN:Bang("!SetOption",newMeter.name,"ImageTint","255,255,255,"..newMeter.minBrightness)
		end
		SKIN:Bang('[!SetOption "'..newMeter.name..'" "W" "'..newMeter.size..'"][!SetOption "'..newMeter.name..'" "H" "'..newMeter.size..'"]')
		newMeter.meter:SetX(math.random(StartX,EndX))
		newMeter.meter:SetY(math.random(StartY,EndY))
		
		particleTable[i] = newMeter
		if not particleTable[i] then
			print("ERROR! meter number "..i.." not found! Check names or adjust the variable NumStars")
		end
	end
end


local timer = 1 --used for snowflake spawn delays
function Update()

	for i,v in pairs(particleTable) do
		if not v.static then
			--main twinkling code
			local newBrightness
			
			local db
			if v.name == "MeterStar1" then
			
				db = true
			end
			
			local disc
			--if v.twinkleOffset + (framesPerCycle / 2) > framesPerCycle then
			if v.twinkleOffset < (framesPerCycle / 2) then
			disc = true --left off: fixing overwraps, debug code a plenty
				--wrapped offset
				if timer >= v.twinkleOffset and timer < v.twinkleOffset + (framesPerCycle / 2) then
					newBrightness = linear(timer, v.minBrightness, v.maxBrightness, framesPerCycle / 2)
					
					if db then 
						print("A") 
						print("Timer: "..timer.." minBright: "..v.minBrightness.." maxBright: "..v.maxBrightness.." framesperCycle: "..(framesPerCycle/2).." Result: "..newBrightness)
					end
				else
					newBrightness = linear(timer - v.twinkleOffset - (framesPerCycle/2), v.maxBrightness, v.minBrightness, framesPerCycle / 2) 
					
					if db then 
						print("B") 
						print("Timer: "..timer - v.twinkleOffset - (framesPerCycle/2).." minBright: "..v.minBrightness.." maxBright: "..v.maxBrightness.." framesperCycle: "..(framesPerCycle/2).." Result: "..newBrightness)
					end
				end
				
			else
			disc = false
				--standard
				if timer < (v.twinkleOffset + (framesPerCycle / 2)) % framesPerCycle or timer >= v.twinkleOffset then
					newBrightness = linear((timer - v.twinkleOffset)% framesPerCycle, v.minBrightness, v.maxBrightness, framesPerCycle / 2)
					
					if db then
						print("C")
						print("Timer: "..(timer - v.twinkleOffset)% framesPerCycle.." minBright: "..v.minBrightness.." maxBright: "..v.maxBrightness.." framesperCycle: "..(framesPerCycle/2).." Result: "..newBrightness)
					end
				else
					newBrightness = linear(((timer - v.twinkleOffset - (framesPerCycle/2))% framesPerCycle), v.maxBrightness, v.minBrightness, framesPerCycle / 2)
					
					if db then
						print("D")
						print("Timer: "..((timer - v.twinkleOffset - (framesPerCycle/2))% framesPerCycle).." minBright: "..v.minBrightness.." maxBright: "..v.maxBrightness.." framesperCycle: "..(framesPerCycle/2).." Result: "..newBrightness)
					end
				end
				
			end
			
			
			--[[apply values
			if tintsActive then
				SKIN:Bang("!SetOption", v.name, "ImageTint", v.tint..","..newBrightness)
			else
				SKIN:Bang("!SetOption", v.name, "ImageTint", "255,255,255,"..newBrightness)
			end
			--]]
			--[debug
			if disc then
				SKIN:Bang("!SetOption", v.name, "ImageTint", "0,255,0,"..newBrightness)
			else
				SKIN:Bang("!SetOption", v.name, "ImageTint", "255,0,0,"..newBrightness)
			end
			--]]
			
		end
	end
	
	
	--timer stuff
	timer = (timer + 1) % (framesPerCycle)
end
