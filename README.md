# TwinklyStars
A rainmeter skin that adds twinkling stars to your desktop
This skin also is very customizable. You can change the speed at which stars twinkle, their size, color, and more.

### Installation
Head on over to the [releases](https://github.com/TheIcyStar/TwinklyStars/releases) page and download and run the latest .rmskin package.

### Custom variables
The customizable variables are found in the .ini file. Here is what each variable does:

#### UpdateRate
Must be the same as the `Update` variable in **[Rainmeter]**

#### NumStars
nust be the same as the number of **[MeterStarN]** s. If you have NumStars set to 30, then you should have **[MeterStar1]** through **[MeterStar30]**.

#### StarAntiAlias
Set to 1 to enable anti aliasing

#### TotalScreenAreaX, TotalScreenAreaY
Set to your screen resolution. For a 1080p monitor, set X to 1920 and Y to 1080.

#### RandomSeed
Set to zero to generate a random layout on every single refresh. Setting this to a number anything but zero will produce the same exact pattern of stars and twinkles every single refresh.

#### TwinkleFrequency
Amount of time, in seconds, for a "cycle" of one twinkle to happen. Lower numbers mean faster twinkles.

#### StaticStarChance
Percent chance, out of 100, for a start to not twinkle.
*If you would like to not have stars twinkle at all, set StaticStarChance to 100 instead of setting TwinkleFrequency to 0.*

#### StartX, EndX, StartY, EndY
The rectangle where stars spawn. 

#### MinSize, MaxSize
The range, in pixels, of how big each star is.

#### MinTransparency, MaxTransparency
The range of how "bright" each star is before the twinkle

#### TwinkleTransparencyMin, TwinkleTransparencyMax
The range of how "bright" each star is at the peak of its twinkle

#### Tints
Set `NumIMageTints` to whatever number of `ImageTintN`'s you have. So if you'd like to use two colors of tints, set `NumImageTints` to 2, and add the variables `ImageTint1` and `ImageTint2` under it.
