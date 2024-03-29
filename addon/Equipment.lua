---@type LibInventory
local _, addon = ...
if not addon.equipment then
    return
end

---@class LibInventoryEquipment
local lib = {}
addon.equipment = lib
lib.addon = addon

function lib:scanEquipment()
    --https://www.townlong-yak.com/framexml/9.0.2/Constants.lua#192
    self.addon.main:clearLocation('equipment')
    local link, itemID
    for slot = 0, 19 do
        link = _G.GetInventoryItemLink("player", slot)
        if link ~= nil then
            itemID = self.addon.utils.itemIdFromLink(link)
            self.addon.main:saveItemLocation(itemID, 'equipment', 1)
        end
    end
end