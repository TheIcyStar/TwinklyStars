--[[
   |--------------------------------------------|
   |     TheIcyStar's twinkling star script     |
   |--------------------------------------------|
   
	Tips aren't expected, but greatly appreciated. Thanks!
   	BTC: 1GvHH4SXiMtyCGJ3iLtXEcBmFVM4Lc37ze
	
	
	Part of TwinklyStars
	This is an alternative script that has a bug in it, but the twinkling effect was interesting so I kept it
	for those who are interested and like to poke around with scripts.
	If you'd like to use this, change this in the .ini file:
	
	[MeasureScript]
	Measure=Script
	ScriptFile=Twinkler.lua
	
	to this:
	
	[MeasureScript]
	Measure=Script
	ScriptFile=Twinkler_Odd.lua
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
	TwinkleTransparencyMin = tonumber(SKIN:GetVariable("TwinkleTransparencyMin"))
	TwinkleTransparencyMax = tonumber(SKIN:GetVariable("TwinkleTransparencyMax"))
	
	--Variables used for timing and other things
	fps = 1000/UpdateRate
	framesPerCycle = TwinkleFrequency*fps
	framesPerCycleDiv2 = math.floor(framesPerCycle/2) --performance boost & a bug fix if I do this here instead of in the update loop
	
	
	--random seed set
	if RandomSeed ~= 0 then
		math.randomseed(RandomSeed)
	end

	--tint list setup
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
		newMeter.maxBrightness = math.random(TwinkleTransparencyMin, TwinkleTransparencyMax)
		newMeter.twinkleOffset = math.random(0,framesPerCycle)
		
		--math is weird. Here's a fix to avoid a dumb bug
		if newMeter.twinkleOffset == framesPerCycleDiv2 then
			newMeter.twinkleOffset = newMeter.twinkleOffset - 1
		end --this also could have been in a "repeat x until y" loop, oh whatever
		
		
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
			
			if v.twinkleOffset < framesPerCycleDiv2 then
				--wrapped offset
				if timer >= v.twinkleOffset and timer < v.twinkleOffset + framesPerCycleDiv2 then
					newBrightness = linear(timer, v.minBrightness, v.maxBrightness, framesPerCycleDiv2)
				else
					local fixedTimer = timer - v.twinkleOffset - framesPerCycleDiv2
					if fixedTimer < 0 then
						fixedTimer = fixedTimer * -1 + 1
					end
					newBrightness = linear(fixedTimer, v.maxBrightness, v.minBrightness, framesPerCycleDiv2)
					
				end
				
			else
				--standard
				if timer < (v.twinkleOffset + framesPerCycleDiv2) % framesPerCycle or timer >= v.twinkleOffset then
					newBrightness = linear((timer - v.twinkleOffset)% framesPerCycle, v.minBrightness, v.maxBrightness, framesPerCycleDiv2)
				else
					newBrightness = linear(((timer - v.twinkleOffset - framesPerCycleDiv2)% framesPerCycle), v.maxBrightness, v.minBrightness, framesPerCycleDiv2)
				end
				
			end
			
			
			--[ apply values
			if tintsActive then
				SKIN:Bang("!SetOption", v.name, "ImageTint", v.tint..","..newBrightness)
			else
				SKIN:Bang("!SetOption", v.name, "ImageTint", "255,255,255,"..newBrightness)
			end
			--]]
			--[[ debug
			if disc then
				SKIN:Bang("!SetOption", v.name, "ImageTint", "0,255,0,"..newBrightness)
			else
				SKIN:Bang("!SetOption", v.name, "ImageTint", "255,0,0,"..newBrightness)
			end
			--]]
			
		end
	end
	
	
	--timer stuff
	timer = math.floor((timer + 1) % (framesPerCycle))
end
