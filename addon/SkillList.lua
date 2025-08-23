---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@class LibInventorySkillList
local lib = _G['LibInventoryAce']:NewModule('LibInventorySkillList')

---@type LibInventorySkills
local skills = addon:GetModule('LibInventorySkills')

function lib:characters()
    local chars = {}
    for char, _ in pairs(skills.db_global) do
        table.insert(chars, char)
    end
    return chars
end

function lib:OnEnable()
    self.gui = _G.LibStub('AceGUI-3.0')
    self.skillGroupFrames = {}
end

function lib:toggle()
    if self.visible then
        self:hide()
    else
        self:show()
    end
end

function lib:hide()
    self.gui:Release(self.frame)
    self.selectedChar = nil
    self.visible = false
end

function lib:show()
    self.visible = true
    local AceGUI = self.gui
    local f = AceGUI:Create('Window')
    self.frame = f
    f:SetCallback('OnClose', function()
        lib:hide()
    end)
    f:SetTitle('Character skills')
    --f:SetStatusText('Status Bar')
    f:SetLayout('Flow')
    f:SetWidth(350)

    local dropdown = AceGUI:Create('Dropdown')
    for _, character in pairs(self:characters()) do
        local characterName, _ = string.match(character, '^(.-)%s-%s(.+)$')
        dropdown:AddItem(character, characterName)
    end

    dropdown:SetCallback('OnValueChanged', function(self2, _, character)
        lib:releaseSkillGroups()
        lib:show_skills(character)
        self2:SetValue(character)
    end)

    f:AddChild(dropdown)

end

function lib:group_skills(character)
    local count = 0
    local groups = {}
    local character_skills = skills:getCharacterSkills(character)
    for skillName, skill in pairs(character_skills) do
        if skill['category'] ~= nil then
            if groups[skill['category']] == nil then
                groups[skill['category']] = {}
            end
            groups[skill['category']][skillName] = skill
            count = count + 1
        end
    end
    return groups, count
end

function lib:releaseSkillGroups()
    for group, frame in pairs(self.skillGroupFrames) do
        self.skillFrame:ReleaseChildren(frame)
        self.skillGroupFrames[group] = nil
    end
end

function lib:showSkillGroup(character, skillGroup)
    local skill_groups = self:group_skills(character)
    assert(skill_groups[skillGroup], ('Skill group %s not found'):format(skillGroup))

    self.skillGroupFrames[skillGroup] = self.gui:Create('InlineGroup')
    local group = self.skillGroupFrames[skillGroup]
    group:SetTitle(skillGroup)
    --local header_obj = self.gui:Create('Heading')
    --header_obj:SetText(header)
    self.skillFrame:AddChild(group)

    for skillName, skill in pairs(skill_groups[skillGroup]) do
        local label = self.gui:Create('Label')
        label:SetText(('%s: %d'):format(skillName, skill['skillRank']))
        if skill['spell'] then
            label:SetImage(skill['spell']['icon'])
        end
        group:AddChild(label)
    end
end

function lib:show_skills(character)
    if self.selectedChar ~= nil then
        self.gui:Release(self.frame)
        self:show()
    end

    self.skillFrame = self.gui:Create('SimpleGroup')
    self.frame:AddChild(self.skillFrame)
    self.selectedChar = character

    for _, skillGroup in ipairs({ 'Professions', 'Secondary Skills' }) do
        self:showSkillGroup(character, skillGroup)
    end
end

function _G.skill_list()
    return lib:show()
end

function lib:add_tree()
    local tree = {
        {
            value = 'A',
            text = 'Alpha',
            icon = 'Interface\\Icons\\INV_Drink_05',
        },
        {
            value = 'B',
            text = 'Bravo',
            children = {
                {
                    value = 'C',
                    text = 'Charlie',
                },
                {
                    value = 'D',
                    text = 'Delta',
                    children = {
                        {
                            value = 'E',
                            text = 'Echo'
                        }
                    }
                }
            }
        },
        {
            value = 'F',
            text = 'Foxtrot',
            disabled = true,
        },
    }

    local container = self.gui:Create('TreeGroup')
    container:SetTree(tree)
    self.frame:AddChild(container)

end