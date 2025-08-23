---@class LibInventoryCharacterObject A object with information about a character
local lib = _G['LibInventoryAce']:NewModule("LibInventoryCharacterObject")

---@type BMUtilsCharacterInfo
local character_utils = _G.LibStub('BMUtilsCharacterInfo')

---Construct the object with data
---@return LibInventoryCharacterObject
function lib.construct(data)
    setmetatable(data, lib)
    lib.__index = lib
    return data
end

---Get character class color
---@return ColorMixin
function lib:color()
    return _G.RAID_CLASS_COLORS[self.class]
end

--[[function lib:banner()
    --if self.faction
    local ALLIANCE_BANNER = 'Interface/Icons/inv_bannerpvp_02'
    local HORDE_BANNER = 'Interface/Icons/inv_bannerpvp_01'
end]]

---Get gender as string
function lib:genderString()
    return character_utils.genderString(self.gender)
end

---Get character race icon
function lib:icon()
    return character_utils.raceIcon(self.raceFile, self:genderString())
end

function lib:iconString(size, x, y)
    if size == nil then
        size = 12
    end
    local atlas, coordinates = self:icon()
    local u, v, w, z = _G.unpack(coordinates)
    return _G.CreateTextureMarkup(atlas, 128, 128, size, size, u, v, w, z, x, y)
end
