--[[
    unrestrict.lua
    Copyright 2018 topkecleon <drew@otou.to>
    This code is licensed under the GNU AGPLv3. See /LICENSE for details.
]]--

local bindings = require('otouto.bindings')
local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('unrestrict', true):t('unmute', true):t('unban', true).table
    self.command = 'unrestrict'
    self.doc = 'Unrestrict a user.\nAliases: ' .. bot.config.cmd_pat .. 'unmute, '
        .. bot.config.cmd_pat .. 'unban'
    self.privilege = 2
    self.administration = true
    self.targeting = true
end

function P:action(bot, msg, group)
    local targets, output = autils.targets(bot, msg)
    for target in pairs(targets) do
        local name = utilities.lookup_name(bot, target)
        bindings.restrictChatMember{
            chat_id = msg.chat.id,
            user_id = target,
            can_send_other_messages = true,
            can_add_web_page_previews = true
        }
        local admin = group.data.admin
        admin.strikes[target] = nil
        if admin.bans[target] then
            admin.bans[target] = nil
            table.insert(output, name ..
                ' has been unbanned and unrestricted.')
        elseif bot.database.userdata.hammered[target] then
            table.insert(output, name .. ' is globally banned.')
        else
            table.insert(output, name .. ' has been unrestricted.')
        end
    end
    utilities.send_reply(msg, table.concat(output, '\n'), 'html')
end

return P
