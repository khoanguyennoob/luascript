-- script.lua trên GitHub
local function Notify(msg)
    pcall(function()
        local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if IngameTipsTools and IngameTipsTools.BattleNormalTips then
            IngameTipsTools.BattleNormalTips("Lexusmod: " .. msg, 2, 4)
        end
    end)
end

Notify("Hệ thống Mod đã sẵn sàng!")

-- Hàm Mod súng
local function ApplyWeaponMod(self)
    local LocalPlayer = self:GetPlayerCharacterSafety()
    if not slua.isValid(LocalPlayer) then return end
    
    local WeaponManager = LocalPlayer.WeaponManagerComponent
    if not slua.isValid(WeaponManager) then return end
    
    local Slot = WeaponManager:GetCurrentUsingPropSlot()
    local SlotValue = tonumber(Slot:GetValue()) or 0
    
    if SlotValue >= 1 and SlotValue <= 3 then
        local CurrentWeapon = WeaponManager.CurrentWeaponReplicated
        if slua.isValid(CurrentWeapon) then
            local ShootEntity = CurrentWeapon.ShootWeaponEntityComp
            local ShootEffect = CurrentWeapon.ShootWeaponEffectComp
            
            if slua.isValid(ShootEntity) and slua.isValid(ShootEffect) then
                if ShootEntity.VehicleDamageScale ~= 573.0 then
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
    end
end

-- Inject (Tiêm) logic vào hệ thống đã chạy
-- Chúng ta sử dụng một Global Variable để BRPlayerCharacterBase.lua gọi vào
_G.LexusCloudTick = function(self, DeltaSeconds)
    self.LexusScanTimer = (self.LexusScanTimer or 0) + DeltaSeconds
    if self.LexusScanTimer >= 1.0 then
        self.LexusScanTimer = 0
        pcall(ApplyWeaponMod, self)
    end
end
