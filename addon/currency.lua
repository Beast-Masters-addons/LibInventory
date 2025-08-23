---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@class LibInventoryCurrency
local lib = _G['LibInventoryAce']:NewModule("LibInventoryCurrency", "AceEvent-3.0")

function lib:OnInitialize()
    self.db = addon.db:RegisterNamespace('Currency')
    self.db_global = _G['LibInventoryDB']['namespaces']['Currency']['char']
end

function lib:OnEnable()
    self:RegisterEvent('PLAYER_MONEY')
    self.name = _G.UnitName("player")
    --@debug@
    print(('Loaded money %d'):format(self.db.char['money']))
    --@end-debug@
    self:saveMoney()
end

function lib:PLAYER_MONEY()
    self:saveMoney()
end

function lib:saveMoney()
    --@debug@
    print(('Save money %d for %s'):format(_G.GetMoney(), self.name))
    --@end-debug@
    self.db.char['money'] = _G.GetMoney()
end

function lib:getMoney(character, realmKey)
    if not character then
        return self.db.char['money']
    else
        if not realmKey then
            realmKey = _G.GetRealmName()
        end
        local charKey = character .. " - " .. realmKey
        if not self.db_global[charKey] then
            return
        end
        return self.db_global[charKey]['money']
    end
end