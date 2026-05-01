-- Hệ thống Notify
local function Notify(msg)
    pcall(function()
        local chatComp = STExtraBlueprintFunctionLibrary.GetChatComponentFromController(uPlayerController)
        local s3, InGameUITools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameUITools")
        if IngameTipsTools and IngameTipsTools.BattleNormalTips then
            IngameTipsTools.BattleNormalTips("Lexusmod: " .. tostring(msg), 2, 4)
            chatComp:AddMsgInClient("<ChatQuickMsg>Lexusmod: " .. tostring(msg) .. " </>")
        end
    end)
end

Notify("Hệ thống Mod đang khởi động...")

-- Hàm Mod súng (Đã xoá check Slot)
local function ApplyWeaponMod(PlayerRef)
    -- Lấy tham chiếu Player
    local LocalPlayer = PlayerRef
    if PlayerRef.GetPlayerCharacterSafety then
        LocalPlayer = PlayerRef:GetPlayerCharacterSafety()
    end

    if not slua.isValid(LocalPlayer) then return end
    
    local WeaponManager = LocalPlayer.WeaponManagerComponent
    if not slua.isValid(WeaponManager) then return end
    
    -- Lấy trực tiếp vũ khí đang cầm trên tay, bỏ qua việc kiểm tra nằm ở Slot số mấy
    local CurrentWeapon = WeaponManager.CurrentWeaponReplicated
    if slua.isValid(CurrentWeapon) then
        local ShootEntity = CurrentWeapon.ShootWeaponEntityComp
        local ShootEffect = CurrentWeapon.ShootWeaponEffectComp
        
        if slua.isValid(ShootEntity) and slua.isValid(ShootEffect) then
            -- Áp dụng thông số
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
