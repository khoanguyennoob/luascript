-- Đây là nội dung trên GitHub của bạn
_G.LexusNotify("Đã tải!")
_G.ApplyWeaponMod = function()
    -- Gọi Notify từ Loader
    if _G.LexusNotify then _G.LexusNotify("Đã chạy function!") end
    
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not s or not GameplayData then return end
    
    local LocalPlayer = GameplayData.GetPlayerCharacter()
    if not slua.isValid(LocalPlayer) then return end
    
    local WeaponManager = LocalPlayer:GetWeaponManager()
    if not slua.isValid(WeaponManager) then return end
    
    local CurrentWeapon = LocalPlayer:GetCurrentShootWeapon()
    if slua.isValid(CurrentWeapon) then
        
        local shootComp = CurrentWeapon.ShootWeaponComponent
        if not slua.isValid(shootComp) then return end

        local ShootEntity = shootComp.ShootWeaponEntityComponent
        local ShootEffect = shootComp.ShootWeaponEffectComp
        
        if slua.isValid(ShootEntity) and slua.isValid(ShootEffect) then
            ShootEntity.VehicleDamageScale = 573.0
            ShootEntity.BurstShootInterval = 0.0
            ShootEntity.ShootInterval = 0.05
            ShootEntity.AccessoriesVRecoilFactor = 0.13
            ShootEntity.AccessoriesHRecoilFactor = 0.13
            ShootEntity.GameDeviationFactor = 0.0
            ShootEffect.CameraShakeInnerRadius = 0.0
            
            -- if _G.LexusNotify then _G.LexusNotify("Cấu hình súng đã kích hoạt!") end
        end
    end
end
