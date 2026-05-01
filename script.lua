-- =============================================================
-- FILE TRÊN GITHUB: LEXUSMOD RAM SCANNER HOOK
-- Tuyệt đối không cần chạm vào file Local
-- =============================================================

local function Notify(msg)
    pcall(function()
        local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if IngameTipsTools and IngameTipsTools.BattleNormalTips then
            IngameTipsTools.BattleNormalTips("Lexusmod: " .. msg, 2, 3)
        end
    end)
end

-- Máy quét bộ nhớ: Tìm và Hack class QuickMenu
local function ScanAndHookRAM()
    local isHooked = false
    
    -- Duyệt toàn bộ package.loaded (Bộ nhớ đệm chứa tất cả các file Lua đã được game nạp)
    for key, module in pairs(package.loaded) do
        
        -- Dấu hiệu nhận diện class QuickMenu: Là Table và chứa hàm SendTeamChat
        if type(module) == "table" and type(module.SendTeamChat) == "function" and type(module.OnSendTeamClicked) == "function" then
            
            if not module.Lexus_Hooked then
                -- Lưu lại hàm gốc trên RAM
                local Org_SendTeamChat = module.SendTeamChat
                
                -- Đè hàm mới trực tiếp vào RAM
                module.SendTeamChat = function(self, Text)
                    local content = string.lower(Text or "")
                    
                    -- NHẬN DIỆN LỆNH LOADMOD TRONG TRẬN
                    if string.find(content, "loadmod") then
                        Notify("Bắt được lệnh! Đang kéo Script...")
                        
                        local AWSHelper = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AWSHelper)
                        if AWSHelper then
                            local URL = "https://raw.githubusercontent.com/khoanguyennoob/luascript/refs/heads/main/script.lua?t=" .. os.time()
                            AWSHelper:DownloadBinary(URL, function(res)
                                if res:IsOK() then
                                    pcall(function()
                                        require("GameLua.Mod.BaseMod.Client.ClientCloudGM").HandleCloudGMCMDStr("loadstring\n" .. res:GetContent())
                                    end)
                                    
                                    local time_ticker = require("common.time_ticker")
                                    time_ticker.AddTimerOnce(2, function()
                                        Notify("Kích hoạt Mod hoàn tất!")
                                    end)
                                end
                            end)
                        end
                        
                        -- Đóng giao diện Chat và xóa chữ cho gọn
                        pcall(function()
                            if self.UIRoot and self.UIRoot.inputText then
                                self.UIRoot.inputText:SetText("")
                            end
                            local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
                            local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
                            if MainControlBaseUI then MainControlBaseUI:HideQuickChatMenu() end
                        end)
                        
                        return -- HỦY GỬI TIN NHẮN
                    end
                    
                    -- Nếu không phải lệnh loadmod, trả về chat bình thường
                    return Org_SendTeamChat(self, Text)
                end
                
                module.Lexus_Hooked = true
                Notify("Đã cấy Hook thành công vào QuickMenu!")
            end
            
            isHooked = true
            break -- Đã tìm thấy và Hook xong, thoát vòng lặp
        end
    end
    
    return isHooked
end

-- Vòng lặp ngầm: Chờ đến khi game thực sự load QuickMenu vào RAM
local function StartDaemon()
    -- Nếu chưa tìm thấy QuickMenu (do đang ở Sảnh, game chưa load giao diện Trong trận)
    if not pcall(ScanAndHookRAM) or not ScanAndHookRAM() then
        -- Hẹn 2 giây sau quét RAM lại một lần
        local time_ticker = require("common.time_ticker")
        time_ticker.AddTimerOnce(2, StartDaemon)
    end
end

-- Kích hoạt hệ thống ngay khi file Github được load
pcall(StartDaemon)
Notify("Radar đang dò tìm giao diện In-game...")
