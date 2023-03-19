Config                  = {}
Config.Locale = GetConvar('esx:locale', 'en')

-- [Config.EnableCommands]
-- Enables Commands Such As /char and /chardel
Config.EnableCommands   = ESX.GetConfig().EnableDebug

-- EXPERIMENTAL Character Registration Method
Config.UseDeferrals     = false -- DO NOT SET TO TRUE, NOT SUPPORTED!

-- How the date will be saved and shown in the identity menu. Only use these three options.
-- Choices: DD/MM/YYYY | MM/DD/YYYY | YYYY/MM/DD
Config.DateFormat       = 'DD/MM/YYYY'

-- These values are for the second input validation in server/main.lua
Config.MaxNameLength    = 25 -- Max Name Length.
Config.MinHeight        = 120 -- 120 cm lowest height
Config.MaxHeight        = 220 -- 220 cm max height.

Config.FullCharDelete   = true -- Delete all reference to character.
Config.EnableDebugging  = ESX.GetConfig().EnableDebug -- prints for debugging :)
