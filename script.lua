-- =============================================================
-- FILE TRÊN GITHUB: ZERO-HOOK SCANNER (KHÔNG TRÁO HÀM GỐC)
-- =============================================================
local function Notify(msg)
    pcall(function()
        local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if IngameTipsTools and IngameTipsTools.BattleNormalTips then
            IngameTipsTools.BattleNormalTips("Lexusmod: " .. msg, 2, 4)
        end
    end)
end

-- Bộ quét dữ liệu thuần túy (Chỉ đọc, không ghi đè)
local function ZeroHookScanner()
    pcall(function()
        local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
        if not s or not GameplayData then return end
        
        local PC = GameplayData.GetPlayerController()
        if not slua.isValid(PC) then return end
        
        local ChatComp = PC:GetChatComponent()
        if not slua.isValid(ChatComp) then return end
        
        -- LẤY DỮ LIỆU TIN NHẮN MỚI NHẤT TRONG GAME
        -- (Dựa theo đúng cấu trúc ở dòng 123 file QuickMenu của bạn)
        local currentMsg = string.lower(tostring(ChatComp.CurrMsg or ""))
        
        -- NẾU THẤY CHỮ LOADMOD VÀ CHƯA TỪNG CHẠY TRƯỚC ĐÓ
        if string.find(currentMsg, "loadmod") and _G.Lexus_LastMsg ~= currentMsg then
            
            -- Lưu lại để ngăn vòng lặp chạy script tải về liên tục
            _G.Lexus_LastMsg = currentMsg 
            
            Notify("Đã đọc thấy lệnh! Đang kéo Script...")
            
            local AWSHelper = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AWSHelper)
            if AWSHelper then
                local URL = "https://raw.githubusercontent.com/khoanguyennoob/luascript/refs/heads/main/script.lua?t=" .. os.time()
                AWSHelper:DownloadBinary(URL, function(res)
                    if res:IsOK() then
                        -- Thực thi Code Mod
                        pcall(function() 
                            require("GameLua.Mod.BaseMod.Client.ClientCloudGM").HandleCloudGMCMDStr("loadstring\n" .. res:GetContent()) 
                        end)
                        
                        -- Hẹn 2 giây báo thành công
                        require("common.time_ticker").AddTimerOnce(2, function() 
                            Notify("Kích hoạt hoàn tất!") 
                        end)
                    end
                end)
            end
        end
    end)
    
    -- Lặp lại việc "nhìn lén" dữ liệu mỗi 0.5 giây
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.5, ZeroHookScanner)
end

-- Kích hoạt bộ quét (Đảm bảo chỉ chạy 1 luồng duy nhất)
if not _G.Lexus_Scanner_Running then
    _G.Lexus_Scanner_Running = true
    pcall(ZeroHookScanner)
    Notify("Hệ thống Không-Hook đã chạy! Hãy gõ 'loadmod'")
end
