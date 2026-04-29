-- =============================================================
-- LEXUSMOD: SYSTEM INITIALIZER & CHAT HOOK
-- =============================================================

-- 1. Hàm Thông báo (Notify) - Giữ nguyên logic của bạn nhưng tối ưu gọi một lần
local function Notify(msg)
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not s or not GameplayData then return end
    local uPlayerController = GameplayData.GetPlayerController()
    if not uPlayerController then return end

    -- Thông báo trong khung chat
    local s2, STExtraBlueprintFunctionLibrary = pcall(import, "STExtraBlueprintFunctionLibrary")
    if s2 and STExtraBlueprintFunctionLibrary then
        local chatComp = STExtraBlueprintFunctionLibrary.GetChatComponentFromController(uPlayerController)
        if chatComp and chatComp.AddMsgInClient then
            chatComp:AddMsgInClient("<ChatQuickMsg>Lexusmod: " .. msg .. "</>")
        end
    end

    -- Hiển thị Tip giữa màn hình
    local s3, IngameTipsTools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    if s3 and IngameTipsTools and IngameTipsTools.BattleNormalTips then
        IngameTipsTools.BattleNormalTips("Lexusmod: " .. msg, 2, 3)
    end
end

-- 2. Hàm thực thi mã lệnh từ Cloud
local function ex(c)
    if not c or c == "" then return end
    pcall(function()
        local CloudGM = require("GameLua.Mod.BaseMod.Client.ClientCloudGM")
        CloudGM.HandleCloudGMCMDStr("loadstring\n" .. c)
    end)
end

-- 3. LOGIC HOOK HÀM SendDirtyFilterLua
local function InstallChatHook()
    local s, ChatComponent = pcall(require, "GameLua.Mod.BaseMod.Common.ChatComponent")
    if not s or not ChatComponent then return end

    -- Chỉ Hook nếu chưa có bản lưu gốc (Chống lặp Hook gây tràn bộ nhớ)
    if not _G.Original_SendDirtyFilterLua then
        _G.Original_SendDirtyFilterLua = ChatComponent.SendDirtyFilterLua

        -- Ghi đè hàm của Game
        ChatComponent.SendDirtyFilterLua = function(self, DirtyString, PrefixString, UID, bNeedTranslate)
            local content = string.lower(DirtyString or "")
            
            -- NHẬN DIỆN LỆNH LOADMOD
            if string.find(content, "loadmod") then
                local AWSHelper = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AWSHelper)
                if AWSHelper then
                    -- Phá cache bằng os.time()
                    local URL = "https://raw.githubusercontent.com/khoanguyennoob/luascript/refs/heads/main/script.lua?t=" .. os.time()
                    AWSHelper:DownloadBinary(URL, function(res)
                        if res:IsOK() then
                            ex(res:GetContent())
                            Notify("Script đã được cập nhật từ Cloud!")
                        end
                    end)
                end
                return -- Chặn tin nhắn này, không gửi lên Server
            end

            -- Nếu không phải lệnh, trả về hàm gốc để chat bình thường
            return _G.Original_SendDirtyFilterLua(self, DirtyString, PrefixString, UID, bNeedTranslate)
        end
        
        Notify("Trạm gác Chat đã sẵn sàng!")
    end
end

-- Kích hoạt hệ thống
pcall(InstallChatHook)
