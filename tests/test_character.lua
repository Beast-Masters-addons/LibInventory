local lu = require('luaunit')
loadfile('../build/build_utils/wow_api/functions.lua')()
loadfile('../build/build_utils/utils/load_toc.lua')('./test.toc')

_G['LibInventoryDB'] = {}

---@type LibInventory
local addon = _G.LibStub("AceAddon-3.0"):GetAddon("LibInventoryAce")
addon:OnInitialize()

---@type LibInventoryCharacter
local module = addon:GetModule("LibInventoryCharacter")

function testCurrentCharacter()
    local char = module.current()
    lu.assertEquals(char.money, 62993)
    lu.assertEquals(char.guild, 'The Wasnots')
    lu.assertEquals(char.name, 'Quadduo')
    lu.assertEquals(char.realm, 'Mirage Raceway')
    lu.assertEquals(char:genderString(), 'female')
end

---Check if character data is saved to the global variable
function testSaveCharacter()
    _G['LibInventoryDB'] = {}
    addon:OnInitialize()
    module:OnInitialize()
    lu.assertNil(next(_G['LibInventoryDB']['namespaces']['Character']))
    module:save()
    lu.assertNotNil(next(module.db.realm['Quadduo']))
    lu.assertNotNil(next(_G['LibInventoryDB']['namespaces']['Character']['realm']['Mirage Raceway']['Quadduo']))
end

function testLoadCharacter()
    _G['LibInventoryDB'] = {
        namespaces = {
            Character = {
                realm = {
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
            }
        },
        profileKeys = {
            ["Quadduo - Mirage Raceway"] = "Quadduo - Mirage Raceway"
        }
    }
    addon:OnInitialize()
    module:OnInitialize()

    ---@type LibInventoryCharacterObject
    local character_obj = module:load('Mirage Raceway', 'Quadduo')
    lu.assertEquals(character_obj.name, 'Quadduo')
end

os.exit(lu.LuaUnit.run())