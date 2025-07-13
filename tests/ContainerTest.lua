loadfile('../build/build_utils/utils/load_toc.lua')('./test.toc')
---@type LibInventoryAce
local addon = _G.LibStub("AceAddon-3.0"):GetAddon("LibInventoryAce")

---@type LibInventoryContainer
local container = addon:GetModule("LibInventoryContainer")

---@type LibInventoryLocations
local inventory = addon:GetModule('LibInventoryLocations')

local lu = require('luaunit')
_G['test'] = {}
local test = _G['test']

function test.setUp()
    addon:OnInitialize()
    inventory:OnInitialize()
end

if GetContainerNumSlots ~= nil then
    function test:testFreeSlots()
        lu.assertEquals(GetContainerNumSlots(1), 16, 'Wrong global API dummy used')
    end
end

function test:testFreeSlotsNamespace()
    lu.assertEquals(C_Container.GetContainerNumSlots(1), 16, 'Wrong namespaced API dummy used')
end

function test:testGetMultiContainerItems()
    local items = container:getMultiContainerItems(0, 4)
    --DevTools_Dump(items)
    lu.assertEquals(items[19316], 3596 + 3200 + 600)
end

function test:testScanAllBags()
    container:scanBags()
    local items = inventory:getItemLocation(19316)
    local items_check = {
        ["Quadduo-Mirage Raceway"] = {
            bags = 3596 + 3200 + 600
        }
    }

    lu.assertEquals(items, items_check)
end

--[[function test:testScanSingleBag()

    container:scanContainers(4, 4, 'bags')
    local items = inventory:getItemLocation(19316)
    local items_check = {
        ["Quadduo-Mirage Raceway"] = {
            bags = 3596 + 3200 + 600
        }
    }

    lu.assertEquals(items, items_check)
end]]

os.exit(lu.LuaUnit.run())