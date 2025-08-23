---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@class LibInventorySkills
local lib = _G['LibInventoryAce']:NewModule('LibInventorySkills', 'AceEvent-3.0')

---@type LibProfessions:LibProfessionsCommon
local professions = _G.LibStub('LibProfessions-0')
local profession = professions.currentProfession
---@type BMUtilsTable
local table_utils = _G.LibStub('BMUtilsTable')
---@type BMUtilsBasic
local basic =  _G.LibStub('BMUtilsBasic')
---@type BMUtilsText
local text_utils =  _G.LibStub('BMUtilsText')

function lib:OnInitialize()
    self.db = addon.db:RegisterNamespace('Skills')
    self.db_global = _G['LibInventoryDB']['namespaces']['Skills']['char']
    _G['SkillDB'] = self.db_global
    self:saveSkills()
    if not self.db.char['skillLevel'] then
        self.db.char['skillLevel'] = {}
    end
end

function lib:OnEnable()
    if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_MAINLINE then
        self:RegisterEvent('TRADE_SKILL_UPDATE')
    end
    self:RegisterEvent('TRADE_SKILL_SHOW')
    self:RegisterEvent('TRADE_SKILL_CLOSE')
    self:RegisterEvent('NEW_RECIPE_LEARNED')
    self:RegisterEvent('CONSOLE_MESSAGE')
end

function lib:professionInfo()
    local skill = {}
    skill['professionName'],
    skill['skill'],
    skill['maxSkill'],
    skill['skillModifier'],
    skill['professionID'] = professions.api.GetInfo()
    return skill
end

function lib:saveRecipes()
    local recipes = profession:GetRecipes()

    local professionName, skill, maxSkill = professions.api.GetInfo()
    --[[    self.db.char[professionName]['skill'] = skill
        self.db.char[professionName]['maxSkill'] = maxSkill]]
    table_utils.subTableCheck(self.db.char, professionName, 'recipes')
    --@debug@
    print(('Save recipes for %s'):format(professionName))
    --@end-debug@
    for recipeID, recipe in pairs(recipes) do
        if recipeID ~= nil and recipe ~= nil then
            self.db.char[professionName]['recipes'][recipeID] = recipe['recipeId']
        end
    end
end

function lib:TRADE_SKILL_SHOW()
    self:saveRecipes()
end

function lib:TRADE_SKILL_CLOSE()
    --Update skill
    self:saveSkills()
end

function lib:TRADE_SKILL_UPDATE()
    --self:saveRecipes()
end

function lib:NEW_RECIPE_LEARNED(event, arg1)
    local spellId = arg1
    self:saveRecipes()
end

function lib:CONSOLE_MESSAGE(_, message, colorType)
    local skill, from, to = message:match('Skill (%d+) increased from (%d+) to (%d+)')
    if not skill then
        return
    end
    --print(('Console message: Skill %d increased to %d'):format(skill, to))
    self.db.char['skillLevel'][tonumber(skill)] = tonumber(to)
end

--/dump LibInventoryAce:GetModule('LibInventorySkills'):getSkill("Herbalism")
function lib:getSkill(skillName)
    local skillLineId = professions.getSkillLineID(skillName)
    return self.db.char['skillLevel'][skillLineId]
end

function lib:saveSkills()
    if _G['GetNumSkillLines'] == nil then
        return --Retail has no skills, only professions
    end
    local headerName
    local numSkills = _G.GetNumSkillLines();
    for skillIndex = 1, numSkills, 1 do
        local skillName, header, _, skillRank, numTempPoints,
        skillModifier, skillMaxRank = _G.GetSkillLineInfo(skillIndex);

        if (header) then
            headerName = skillName
        else
            self.db.char[skillName] = {
                skillName = skillName,
                skillRank = skillRank,
                numTempPoints = numTempPoints,
                skillModifier = skillModifier,
                skillMaxRank = skillMaxRank,
                category = headerName
            }
            if headerName .. ':' == _G.SECONDARY_SKILLS or headerName == _G.TRADE_SKILLS then
                local name, rank, icon, _, _, _, spellID, originalIcon = _G.GetSpellInfo(skillName)
                self.db.char[skillName]['spell'] = {
                    name = name,
                    rank = rank,
                    icon = icon,
                    spellID = spellID,
                    originalIcon = originalIcon,
                }
                self.db.char[skillName]['recipes'] = {}
            end
        end
    end
end

function lib:getSkills(category)
    local skills = {}
    for _, skill in pairs(self.db.char) do
        if category == nil or skill['category'] == category then
            table.insert(skills, skill)
        end
    end
    return skills
end

--/dump LibInventoryAce:GetModule('LibInventorySkills'):getCharacterSkills()
function lib:getCharacterSkills(character, realmKey)
    local character_temp, charKey
    if not character then
        return self.db.char
    else
        if not realmKey then
            character_temp, realmKey = string.match(character, '^(.-)%s-%s(.+)$')
            if not realmKey then
                realmKey = _G.GetRealmName()
            else
                charKey = character
                character = character_temp
            end
        else
            charKey = character .. " - " .. realmKey
        end

        if basic.empty(self.db_global[charKey]) then
            --@debug@
            text_utils.error(('No skills found for character %s'):format(character))
            --@end-debug@
        end
        return self.db_global[charKey]
    end
end
