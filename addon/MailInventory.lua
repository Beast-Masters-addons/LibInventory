---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@class LibInventoryMailInventory
local lib = addon:NewModule("LibInventoryMailInventory", "AceEvent-3.0")
lib.characters = {}

---@type LibInventoryMail
local mail = addon:GetModule('LibInventoryMail')

---@type LibInventoryLocations
local inventory = addon:GetModule('LibInventoryLocations')

function lib:OnEnable()
    self:RegisterEvent('MAIL_INBOX_UPDATE')
    self:RegisterEvent("MAIL_SEND_SUCCESS")
    self.characters = self:get_characters()
    _G.SendMailMailButton:HookScript('OnClick', function()
        lib.recipient_name = _G.SendMailNameEditBox:GetText() --Save recipient name
        lib.send_items = mail:getSendAttachments()
    end)
end

function lib:get_characters()
    ---@type LibInventoryCharacter
    local characters = addon:GetModule('LibInventoryCharacter')
    for _, character in ipairs(characters:characters()) do
        self.characters[character] = true
    end
    return self.characters
end

---This event is fired when the inbox changes in any way.
---[https://warcraft.wiki.gg/wiki/MAIL_INBOX_UPDATE]
function lib:MAIL_INBOX_UPDATE()
    --@debug@
    print('Mail inbox updated')
    --@end-debug@
    self.scanMail()
end

---Save items when mail is successfully sent
function lib:MAIL_SEND_SUCCESS()
    if not self.recipient_name or not self.characters[self.recipient_name] then
        return
    end

    for itemID, itemCount in pairs(self.send_items) do
        --@debug@
        print(('Item %d sent to %s'):format(itemID, self.recipient_name))
        --@end-debug@
        local location = inventory:getItemLocation(itemID, self.recipient_name)
        if location['mail'] then
            itemCount = location['mail'] + itemCount
        end
        inventory:saveItemLocation(itemID, 'mail', itemCount, self.recipient_name)
    end
    self.recipient_name = nil
    self.send_items = nil
end

function lib.scanMail()
    inventory:clearLocation('mail')
    local mails = mail:NumMails()
    --@debug@
    print(('Scan %d mail(s)'):format(mails))
    --@end-debug@
    local items
    if mails == 0 then
        return
    end
    local mailItemCount = {}
    for mailIndex = 1, mails do
        items = mail:GetMailItems(mailIndex)
        for _, item in ipairs(items) do
            if mailItemCount[item["itemID"]] == nil then
                mailItemCount[item["itemID"]] = item["itemCount"]
            else
                mailItemCount[item["itemID"]] = mailItemCount[item["itemID"]] + item["itemCount"]
            end
        end
    end
    for itemID, itemCount in pairs(mailItemCount) do
        inventory:saveItemLocation(itemID, 'mail', itemCount)
    end
end