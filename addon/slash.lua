---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@type LibInventoryContainer
local inventory = addon:GetModule('LibInventoryContainer')

---@type LibInventorySkillList
local skills = addon:GetModule('LibInventorySkillList')

_G.SLASH_SCANBAGS1 = "/scanbags"
_G.SlashCmdList["SCANBAGS"] = function()
    inventory:scanBags()
end

_G.SLASH_SKILLS1 = "/skills"
_G.SlashCmdList['SKILLS'] = function()
    skills:toggle()
end
