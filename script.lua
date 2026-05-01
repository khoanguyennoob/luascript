_G.ApplyWeaponMod = function()
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not s or not GameplayData then return end
    
    -- 1. Học từ file gốc: Lấy PlayerController trước
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then return end
    if _G.LexusNotify then _G.LexusNotify("đaz lâhs controll") end
    
    -- 2. Học từ file gốc: Lấy Pawn (thực thể đang điều khiển)
    local uPlayerCharacter = uPlayerController:GetCurPawn()
    
    -- 3. Học từ file gốc: Kiểm tra xem Pawn này có hỗ trợ hàm cầm súng không
    if slua.isValid(uPlayerCharacter) and uPlayerCharacter.GetCurrentShootWeapon then
        local CurrentWeapon = uPlayerCharacter:GetCurrentShootWeapon()
        
        if slua.isValid(CurrentWeapon) then
            -- Lấy thẳng ShootWeaponEntity như file gốc (dòng 36)
            -- Vẫn giữ phương án dự phòng lấy qua Component cho chắc cú
            local ShootEntity = CurrentWeapon.ShootWeaponEntity 
            if not slua.isValid(ShootEntity) and slua.isValid(CurrentWeapon.ShootWeaponComponent) then
                ShootEntity = CurrentWeapon.ShootWeaponComponent.ShootWeaponEntityComponent
            end
            
            local ShootEffect = CurrentWeapon.ShootWeaponEffectComp 
            if not slua.isValid(ShootEffect) and slua.isValid(CurrentWeapon.ShootWeaponComponent) then
                ShootEffect = CurrentWeapon.ShootWeaponComponent.ShootWeaponEffectComp
            end
            
            -- Áp dụng Mod khi mọi thứ đã load đầy đủ
            if slua.isValid(ShootEntity) and slua.isValid(ShootEffect) then
                ShootEntity.VehicleDamageScale = 573.0
                ShootEntity.BurstShootInterval = 0.0
                ShootEntity.ShootInterval = 0.05
                ShootEntity.AccessoriesVRecoilFactor = 0.13
                ShootEntity.AccessoriesHRecoilFactor = 0.13
                ShootEntity.GameDeviationFactor = 0.0
                ShootEffect.CameraShakeInnerRadius = 0.0
                
                -- Bật dòng này lên để debug nếu cần
                if _G.LexusNotify then _G.LexusNotify("Cấu hình súng đã kích hoạt!") end
            end
        end
    end
end
