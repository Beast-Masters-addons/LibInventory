loadfile('../build/build_utils/utils/load_toc.lua')('./test.toc')
---@type LibInventoryAce
local addon = _G.LibStub("AceAddon-3.0"):GetAddon("LibInventoryAce")

---@type LibInventoryLocations
local module = addon:GetModule("LibInventoryLocations")

local lu = require('luaunit')
_G['test'] = {}
local test = _G['test']

function _G.UnitName()
    return 'Quadduo'
end

function _G.GetRealmName()
    return 'The Maelstrom'
end

function test.setUp()
    addon:OnInitialize()
    module:OnInitialize()
    addon.db:ResetDB()
end

function test.testSaveLocation()
    lu.assertEquals(module.db.char, { bags = {}, bank = {}, equipment = {}, mail = {} })
    lu.assertEquals(module.db.factionrealm, {})
    module:saveItemLocation(123, 'bags', 10, 'Quadduo', 'The Maelstrom')
    lu.assertNotNil(module.db.factionrealm[123])
    lu.assertNotNil(module.db.char['bags'])
end

function test.testGetItemLocation()
    module:saveItemLocation(123, 'bags', 10, 'Quadduo', 'The Maelstrom')
    local location = module:getItemLocation(123, 'Quadduo', 'The Maelstrom')
    lu.assertEquals(location, { bags = 10 })
end

function test.testClear()
    module:saveItemLocation(123, 'mail', 10, 'Quadduo', 'The Maelstrom')
    local location = module:getItemLocation(123, 'Quadduo', 'The Maelstrom')
    lu.assertEquals(location, { mail = 10 })
    module:saveItemLocation(123, 'bags', 10, 'Quadduo', 'The Maelstrom')
    module:clearLocation('mail')
    location = module:getItemLocation(123, 'Quadduo', 'The Maelstrom')
    lu.assertEquals(location, { bags = 10 })
end

function test.testClearSingleChar()
    module:saveItemLocation(123, 'mail', 10, 'Quadduo', 'The Maelstrom')
    module:saveItemLocation(124, 'mail', 19, 'Quadduo', 'The Maelstrom')
    module:saveItemLocation(123, 'bags', 8, 'Quadbear', 'The Maelstrom')
    module:saveItemLocation(123, 'mail', 8, 'Quadbear', 'The Maelstrom')
    lu.assertEquals(module:getItemLocation(123), {
        ["Quadbear-The Maelstrom"] = {
            bags = 8,
            mail = 8
        },
        ["Quadduo-The Maelstrom"] = {
            mail = 10
        }
    })
    lu.assertEquals(module:getItemLocation(124), {
        ["Quadduo-The Maelstrom"] = {
            mail = 19
        }
    })

    module:clearLocation('mail', 'Quadduo')
    lu.assertEquals(module:getItemLocation(123), {
        ["Quadbear-The Maelstrom"] = {
            bags = 8,
            mail = 8
        },
    })
end

os.exit(lu.LuaUnit.run())