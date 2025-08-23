---@class LibInventoryMail Library to send and extract items from mail
local mail = _G['LibInventoryAce']:NewModule('LibInventoryMail', 'AceEvent-3.0')

---@type BMUtilsCharacterInfo
local character_utils = _G.LibStub('BMUtilsCharacterInfo')
---@type BMUtilsText
local text_utils = _G.LibStub('BMUtilsText')

mail.mail_open = false
mail.attachment_key = 1
mail.items = {}

---Set mail recipient
---@param recipient string Mail recipient
function mail:recipient(recipient)
    local character, realm = character_utils.splitCharacterString(recipient)
    if realm == _G.GetRealmName() then
        recipient = character
    end
    _G.SendMailNameEditBox:SetText(recipient)
end

--- Add money to a mail
---@param amount number Copper amount to be added
function mail:money(amount)
    _G.SetSendMailMoney(amount)
    self.money = amount
end

---Set cash on delivery
---@param amount number COD copper amount
function mail:cod(amount)
    _G.SetSendMailCOD(amount)
    self.cod = amount
end

function mail:send(target, subject, body)
    --https://warcraft.wiki.gg/wiki/API_SendMail
    _G.SendMail(target, _G.SendMailSubjectEditBox:GetText() or subject or "", body or "")
    self.body = body
    self.subject = subject
end

---Add item as attachment to the current mail
---@param bag number Bag id
---@param slot number Slot inside the bag (top left slot is 1, slot to the right of it is 2)
---@param key number The index of the item (1-ATTACHMENTS_MAX_SEND(12))
function mail:AddAttachment(bag, slot, key)
    --@debug@
    local itemInfo = _G.C_Container.GetContainerItemInfo(bag, slot)
    text_utils.cprint(('Attach item %s from container %d slot %d to %d'):format(
            itemInfo['hyperlink'], bag, slot, self.attachment_key), 1, 1, 0)
    --@end-debug@
    --https://warcraft.wiki.gg/wiki/API_PickupContainerItem
    _G.C_Container.PickupContainerItem(bag, slot)
    _G.ClickSendMailItemButton(key or self.attachment_key)
    self.attachment_key = self.attachment_key + 1
end

function mail:NumMails()
    local numItems, totalItems = _G.GetInboxNumItems()
    self.mail_count = numItems
    self.mail_total = totalItems
    return numItems
end

--/dump LibInventoryMail:GetMailItems(2)
function mail:GetMailItems(mailIndex)
    local mailItems = {}
    local hasItem = select(8, _G.GetInboxHeaderInfo(mailIndex))

    if hasItem == nil then
        return {}
    end
    local itemInfo, itemLink
    for itemIndex = 1, _G.ATTACHMENTS_MAX_RECEIVE, 1 do
        local _, itemID, itemTexture, count, quality, _ = _G.GetInboxItem(mailIndex, itemIndex)
        if itemID then

            itemLink = _G.GetInboxItemLink(mailIndex, itemIndex)
            itemInfo = { ["icon"] = itemTexture, ["itemCount"] = count, ["quality"] = quality,
                         ["itemLink"] = itemLink, ["itemID"] = itemID }
            table.insert(mailItems, itemInfo)
        end
    end
    self.items[mailIndex] = mailItems
    return mailItems
end

---Get items attached to an outgoing mail
---Multiple item stacks are summarized
---@return table ItemID and item count
function mail:getSendAttachments()
    local items = {}
    -- Based on code snippet from https://warcraft.wiki.gg/wiki/API_GetSendMailItem
    for i = 1, _G.ATTACHMENTS_MAX_SEND do
        local name, itemID, texture, count = _G.GetSendMailItem(i)
        if itemID then
            --@debug@
            print("You are sending", "\124T" .. texture .. ":0\124t", name, "x", count)
            --@end-debug@
            if items[itemID] == nil then
                items[itemID] = count
            else
                items[itemID] = items[itemID] + count
            end
        end
    end
    return items
end


--/dump LibInventoryMail:GetItem(1081, "Quadduo")
function mail:GetItem(itemID, character)
    character = character_utils.getCharacterString(character)
    if _G.MailItems[character][itemID] ~= nil and _G.MailItems[character][itemID] > 0 then
        return _G.MailItems[character][itemID]
    end
end

function mail:attachments(attachments, positions)
    local position
    for key, itemID in ipairs(attachments) do
        position = positions[itemID]
        if position then
            --@debug@
            print(('Attach itemID %s as attachment %d from container %d slot %d'):format(
                    itemID, key, position["bag"], position["slot"]))
            --@end-debug@
            _G.C_Container.PickupContainerItem(position["bag"], position["slot"])
            _G.ClickSendMailItemButton(key)
        end
    end
end

--Event handling
function mail:OnEnable()
    --https://warcraft.wiki.gg/wiki/Events#C_Mail
    self:RegisterEvent("MAIL_SEND_SUCCESS")
    self:RegisterEvent("MAIL_SHOW")
    self:RegisterEvent("MAIL_CLOSED")
end

function mail:MAIL_SHOW()
    self.mail_open = true
end

function mail:MAIL_CLOSED()
    self.mail_open = false
    _G.ClearCursor()
end

function mail:MAIL_SEND_SUCCESS()
    self.attachment_key = 1
end

_G.SendMailFrame:HookScript('OnHide', function()
    mail.attachment_key = 1
end)