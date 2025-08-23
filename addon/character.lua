---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@class LibInventoryCharacter
local lib = _G['LibInventoryAce']:NewModule("LibInventoryCharacter")
if not lib then
    return
end

---@type LibInventoryCharacterObject
local CharacterObject = addon:GetModule('LibInventoryCharacterObject')

---@type BMUtilsBasic
local basic = _G.LibStub('BMUtilsBasic')
---@type BMUtilsText
local text = _G.LibStub('BMUtilsText')

function lib:OnInitialize()
    self.db = addon.db:RegisterNamespace('Character', {})
end

function lib:OnEnable()
    self:save()
end

---Save information about the current character
function lib:save()
    local character = _G.UnitName("player")
    self.db.realm[character] = self.currentCharacterData()
end

---Get information about the specified character
---@param realm string Realm
---@param character string Character name
---@return LibInventoryCharacterObject
function lib:load(realm, character)
    if realm ~= _G.GetRealmName() then
        text.error(('Requested realm %s is not current'):format(realm))
        return
    end

    if basic.empty(self.db.realm[character]) then
        --TODO: Do not show error for guild bank
        --utils.text.error(('No data found for character %s'):format(character))
        return
    end

    return CharacterObject.construct(self.db.realm[character])
end

---Get a CharacterData object with information about the current character
---@return LibInventoryCharacterObject
function lib.current()
    return CharacterObject.construct(lib.currentCharacterData())
end

---Get known characters
---@return table Character names
function lib:characters()
    local chars = {}
    for character_nane, _ in pairs(self.db.realm) do
        table.insert(chars, character_nane)
    end
    return chars
end

function lib.currentCharacterData()
    local o = {}

    o.money = (_G.GetMoney() or 0) - _G.GetCursorMoney() - _G.GetPlayerTradeMoney()
    o.class = select(2, _G.UnitClass('player'))
    o.race = select(2, _G.UnitRace('player'))

    --https://wow.gamepedia.com/API_UnitRace
    o.raceName, o.raceFile, o.raceID = _G.UnitRace('player')

    --https://wow.gamepedia.com/API_UnitClass
    o.className, o.classFilename, o.classId = _G.UnitClass('player')

    o.guild = _G.GetGuildInfo('player')
    o.gender = _G.UnitSex('player')
    o.name = _G.UnitName("player")
    o.realm = _G.GetRealmName()
    return o
end
