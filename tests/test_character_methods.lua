local lu = require('luaunit')
loadfile('../build/build_utils/wow_api/mixin.lua')()
loadfile('../build/build_utils/wow_api/Color.lua')()
loadfile('../build/build_utils/utils/load_toc.lua')('./test.toc')

---@type LibInventoryAce
local addon = _G.LibStub("AceAddon-3.0"):GetAddon("LibInventoryAce")
addon:OnInitialize()

---@type LibInventoryCharacter
local module = addon:GetModule("LibInventoryCharacter")
module:OnInitialize()

_G['Characters'] = {
    ["Mirage Raceway"] = {
        Quadduo = {
            class = "HUNTER",
            classFilename = "HUNTER",
            classId = 3,
            className = "Hunter",
            gender = 3,
            guild = "The Wasnots",
            money = 62993,
            name = "Quadduo",
            race = "NightElf",
            raceFile = "NightElf",
            raceID = 4,
            raceName = "Night Elf",
            realm = "Mirage Raceway"
        }
    }
}

---@type LibInventoryCharacterObject
local character_obj = module:current('Mirage Raceway', 'Quadduo')

function testCharacterProperties()
    lu.assertEquals(character_obj.money, 62993)
    lu.assertEquals(character_obj.guild, 'The Wasnots')
    lu.assertEquals(character_obj.name, 'Quadduo')
    lu.assertEquals(character_obj.realm, 'Mirage Raceway')
end

function testCharacterColor()
    lu.assertEquals(character_obj:color():GenerateHexColor(), 'ffaad372')
end

function testCharacterGenderString()
    lu.assertEquals(character_obj:genderString(), 'female')
end

function testCharacterIcon()
    local _, icon = character_obj:icon()
    lu.assertEquals(icon, { 0.75, 1.0, 0.5, 0.75 })
end

function testCharacterIconString()
    lu.assertEquals(character_obj:iconString(),
            "|TInterface/Glues/CharacterCreate/UI-CharacterCreate-Races:12:12:0:0:128:128:96:128:64:96|t")
end

os.exit(lu.LuaUnit.run())