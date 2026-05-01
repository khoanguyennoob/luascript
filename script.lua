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

-- Hàm Mod súng (Đã xoá check Slot)
local function ApplyWeaponMod(PlayerRef)
    -- Lấy tham chiếu Player
    Notify("Đã chạy function!")
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    local LocalPlayer = GameplayData.GetPlayerCharacter()

    if not slua.isValid(LocalPlayer) then return end
    
    local WeaponManager = LocalPlayer:GetWeaponManager()
    if not slua.isValid(WeaponManager) then return end
    
    -- Lấy trực tiếp vũ khí đang cầm trên tay, bỏ qua việc kiểm tra nằm ở Slot số mấy
    local CurrentWeapon = LocalPlayer:GetCurrentShootWeapon()
    if slua.isValid(CurrentWeapon) then
        local ShootEntity = CurrentWeapon.ShootWeaponComponent.ShootWeaponEntityComponent
        local ShootEffect = CurrentWeapon.ShootWeaponComponent.ShootWeaponEffectComp
        
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
        
        -- Gọi pcall kèm bắt lỗi để debug nếu game sập/chống cheat
        local status, err = pcall(ApplyWeaponMod, self)
        if not status then
            Notify("Lỗi Mod: " .. tostring(err))
        end
    end
end
