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
    if uPlayerCharacter.GetCurrentVehicle then
        local CurrentVehicle = uPlayerCharacter:GetCurrentVehicle()
        
        if slua.isValid(CurrentVehicle) then
            local VehicleCommon = CurrentVehicle.VehicleCommon
            
            if slua.isValid(VehicleCommon) then
                -- Dùng hàm NoFuel() hoặc kiểm tra xăng thấp để bơm tự động
                if VehicleCommon.Fuel < 10.0 or (type(VehicleCommon.NoFuel) == "function" and VehicleCommon:NoFuel()) then
                    
                    local MaxFuel = 100.0
                    if type(VehicleCommon.GetFuelMax) == "function" then
                        MaxFuel = VehicleCommon:GetFuelMax()
                    elseif VehicleCommon.FuelMax then
                        MaxFuel = VehicleCommon.FuelMax
                    end
                    
                    -- SỬ DỤNG HÀM CHUẨN CỦA GAME ĐỂ BƠM XĂNG
                    if type(VehicleCommon.SetFuelMax) == "function" then
                        VehicleCommon:SetFuelMax(MaxFuel, true)
                        --VehicleCommon:OnRep_Fuel(MaxFuel)
                    end
                    if type(VehicleCommon.SetFuel) == "function" then
                        VehicleCommon:SetFuel(MaxFuel)
                      --  VehicleCommon:OnRep_Fuel(MaxFuel)
                    else
                        VehicleCommon.Fuel = MaxFuel
                    end
                    
                    if _G.LexusNotify then _G.LexusNotify("Đã tự động nạp đầy nhiên liệu xe bằng hàm gốc!") end
                end
                
                VehicleCommon.FuelConsumeFactor = 0.001 -- Đưa luôn về 0 cho xe chạy vĩnh viễn
            end
            
            -- Sửa xe & Tắt Anti-Cheat
            if CurrentVehicle.VehicleDamage ~= 0.0 then
                CurrentVehicle.VehicleDamage = 0.0
            end
            CurrentVehicle.bEnableAntiCheat = false
        end
    end
end
