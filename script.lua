-- File trên GitHub: script.lua
_G.ApplyWeaponMod = function()
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not s or not GameplayData then return end
    
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then return end
    if _G.LexusNotify then _G.LexusNotify("nhận control!") end
    
    local uPlayerCharacter = uPlayerController:GetCurPawn()
    
    -- Kiểm tra 1: Pawn phải là nhân vật và có hỗ trợ súng
    if slua.isValid(uPlayerCharacter) and uPlayerCharacter.GetCurrentShootWeapon then
        
        -- Kiểm tra 2 (Học từ CharacterBase.lua): 
        -- Đảm bảo nhân vật không nằm trong các trạng thái ẩn súng (như Dying, Bơi, v.v.)
        -- Ở đây kiểm tra xem hàm GetWeaponManager có hoạt động và súng có bị ẩn không
        local uWeaponManager = uPlayerCharacter:GetWeaponManager()
        if slua.isValid(uWeaponManager) and uWeaponManager.HideCurrentWeapon == true then
            return -- Thoát sớm nếu súng đang bị giấu đi (ví dụ: đang cứu đồng đội, đang bò)
        end

        local CurrentWeapon = uPlayerCharacter:GetCurrentShootWeapon()
        
        if slua.isValid(CurrentWeapon) then
            -- Kiểm tra 3 (Học từ CharacterBase.lua): 
            -- Đề phòng lỗi NetCullDistance (súng chưa kịp load Component đầy đủ)
            local ShootEntity = CurrentWeapon.ShootWeaponEntity 
            if not slua.isValid(ShootEntity) and slua.isValid(CurrentWeapon.ShootWeaponComponent) then
                ShootEntity = CurrentWeapon.ShootWeaponComponent.ShootWeaponEntityComponent
            end
            
            local ShootEffect = CurrentWeapon.ShootWeaponEffectComp 
            if not slua.isValid(ShootEffect) and slua.isValid(CurrentWeapon.ShootWeaponComponent) then
                ShootEffect = CurrentWeapon.ShootWeaponComponent.ShootWeaponEffectComp
            end
            
            -- Áp dụng Mod khi mọi thứ đã load đầy đủ và an toàn
            if slua.isValid(ShootEntity) and slua.isValid(ShootEffect) then
                -- Kiểm tra giá trị trước khi gán để tránh spam lệnh gán (tối ưu CPU)
                if ShootEntity.VehicleDamageScale ~= 573.0 then
                    ShootEntity.VehicleDamageScale = 573.0
                    ShootEntity.BurstShootInterval = 0.0
                    ShootEntity.ShootInterval = 0.05
                    ShootEntity.AccessoriesVRecoilFactor = 0.13
                    ShootEntity.AccessoriesHRecoilFactor = 0.13
                    ShootEntity.GameDeviationFactor = 0.0
                    ShootEffect.CameraShakeInnerRadius = 0.0
                    
                    if _G.LexusNotify then _G.LexusNotify("Cấu hình súng đã được tối ưu!") end
                end
            end
        end
    end
end
