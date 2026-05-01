_G.ApplyWeaponMod = function()
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not s or not GameplayData then return end
    
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then return end
    
    local uPlayerCharacter = uPlayerController:GetCurPawn()
    if not slua.isValid(uPlayerCharacter) then return end

    -- ==========================================
    -- 1. HỆ THỐNG MOD SÚNG (WEAPON MOD)
    -- ==========================================
    if uPlayerCharacter.GetCurrentShootWeapon then
        local uWeaponManager = uPlayerCharacter:GetWeaponManager()
        if slua.isValid(uWeaponManager) and uWeaponManager.HideCurrentWeapon ~= true then
            local CurrentWeapon = uPlayerCharacter:GetCurrentShootWeapon()
            
            if slua.isValid(CurrentWeapon) then
                local ShootEntity = CurrentWeapon.ShootWeaponEntity 
                if not slua.isValid(ShootEntity) and slua.isValid(CurrentWeapon.ShootWeaponComponent) then
                    ShootEntity = CurrentWeapon.ShootWeaponComponent.ShootWeaponEntityComponent
                end
                
                local ShootEffect = CurrentWeapon.ShootWeaponEffect
                if not slua.isValid(ShootEffect) and slua.isValid(CurrentWeapon.ShootWeaponComponent) then
                    ShootEffect = CurrentWeapon.ShootWeaponComponent.ShootWeaponEffectComponent
                end
                
                if ShootEntity.AccessoriesVRecoilFactor ~= 0.11 then
                    ShootEntity.bRecordHitDetail = false;
                    ShootEntity.RecoilKickADS = 0.11;
                    ShootEntity.bCachedDefaultConfig = false;
                  --  ShootEntity.bDrawCrosshairWhenScope = false;
                   -- ShootEntity.ReloadWithNoCost = true;
                    --ShootEntity.BulletNumSingleShot = 8;
                    ShootEntity.AccessoriesVRecoilFactor = 0.11
                    ShootEntity.AccessoriesHRecoilFactor = 0.07
                    ShootEntity.GameDeviationFactor = 0.0
                    ShootEffect.CameraShakeInnerRadius = 0.0
                    if _G.LexusNotify then _G.LexusNotify("Cấu hình súng đã được tối ưu!") end
                    end
                end
            end
        end
    end

    -- ==========================================
    -- 2. HỆ THỐNG MOD XE (VEHICLE MOD TỐI ƯU)
    -- ==========================================
    
end
