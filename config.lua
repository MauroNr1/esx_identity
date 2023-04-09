Config                  = {}
Config.Locale = GetConvar('esx:locale', 'en')

-- EXPERIMENTAL Character Registration Method
Config.UseDeferrals     = false --DO NOT TURN ON! NOT COMPATIBLE WITH THIS FORK!

-- These values are for the date format in the registration menu
-- Choices: DD/MM/YYYY | MM/DD/YYYY | YYYY/MM/DD
Config.DateFormat       = 'DD/MM/YYYY'

-- These values are for the second input validation in server/main.lua
Config.MaxNameLength    = 20 -- Max Name Length.
Config.MinHeight        = 120 -- 120 cm lowest height
Config.MaxHeight        = 220 -- 220 cm max height.

Config.FullCharDelete   = true -- Delete all reference to character.