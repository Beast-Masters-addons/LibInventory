loadfile('../build_utils/utils/load_toc.lua')('./test.toc')
loadfile('container_data.lua')()
---@type LibInventoryAce
local addon = _G.LibStub("AceAddon-3.0"):GetAddon("LibInventoryAce")

---@type LibInventoryCurrency
local module = addon:GetModule('LibInventoryCurrency')

local lu = require('luaunit')
_G['test'] = {}
local test = _G['test']

function test.setUp()

end

function test:testMoney()
    addon:OnInitialize()
    module:OnInitialize()
    module:saveMoney()
    local money = module:getMoney()
    lu.assertEquals(money, 62993)
end

function test:testMoneyDifferentChar()
    _G['LibInventoryDB']['namespaces']['Currency']['char']['Test - Mirage Raceway'] = { ['money'] = 55 }
    addon:OnInitialize()
    module:OnInitialize()
    module:saveMoney()
    lu.assertEquals(module:getMoney(), 62993)
    lu.assertEquals(module:getMoney('Test'), 55)
end

function test:testMoneyDifferentRealm()
    _G['LibInventoryDB']['namespaces']['Currency']['char']['Test - Mirage'] = { ['money'] = 55 }
    addon:OnInitialize()
    module:OnInitialize()
    module:saveMoney()
    lu.assertEquals(module:getMoney(), 62993)
    lu.assertEquals(module:getMoney('Test', 'Mirage'), 55)
end

os.exit(lu.LuaUnit.run())