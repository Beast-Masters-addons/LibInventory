---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@class LibInventoryLocations
local lib = _G['LibInventoryAce']:NewModule("LibInventoryLocations")

---@type BMUtilsBasic
local basic = _G.LibStub('BMUtilsBasic')
---@type BMUtilsCharacterInfo
local character_utils = _G.LibStub('BMUtilsCharacterInfo')

lib.location_names = {
    guildBank = _G.GUILD_BANK,
    bank = _G.BANK,
    reagentBank = _G.REAGENT_BANK,
    bags = _G.BAGSLOT,
    voidStorage = _G.VOID_STORAGE,
    mail = _G.MAIL_LABEL,
    equipment = _G.STAT_AVERAGE_ITEM_LEVEL_EQUIPPED:sub(2, -5)
}

function lib:OnInitialize()
    self.db = addon.db:RegisterNamespace("Items", {
        char = {
            bags = {},
            bank = {},
            mail = {},
            equipment = {},
        }
    })
end

function lib.subTableCheck(tableData, ...)
    --https://stackoverflow.com/questions/7183998/in-lua-what-is-the-right-way-to-handle-varargs-which-contains-nil
    for _, value in ipairs { ... } do
        if type(tableData[value]) ~= 'table' then
            tableData[value] = {}
        end
        tableData = tableData[value]
    end
end

---Save item location
---@param itemID number Item ID
---@param location string Item location (container type)
---@param quantity number Item quantity (total of all slots in the container)
---@param character string Character who owns the item (optional, defaults to the current character)
---@param realm string Realm of the character who owns the item (optional, defaults to the current realm)
function lib:saveItemLocation(itemID, location, quantity, character, realm)
    assert(itemID, 'itemID is nil')
    ---Get character string, arguments are optional and falls back to current character and realm if not set
    character = character_utils.getCharacterString(character, realm)
    assert(self.location_names[location], ('Invalid location: %s'):format(location))

    self.subTableCheck(self.db.char, location)
    if not self.db.char[location][itemID] then
        self.db.char[location][itemID] = quantity
    else
        self.db.char[location][itemID] = self.db.char[location][itemID] + quantity
    end

    self.subTableCheck(self.db.factionrealm, itemID, character)
    if not self.db.factionrealm[itemID][character][location] then
        self.db.factionrealm[itemID][character][location] = quantity
    else
        self.db.factionrealm[itemID][character][location] = self.db.factionrealm[itemID][character][location] + quantity
    end
end

--/dump _G['LibInventory'].main:getItemLocation(6948, 'Luckydime', 'Mirage Raceway')
---Get item count and which container type it is located in
function lib:getItemLocation(itemID, character, realm)
    if not self.db.factionrealm[itemID] then
        return {}
    end

    if character then
        character = character_utils.getCharacterString(character, realm)
        return self.db.factionrealm[itemID][character] or {}
    else
        return self.db.factionrealm[itemID] or {}
    end
end

---Get all items in the given location
---TODO: Broken
function lib:getLocationItems(location, character, realm)
    if character then
        error('Broken, need rewrite')
        character = character_utils.getCharacterString(character, realm)
        if not self.db.char[location] then
            --@debug@
            print(('No data for location %s on character %s'):format(location, character))
            --@end-debug@
            return
        end
        return self.db.char[location]
    else
        return self.db.char[location]
    end
end

---Clear all items from the given location
---/run LibInventoryItems.main:clearLocation('Bags')
function lib:clearLocation(location, character, realm)
    character = character_utils.getCharacterString(character, realm)
    self.db.char[location] = {}
    for itemID, characters in pairs(self.db.factionrealm) do
        for character_iter, locations in pairs(characters) do
            for location_iter, _ in pairs(locations) do
                if location_iter == location and character_iter == character then
                    self.db.factionrealm[itemID][character_iter][location_iter] = nil

                    if basic.empty(self.db.factionrealm[itemID][character_iter]) then
                        self.db.factionrealm[itemID][character_iter] = nil
                    end
                end
            end
        end
    end
end

---Clear all location for the given item
function lib:clearItem(itemID)
    --TODO: Clear all characters
    self.db.factionrealm[itemID] = nil
    for location_iter, item_iter in pairs(self.db.char) do
        if item_iter == itemID then
            self.db.char[location_iter][item_iter] = nil
        end
    end
end


--/run _G['LibInventory-@project-version@'].main:cleanItems()
--/dump LocationItems[2592]['Quadduo-MirageRaceway']
function lib:cleanItems()

    for itemID, characters in pairs(self.db.factionrealm) do
        for character_iter, locations in pairs(characters) do
            --[[            for location_iter, _ in pairs(locations) do
                        end]]
            if basic.empty(self.db.factionrealm[itemID][character_iter]) then
                --@debug@
                print(('Item %d has no locations for character %s, remove from table'):format(itemID, character_iter))
                --@end-debug@
                self.db.factionrealm[itemID][character_iter] = nil
            end
        end
        if basic.empty(self.db.factionrealm[itemID]) then
            --@debug@
            print(('No characters has item %d, remove it from table'):format(itemID))
            --@end-debug@
            self.db.factionrealm[itemID] = nil
        end
    end
end

---Get localized location name
---@param location string
function lib:locationName(location)
    return self.location_names[location] or location
end