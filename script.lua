local function Notify(msg)
    pcall(function()
        local ChatComponent = require("GameLua.Mod.BaseMod.Common.ChatComponent")
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

Notify("Hệ thống Mod đang khởi động...")

-- Hàm Mod súng
local function ApplyWeaponMod()
    -- Bỏ tham số PlayerRef đi vì không còn dùng tới
    -- Lấy tham chiếu Player
    Notify("Đã chạy function!")
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not s or not GameplayData then return end
    
    local LocalPlayer = GameplayData.GetPlayerCharacter()

    if not slua.isValid(LocalPlayer) then return end
    
    -- SỬ DỤNG DẤU HAI CHẤM (:) 
    local WeaponManager = LocalPlayer:GetWeaponManager()
    if not slua.isValid(WeaponManager) then return end
    
    -- SỬ DỤNG DẤU HAI CHẤM (:) 
    local CurrentWeapon = LocalPlayer:GetCurrentShootWeapon()
    if slua.isValid(CurrentWeapon) then
        
        -- Lấy Component an toàn
        local shootComp = CurrentWeapon.ShootWeaponComponent
        if not slua.isValid(shootComp) then return end

        local ShootEntity = shootComp.ShootWeaponEntityComponent
        local ShootEffect = shootComp.ShootWeaponEffectComp
        
        if slua.isValid(ShootEntity) and slua.isValid(ShootEffect) then
            -- Áp dụng thông số
            Notify("Đã nhận shootentity!")
            ShootEntity.VehicleDamageScale = 573.0
            ShootEntity.BurstShootInterval = 0.0
            ShootEntity.ShootInterval = 0.05
            ShootEntity.AccessoriesVRecoilFactor = 0.13
            ShootEntity.AccessoriesHRecoilFactor = 0.13
            ShootEntity.GameDeviationFactor = 0.0
            ShootEffect.CameraShakeInnerRadius = 0.0
            
            Notify("Cấu hình súng đã kích hoạt!")
        end
    end
end

-- Timer xử lý độc lập để không làm hỏng Animation của nhân vật
local LexusScanTimer = 0

_G.LexusCloudTick = function(self, DeltaSeconds)
    if not DeltaSeconds then return end 
    
    LexusScanTimer = LexusScanTimer + DeltaSeconds
    if LexusScanTimer >= 1.0 then
        LexusScanTimer = 0
        
        -- Gọi ApplyWeaponMod, không truyền self vì ApplyWeaponMod tự lấy qua GameplayData
        local status, err = pcall(ApplyWeaponMod)
        if not status then
            Notify("Lỗi Mod: " .. tostring(err))
        end
    end
end
