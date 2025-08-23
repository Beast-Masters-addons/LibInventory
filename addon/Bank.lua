---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@class LibInventoryBank Manage banks which are not containers
local lib = addon:NewModule('LibInventoryBank', 'AceEvent-3.0')

---@type LibInventoryLocations
local inventory = addon:GetModule('LibInventoryLocations')

---@type BMUtils
local utils = _G.LibStub('BMUtils')

function lib:OnEnable()
    if _G['CanGuildBankRepair'] ~= nil then
        --TODO: Find better variable to check
        self:RegisterEvent('GUILDBANKFRAME_OPENED')
        self:RegisterEvent('GUILDBANKFRAME_CLOSED')
        self:RegisterEvent('GUILDBANKBAGSLOTS_CHANGED')
    end

    --if _G['CanUseVoidStorage'] then
    --    self:RegisterEvent('VOID_STORAGE_OPEN')
    --    self:RegisterEvent('VOID_STORAGE_CLOSE')
    --end
end

function lib:scanGuildBank()
    local guildName = _G.GetGuildInfo('player');
    inventory:clearLocation('guildBank', guildName)
    local numTabs = _G.GetNumGuildBankTabs()

    for tab = 1, numTabs do
        for i = 1, 14 * 7 do
            local _, itemCount = _G.GetGuildBankItemInfo(tab, i);
            if itemCount > 0 then
                local link = _G.GetGuildBankItemLink(tab, i)
                local itemID = utils.itemIdFromLink(link)
                assert(itemID, ('Unable to get item id for slot %d'):format(i))
                inventory:saveItemLocation(itemID, 'guildBank', itemCount, guildName)
            end
        end
    end
end

function lib:GUILDBANKFRAME_OPENED()
    self.atGuildBank = true
end

function lib:GUILDBANKBAGSLOTS_CHANGED(slot)
    --@debug@
    utils.basic.printf('Guild Bank slot %d changed', slot)
    --@end-debug@
    self:scanGuildBank()
end

function lib:GUILDBANKFRAME_CLOSED()
    self:scanGuildBank()
    self.atGuildBank = false
end

--[[
function events:VOID_STORAGE_OPEN()

end

function events:VOID_STORAGE_CLOSE()

end]]