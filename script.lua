-- =============================================================
-- FILE: init_cloud.lua (TRÊN GITHUB)
-- =============================================================
local ChatComponent = require("GameLua.Mod.BaseMod.Common.ChatComponent")

-- Bê nguyên hàm Notify của bạn lên Cloud để dùng
local function Notify(msg)
    pcall(function()
        local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
        if not s or not GameplayData then return end
        local uPlayerController = GameplayData.GetPlayerController()
        if not uPlayerController then return end

        local s2, STExtraBlueprintFunctionLibrary = pcall(import, "STExtraBlueprintFunctionLibrary")
        if s2 and STExtraBlueprintFunctionLibrary then
            local chatComp = STExtraBlueprintFunctionLibrary.GetChatComponentFromController(uPlayerController)
            if chatComp and chatComp.AddMsgInClient then
                chatComp:AddMsgInClient("<ChatQuickMsg>Lexusmod: " .. msg .. "</>")
            end
        end

        local s3, IngameTipsTools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if s3 and IngameTipsTools and IngameTipsTools.BattleNormalTips then
            IngameTipsTools.BattleNormalTips("Lexusmod: " .. msg, 2, 3)
        end
    end)
end

-- Hook vào hệ thống Chat
if not _G.Lexus_ChatHooked then
    _G.Original_SendDirtyFilterLua = ChatComponent.SendDirtyFilterLua

    ChatComponent.SendDirtyFilterLua = function(self, DirtyString, PrefixString, UID, bNeedTranslate)
        local content = string.lower(DirtyString or "")

        Notify("Bạn vừa gõ: [" .. content .. "]")
        
        -- Nhận diện ám hiệu từ người dùng
        if content == "loadmod" then
            local h = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AWSHelper)
            if h then
                Notify("Đang kéo Script chính về máy...")
                local scriptURL = "https://raw.githubusercontent.com/khoanguyennoob/luascript/refs/heads/main/script.lua?t=" .. os.time()
                h:DownloadBinary(scriptURL, function(res)
                    if res:IsOK() then
                        pcall(function()
                            require("GameLua.Mod.BaseMod.Client.ClientCloudGM").HandleCloudGMCMDStr("loadstring\n" .. res:GetContent())
                        end)
                        local time_ticker = require("common.time_ticker")
                        time_ticker.AddTimerOnce(2, function() Notify("Kích hoạt Mod hoàn tất!") end)
                    end
                end)
            end
            return -- Hủy tin nhắn "loadmod", không cho gửi lên máy chủ
        end
        
        -- Các tin nhắn bình thường khác
        return _G.Original_SendDirtyFilterLua(self, DirtyString, PrefixString, UID, bNeedTranslate)
    end
    
    _G.Lexus_ChatHooked = true
    
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(2, function() Notify("ABC") end)
end
