-- =============================================================
-- FILE: init_cloud.lua (TRÊN GITHUB) - PHIÊN BẢN MÁY X-QUANG
-- =============================================================
local ChatComponent = require("GameLua.Mod.BaseMod.Common.ChatComponent")

local function Notify(msg)
    pcall(function()
        local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if IngameTipsTools and IngameTipsTools.BattleNormalTips then
            -- Tăng thời gian hiện lên 4 giây để dễ đọc
            IngameTipsTools.BattleNormalTips("Lexus Debug: " .. msg, 2, 4)
        end
    end)
end

if not _G.Lexus_ChatHooked then
    _G.Original_SendDirtyFilterLua = ChatComponent.SendDirtyFilterLua

    ChatComponent.SendDirtyFilterLua = function(self, DirtyString, PrefixString, UID, bNeedTranslate)
        -- Ép kiểu chuỗi an toàn tuyệt đối
        local raw_content = tostring(DirtyString or "")
        local lower_content = string.lower(raw_content)
        
        -- MÁY X-QUANG: In ra màn hình CHÍNH XÁC những gì game nhận được
        Notify("Bạn vừa gõ: [" .. raw_content .. "]")
        
        if string.find(lower_content, "loadmod") then
            Notify("BẮT TRÚNG LỆNH! Đang kéo Script...")
            local h = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AWSHelper)
            if h then
                local scriptURL = "https://raw.githubusercontent.com/khoanguyennoob/luascript/refs/heads/main/script.lua?t=" .. os.time()
                h:DownloadBinary(scriptURL, function(res)
                    if res:IsOK() then
                        pcall(function()
                            require("GameLua.Mod.BaseMod.Client.ClientCloudGM").HandleCloudGMCMDStr("loadstring\n" .. res:GetContent())
                        end)
                        
                        local time_ticker = require("common.time_ticker")
                        time_ticker.AddTimerOnce(2, function()
                            Notify("Script chạy thành công!")
                        end)
                    else
                        Notify("Lỗi tải link Github (Script chính)!")
                    end
                end)
            end
            return 
        end
        
        return _G.Original_SendDirtyFilterLua(self, DirtyString, PrefixString, UID, bNeedTranslate)
    end
    
    _G.Lexus_ChatHooked = true
    Notify("Máy X-Quang đã bật! Thử gõ số 123 xem sao!")
end
