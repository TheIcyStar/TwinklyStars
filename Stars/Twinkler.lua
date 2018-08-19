--[[
   |--------------------------------------------|
   |     TheIcyStar's twinkling star script     |
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


--Aquires variables and variables on refresh
function Initialize()
	UpdateRate = tonumber(SKIN:GetVariable("UpdateRate"))
	NumStars = tonumber(SKIN:GetVariable("NumStars"))
	RandomSeed = tonumber(SKIN:GetVariable("RandomSeed"))
	TwinkleFrequency = tonumber(SKIN:GetVariable("TwinkleFrequency"))
	--TwinkleVariation = tonumber(SKIN:GetVariable("TwinkleVariation")) --decided that having less variation wouldn't be good, if somebody wants this I can easily add it in though
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
	framesPerCycleDiv2 = framesPerCycle/2 --performance boost in the main update loop?? doubt it but this won't hurt
	
	
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
	
	--Acquires Meters, creates particle objects
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
		
		--set values for the meter object
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


local timer = 1
function Update()

	for i,v in pairs(particleTable) do
		if not v.static then
			--main twinkling code
			local newBrightness
			local disc
			if v.twinkleOffset < (framesPerCycle / 2) then
			disc = true
				--wrapped offset
				if timer >= v.twinkleOffset and timer < v.twinkleOffset + framesPerCycleDiv2 then
					newBrightness = linear(timer, v.minBrightness, v.maxBrightness, framesPerCycleDiv2)
				else
					newBrightness = linear(timer - v.twinkleOffset - framesPerCycleDiv2, v.maxBrightness, v.minBrightness, framesPerCycleDiv2) 
				end
				
			else
			disc = false
				--standard
				if timer < (v.twinkleOffset + framesPerCycleDiv2) % framesPerCycle or timer >= v.twinkleOffset then
					newBrightness = linear((timer - v.twinkleOffset)% framesPerCycle, v.minBrightness, v.maxBrightness, framesPerCycleDiv2)
				else
					newBrightness = linear(((timer - v.twinkleOffset - framesPerCycleDiv2)% framesPerCycle), v.maxBrightness, v.minBrightness, framesPerCycleDiv2)
				end
				
			end
			
			
			--[[ apply values
			if tintsActive then
				SKIN:Bang("!SetOption", v.name, "ImageTint", v.tint..","..newBrightness)
			else
				SKIN:Bang("!SetOption", v.name, "ImageTint", "255,255,255,"..newBrightness)
			end
			--]]
			--[ debug
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
