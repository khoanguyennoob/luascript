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
    -- 3. HỆ THỐNG ESP TỔNG HỢP (RADAR + 3D BOX + HEALTH)
    -- ==========================================
    local UGameplayStatics = import("GameplayStatics")
    local USTExtraGameplayStatics = import("STExtraGameplayStatics")
    local CharacterClass = import("/Script/Engine.Character")
    
    local sMark, InGameMarkTools = pcall(require, "GameLua.Mod.BaseMod.Common.InGameMarkTools")
    
    if CharacterClass then
        local outActors = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
        UGameplayStatics.GetAllActorsOfClass(uPlayerController, CharacterClass, outActors)
        
        local myLocation = uPlayerCharacter:K2_GetActorLocation()

        for i = 0, outActors:Num() - 1 do
            local enemy = outActors:Get(i)
            
            if slua.isValid(enemy) and enemy ~= uPlayerCharacter then
                if enemy.TeamID and enemy.TeamID ~= uPlayerCharacter.TeamID then
                    
                    local isAlive = true
                    if type(enemy.IsAlive) == "function" then isAlive = enemy:IsAlive() end
                    
                    if isAlive then
                        local enemyLocation = enemy:K2_GetActorLocation()
                        local headLocation = type(enemy.GetHeadLocation) == "function" and enemy:GetHeadLocation(false) or enemyLocation
                        
                        -- =====================================
                        -- TÍNH NĂNG A: CHẤM ĐỎ TRÊN MINIMAP (RADAR)
                        -- =====================================
                        if sMark and InGameMarkTools and type(InGameMarkTools.ClientAddMapMark) == "function" then
                            if enemy.ActiveForceMark and type(InGameMarkTools.HideMapMark) == "function" then
                                InGameMarkTools.HideMapMark(enemy.ActiveForceMark)
                            end
                            enemy.ActiveForceMark = InGameMarkTools.ClientAddMapMark(1003, headLocation, 0, "", 4, nil)
                        end

                        -- =====================================
                        -- TÍNH NĂNG B: ESP 3D (HỘP, KẺ CHỈ, MÁU)
                        -- =====================================
                        if slua.isValid(USTExtraGameplayStatics) then
                            local curHP = enemy.Health or 100
                            local maxHP = enemy.HealthMax or 100
                            local hpPercent = curHP / maxHP
                            
                            local espColor = FLinearColor(0.0, 1.0, 0.0, 1.0)
                            if hpPercent < 0.3 then espColor = FLinearColor(1.0, 0.0, 0.0, 1.0)
                            elseif hpPercent < 0.7 then espColor = FLinearColor(1.0, 1.0, 0.0, 1.0) end

                            if type(USTExtraGameplayStatics.ClientDrawDebugLine) == "function" then
                                USTExtraGameplayStatics.ClientDrawDebugLine(myLocation, enemyLocation, espColor, 1.1, 1.5)
                            end

                            if type(USTExtraGameplayStatics.ClientDrawDebugBox) == "function" then
                                local boxExtent = FVector(45.0, 45.0, 90.0) 
                                local boxCenter = FVector(enemyLocation.X, enemyLocation.Y, enemyLocation.Z + 90.0)
                                local boxRotation = enemy:K2_GetActorRotation()
                                USTExtraGameplayStatics.ClientDrawDebugBox(boxCenter, boxExtent, espColor, boxRotation, 1.1, 1.5)
                            end

                            -- ĐÃ SỬA LỖI Ở DÒNG NÀY (Bỏ uPlayerController)
                            if type(USTExtraGameplayStatics.ClientDrawDebugString) == "function" then
                                local textLoc = FVector(headLocation.X, headLocation.Y, headLocation.Z + 30.0)
                                local bars = math.floor(hpPercent * 10)
                                local hpText = "[" .. string.rep("|", bars) .. string.rep(".", 10 - bars) .. "] " .. math.floor(curHP)
                                
                                USTExtraGameplayStatics.ClientDrawDebugString(textLoc, hpText, nil, espColor, 1.1)
                            end
                        end
                        
                    -- Dọn dẹp chấm đỏ trên map khi địch chết
                    elseif not isAlive then
                        if enemy.ActiveForceMark and InGameMarkTools and type(InGameMarkTools.HideMapMark) == "function" then
                            InGameMarkTools.HideMapMark(enemy.ActiveForceMark)
                            enemy.ActiveForceMark = nil
                        end
                    end
                end
            end
        end
    end

end
