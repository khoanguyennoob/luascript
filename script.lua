-- File trên GitHub: script.lua
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
                
                if slua.isValid(ShootEntity) and slua.isValid(ShootEffect) then
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
                    end
                end
            end
        end
    end

    -- ==========================================
    -- 2. HỆ THỐNG MOD XE (VEHICLE MOD)
    -- ==========================================
    if uPlayerCharacter.GetCurrentVehicle then
        local CurrentVehicle = uPlayerCharacter:GetCurrentVehicle()
        if slua.isValid(CurrentVehicle) then
            local VehicleCommon = CurrentVehicle.VehicleCommon
            if slua.isValid(VehicleCommon) then
                if VehicleCommon.Fuel < 10.0 or (type(VehicleCommon.NoFuel) == "function" and VehicleCommon:NoFuel()) then
                    local MaxFuel = 100.0
                    if type(VehicleCommon.GetFuelMax) == "function" then
                        MaxFuel = VehicleCommon:GetFuelMax()
                    elseif VehicleCommon.FuelMax then MaxFuel = VehicleCommon.FuelMax end
                    
                    if type(VehicleCommon.SetFuelMax) == "function" then VehicleCommon:SetFuelMax(MaxFuel, true) end
                    if type(VehicleCommon.SetFuel) == "function" then VehicleCommon:SetFuel(MaxFuel) else VehicleCommon.Fuel = MaxFuel end
                end
                VehicleCommon.FuelConsumeFactor = 0.0
            end
            if CurrentVehicle.VehicleDamage ~= 0.0 then CurrentVehicle.VehicleDamage = 0.0 end
            CurrentVehicle.bEnableAntiCheat = false
        end
    end

    -- ==========================================
    -- 3. HỆ THỐNG ESP (TÌM ĐỊCH & VẼ VIỀN)
    -- ==========================================
    local UGameplayStatics = import("GameplayStatics")
    local CharacterClass = import("/Script/Engine.Character")
    
    if CharacterClass then
        -- Lấy toàn bộ nhân vật có trên bản đồ
        local outActors = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
        UGameplayStatics.GetAllActorsOfClass(uPlayerController, CharacterClass, outActors)
        
        -- Gọi các thư viện UI (Cần dùng pcall để an toàn)
        local sMark, InGameMarkTools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameMarkTools")
        local ppm = import("PostProcessManager")
        local uPPMInstance = slua.isValid(ppm) and ppm:GetInstance() or nil

        for i = 0, outActors:Num() - 1 do
            local enemy = outActors:Get(i)
            
            -- Nếu đây là nhân vật hợp lệ và không phải là bản thân mình
            if slua.isValid(enemy) and enemy ~= uPlayerCharacter then
                
                -- Phân biệt Địch / Ta bằng TeamID
                if enemy.TeamID and enemy.TeamID ~= uPlayerCharacter.TeamID then
                    
                    local isAlive = true
                    if type(enemy.IsAlive) == "function" then isAlive = enemy:IsAlive() end
                    
                    if isAlive then
                        -- TÍNH NĂNG A: BẬT WALLHACK (Viền đỏ)
                        if slua.isValid(uPPMInstance) and uPPMInstance.IsPPEnabled then
                            local ac = type(enemy.getAvatarComponent2) == "function" and enemy:getAvatarComponent2() or nil
                            if slua.isValid(ac) then
                                uPPMInstance.OutlineThickness = 10
                                if uPPMInstance.OutlineColor then
                                    uPPMInstance.OutlineColor = { r = 15, g = 0, b = 0, a = 1000 }
                                end
                                uPPMInstance:EnableAvatarOutline(ac, true)
                            end
                        end
                        
                        -- TÍNH NĂNG B: RADAR MINIMAP
                        if sMark and InGameMarkTools and type(InGameMarkTools.ClientAddMapMark) == "function" then
                            local head_location = nil
                            if type(enemy.GetHeadLocation) == "function" then
                                head_location = enemy:GetHeadLocation(false)
                            end
                            if not head_location and type(enemy.K2_GetActorLocation) == "function" then
                                head_location = enemy:K2_GetActorLocation()
                            end
                            
                            if head_location then
                                -- Xoá chấm cũ để tránh lag/spam trên map
                                if enemy.ActiveForceMark and type(InGameMarkTools.HideMapMark) == "function" then
                                    InGameMarkTools.HideMapMark(enemy.ActiveForceMark)
                                end
                                -- Đặt chấm mới (MarkID 1003)
                                enemy.ActiveForceMark = InGameMarkTools.ClientAddMapMark(1003, head_location, 0, "", 4, nil)
                            end
                        end
                        
                    -- NẾU ĐỊCH ĐÃ CHẾT: TẮT VIỀN VÀ XÓA RADAR
                    elseif not isAlive then
                        if enemy.ActiveForceMark and sMark and type(InGameMarkTools.HideMapMark) == "function" then
                            InGameMarkTools.HideMapMark(enemy.ActiveForceMark)
                            enemy.ActiveForceMark = nil
                        end
                        if slua.isValid(uPPMInstance) and uPPMInstance.IsPPEnabled then
                            local ac = type(enemy.getAvatarComponent2) == "function" and enemy:getAvatarComponent2() or nil
                            if slua.isValid(ac) then
                                uPPMInstance:EnableAvatarOutline(ac, false)
                            end
                        end
                    end
                end
            end
        end
    end
end
