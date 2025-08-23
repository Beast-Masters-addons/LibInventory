loadfile('../build/build_utils/utils/load_toc.lua')('./test.toc')
---@type LibInventoryAce
local addon = _G.LibStub('AceAddon-3.0'):GetAddon('LibInventoryAce')

---@type LibInventoryEquipment
local module = addon:GetModule('LibInventoryEquipment')

---@type LibInventoryLocations
local inventory = addon:GetModule('LibInventoryLocations')

local lu = require('luaunit')
_G['test'] = {}
local test = _G['test']

function test.setUp()
    addon:OnInitialize()
    inventory:OnInitialize()
    addon.db:ResetDB()
end

function test:testEquipment()
    module:scanEquipment()
    local items = inventory:getLocationItems('equipment')
    lu.assertEquals(items[9859], 1)
end

os.exit(lu.LuaUnit.run())