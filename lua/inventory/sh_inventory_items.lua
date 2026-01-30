-- 1=	1	1
-- 2=	1	2
-- 3=	2	2
-- 4=	2	1
-- 5=	1	3
-- 6=	2	3
-- 7=	3	3
-- 8=	3	2
-- 9=	3	1
-- 10=	1	4
-- 11=	2	4
-- 12=	3	4
-- 13=	4	4
-- 14=	4	3
-- 15=	4	2
-- 16=	4	1


-- Current Types:
-- Weapon, Armor, Util
-- Primary Weapon: Size 9
-- Secondary Weapon: Size 4
-- Hand Weapon: Size 1
-- Ammo and Grenades: Size 1

InventoryItems = {
    ["weapon_crowbar"] = {
        ["Name"] = "Crowbar",
        ["Size"] = 4,
        ["Color"] = "#FF0000",
        ["Type"] = "Weapon"
    },
    ["weapon_pistol"] = {
        ["Name"] = "Pistol",
        ["Size"] = 1,
        ["Color"] = "#00FF00",
        ["Type"] = "Weapon"
    },
    ["weapon_smg1"] = {
        ["Name"] = "SMG1",
        ["Size"] = 4,
        ["Color"] = "#505050",
        ["Type"] = "Weapon"
    },
    ["weapon_frag"] = {
        ["Name"] = "Grenade",
        ["Size"] = 1,
        ["Color"] = "#FFFF00",
        ["Type"] = "Util"
    },
    ["weapon_ar2"] = {
        ["Name"] = "AR2",
        ["Size"] = 8,
        ["Color"] = "#FF00FF",
        ["Type"] = "Weapon"
    },
    ["weapon_crossbow"] = {
        ["Name"] = "Crossbow",
        ["Size"] = 9,
        ["Color"] = "#00FFFF",
        ["Type"] = "Weapon"
    },
    ["weapon_shotgun"] = {
        ["Name"] = "Shotgun",
        ["Size"] = 4,
        ["Color"] = "#7F7F7F",
        ["Type"] = "Weapon"
    },
    ["weapon_rpg"] = {
        ["Name"] = "RPGLauncher",
        ["Size"] = 9,
        ["Color"] = "#000000",
        ["Type"] = "Weapon"
    },
    ["item_ammo_smg1"] = {
        ["Name"] = "SMG Ammo",
        ["Size"] = 1,
        ["Color"] = "#FFFFFF",
        ["Type"] = "Util"
    },
    ["codesetter"] = {
        ["Name"] = "CodeSetter",
        ["Size"] = 1,
        ["Color"] = "#FF7F00",
        ["Type"] = "Util"
    },
    ["codezylinder_1"] = {
        ["Name"] = "Codezylinder Stufe 1",
        ["Size"] = 1,
        ["Color"] = "#0000FF",
        ["Type"] = "Util"
    },
    ["codezylinder_2"] = {
        ["Name"] = "Codezylinder Stufe 2",
        ["Size"] = 1,
        ["Color"] = "#FFFF00",
        ["Type"] = "Util"
    },
    ["codezylinder_3"] = {
        ["Name"] = "Codezylinder Stufe 3",
        ["Size"] = 1,
        ["Color"] = "#FF0000",
        ["Type"] = "Util"
    },
    ["codezylinder_4"] = {
        ["Name"] = "Codezylinder Stufe 4",
        ["Size"] = 1,
        ["Color"] = "#000000",
        ["Type"] = "Util"
    },
    ["smg1"] = {
        ["Name"] = "SMG Ammo (45x)",
        ["Ammo"] = 45,
        ["Size"] = 1,
        ["Color"] = "#000000",
        ["Type"] = "Util"
    },
    ["smg1_grenade"] = {
        ["Name"] = "SMG Ammo (1x)",
        ["Ammo"] = 1,
        ["Size"] = 1,
        ["Color"] = "#000000",
        ["Type"] = "Util"
    },
    ["pistol"] = {
        ["Name"] = "Pistol Ammo (18x)",
        ["Ammo"] = 18,
        ["Size"] = 1,
        ["Color"] = "#000000",
        ["Type"] = "Util"
    },
    ["model_armor"] = {
        ["Name"] = "Armor",
        ["Model_Route"] = "models/player/combine_super_soldier.mdl",
        ["Size"] = 6,
        ["Color"] = "#FFFFFF",
        ["Type"] = "Armor"
    },
    ["model_armor_black"] = {
        ["Name"] = "Black Armor",
        ["Model_Route"] = "models/player/combine_soldier_prisonguard.mdl",
        ["Size"] = 6,
        ["Color"] = "#A0A0A0",
        ["Type"] = "Armor"
    },
}
