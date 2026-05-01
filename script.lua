-- Dòng này nằm vứt thẳng ra ngoài, không nằm trong function nào cả.
-- Khi GM Tool load xong, dòng này PHẢI được in ra màn hình!
if _G.LexusNotify then 
    _G.LexusNotify("Code từ GitHub ĐÃ BIÊN DỊCH VÀ ĐỌC THÀNH CÔNG!") 
end

-- Định nghĩa hàm Mod (phải là _G)
_G.ApplyWeaponMod = function()
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
            if _G.LexusNotify then _G.LexusNotify("Đã nhận shootentity!") end
            ShootEntity.VehicleDamageScale = 573.0
            ShootEntity.BurstShootInterval = 0.0
            ShootEntity.ShootInterval = 0.05
            ShootEntity.AccessoriesVRecoilFactor = 0.13
            ShootEntity.AccessoriesHRecoilFactor = 0.13
            ShootEntity.GameDeviationFactor = 0.0
            ShootEffect.CameraShakeInnerRadius = 0.0
        end
    end
end
