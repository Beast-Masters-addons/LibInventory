if _G['LibInventoryAce'] ~= nil then
    error('There should only be one instance of LibInventory')
end
local addonName = ...
---@class LibInventoryAce
local addon = _G.LibStub("AceAddon-3.0"):NewAddon("LibInventoryAce", "AceEvent-3.0")
_G['LibInventoryAce'] = addon
addon.version = '@project-version@'
addon.major, addon.minor = _G['BMUtils-Version'].parse_version(addon.version)
addon.name = addonName
addon.is_classic_era = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC

function addon:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("LibInventoryDB")
end