-- =============================================================
-- FILE: init_cloud.lua (TRÊN GITHUB)
-- =============================================================
local ChatComponent = require("GameLua.Mod.BaseMod.Common.ChatComponent")

-- Hàm thông báo ra màn hình
local function Notify(msg)
    pcall(function()
        local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if IngameTipsTools and IngameTipsTools.BattleNormalTips then
            IngameTipsTools.BattleNormalTips("Lexusmod: " .. msg, 2, 3)
        end
    end)
end

-- Hàm thực thi script tính năng chính
local function execute_main(c)
    pcall(function()
        require("GameLua.Mod.BaseMod.Client.ClientCloudGM").HandleCloudGMCMDStr("loadstring\n" .. c)
    end)
end

-- Tiến hành Hook hàm chat để đợi lệnh loadmod
if not _G.Lexus_ChatHooked then
    _G.Original_SendDirtyFilterLua = ChatComponent.SendDirtyFilterLua

    ChatComponent.SendDirtyFilterLua = function(self, DirtyString, PrefixString, UID, bNeedTranslate)
        local content = string.lower(DirtyString or "")
        
        -- Nhận diện lệnh gõ từ khung chat
        if content == "loadmod" then
            local h = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AWSHelper)
            if h then
                local scriptURL = "https://raw.githubusercontent.com/khoanguyennoob/luascript/refs/heads/main/script.lua?t=" .. os.time()
                h:DownloadBinary(scriptURL, function(r)
                    if r:IsOK() then
                        execute_main(r:GetContent())
                        Notify("Script đã kích hoạt thành công!")
                    end
                end)
            end
            return -- Chặn không cho tin nhắn gửi đi
        end
        
        return _G.Original_SendDirtyFilterLua(self, DirtyString, PrefixString, UID, bNeedTranslate)
    end
    
    _G.Lexus_ChatHooked = true
    Notify("Hệ thống Cloud sẵn sàng! Gõ 'loadmod'")
end
