
function BRPlayerCharacterBase:ApplyWeaponConfig()
    -- Import class từ Unreal Engine
    local LocalPlayer = self:GetPlayerCharacterSafety()
    if not slua.isValid(LocalPlayer) then
      return
    end
    
    
    local WeaponManager = LocalPlayer.WeaponManagerComponent
    if not slua.isValid(WeaponManager) then
        return false
    end
    
    -- Lấy slot vũ khí hiện tại
    local Slot = WeaponManager:GetCurrentUsingPropSlot()
    local SlotValue = tonumber(Slot:GetValue()) or 0
    
    if SlotValue >= 1 and SlotValue <= 3 then
        local CurrentWeapon = WeaponManager.CurrentWeaponReplicated
        
        if slua.isValid(CurrentWeapon) then
            local ShootEntity = CurrentWeapon.ShootWeaponEntityComp
            local ShootEffect = CurrentWeapon.ShootWeaponEffectComp
            
            -- Kiểm tra cả 2 component có hợp lệ không
            if slua.isValid(ShootEntity) and slua.isValid(ShootEffect) then
                
                    ShootEntity.VehicleDamageScale = 573.0
                    ShootEntity.BurstShootInterval = 0.0
                    ShootEntity.ShootIntervalShowNumber = 990
                    ShootEntity.ShootInterval = 0.05
                    ShootEntity.ExtraShootInterval = 0.05
                    ShootEntity.bRecordHitDetail = false
                    ShootEntity.AccessoriesVRecoilFactor = 0.11
                    ShootEntity.AccessoriesHRecoilFactor = 0.11
                    ShootEntity.GameDeviationFactor = 0.0
                    ShootEntity.MaxDamageRate = 0
                    ShootEntity.RecoilKickADS = 0.11
                    ShootEntity.AccessoriesVRecoilFactor = 0.13
                    ShootEntity.AccessoriesHRecoilFactor = 0.13
                    ShootEffect.CameraShakeInnerRadius = 0.0
                    ShootEffect.CameraShakeOuterRadius = 0.0
                    ShootEffect.CameraShakFalloff = 0.000001
                    ShootEntity.GameDeviationFactor = 0.0
                    ShootEntity.GameDeviationAccuracy = 0.0
            end
        end
    end

    pcall(function() 
            BRPlayerCharacterBase:ApplyWeaponConfig() 
        end)
    return false
end
