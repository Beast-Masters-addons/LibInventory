---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@class LibInventoryEquipment
local lib = addon:NewModule('LibInventoryEquipment', 'AceEvent-3.0')

---@type BMUtils
local utils = _G.LibStub('BMUtils')

---@type LibInventoryLocations
local inventory = addon:GetModule('LibInventoryLocations')

function lib:OnEnable()
    self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
end

---Scan equipped items
--- [https://www.townlong-yak.com/framexml/9.0.2/Constants.lua#192]
function lib.scanEquipment()
    inventory:clearLocation('equipment')
    local link, itemID
    for slot = 0, 19 do
        link = _G.GetInventoryItemLink('player', slot)
        if link ~= nil then
            itemID = utils.itemIdFromLink(link)
            inventory:saveItemLocation(itemID, 'equipment', 1)
        end
    end
end

function lib:PLAYER_EQUIPMENT_CHANGED()
    self.scanEquipment()
end