-- File trên GitHub: script.lua
_G.LexusNotify = function(msg)
    pcall(function()
        -- 1. Hiển thị trên màn hình (Battle Tips)
        local s3, IngameTipsTools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if s3 and IngameTipsTools and IngameTipsTools.BattleNormalTips then
            IngameTipsTools.BattleNormalTips("Lexusmod: " .. msg, 2, 3)
        end
        
        -- 2. Gửi vào kênh Chat
        local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
        if not s or not GameplayData then return end
        local uPlayerController = GameplayData.GetPlayerController()
        if not uPlayerController then return end

        local s2, STExtraBlueprintFunctionLibrary = pcall(import, "STExtraBlueprintFunctionLibrary")
        if s2 and STExtraBlueprintFunctionLibrary then
            local chatComp = STExtraBlueprintFunctionLibrary.GetChatComponentFromController(uPlayerController)
            if chatComp and chatComp.AddMsgInClient then
                chatComp:AddMsgInClient("<ChatQuickMsg>Lexusmod: " .. msg .. "</>")
            end
        end
    end)
end

_G.LexusEnemyCache = _G.LexusEnemyCache or {}
_G.LexusLastScan = _G.LexusLastScan or 0
_G.LexusMarkPool = _G.LexusMarkPool or {}
_G.LexusVisibleMarks = {}
_G.LexusMaxVisibleMarks = 10  -- Tăng giới hạn hiển thị từ 4 lên 10

-- POOL MARKS - Tái sử dụng marks để tránh giới hạn 4
local function LexusInitMarkPool()
    if #_G.LexusMarkPool == 0 then
        for i = 1, _G.LexusMaxVisibleMarks do
            _G.LexusMarkPool[i] = InGameMarkTools.ClientAddMapMark(1003, FVector(0, 0, 0), 0, "", 0, nil)
            if _G.LexusMarkPool[i] then
                InGameMarkTools.HideMapMark(_G.LexusMarkPool[i])
            end
        end
        LexusNotify("Mark Pool Initialized: " .. _G.LexusMaxVisibleMarks .. " marks")
    end
end

-- ASSIGN MARK TỪ POOL
local function LexusAssignMarkToEnemy(enemy, markIdx)
    if not markIdx or not _G.LexusMarkPool[markIdx] then return nil end
    
    local headLocation = type(enemy.GetHeadLocation) == "function" and enemy:GetHeadLocation(false) or enemy:K2_GetActorLocation()
    InGameMarkTools.UpdateMapMarkLocation(_G.LexusMarkPool[markIdx], headLocation)
    InGameMarkTools.ShowMapMark(_G.LexusMarkPool[markIdx])
    
    return _G.LexusMarkPool[markIdx]
end

-- HÀM LOGIC CHÍNH
local function LexusMainLoop()
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not s or not GameplayData then return end
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then return end
    local uPlayerCharacter = uPlayerController:GetCurPawn()
    if not slua.isValid(uPlayerCharacter) then return end

    local sMark, InGameMarkTools = pcall(require, "GameLua.Mod.BaseMod.Common.InGameMarkTools")
    local UGameplayStatics = import("GameplayStatics")
    local USTExtraGameplayStatics = import("STExtraGameplayStatics")
    local CharacterClass = import("/Script/Engine.Character")

    local currentTime = os.clock()

    -- ==========================================
    -- [LUỒNG CHẬM] 2 Giây/lần: Quét địch, Súng, Xe
    -- ==========================================
    if currentTime - _G.LexusLastScan > 2.0 then
        _G.LexusLastScan = currentTime

        -- 1. MOD SÚNG
        if uPlayerCharacter.GetCurrentShootWeapon then
            local uWeaponManager = uPlayerCharacter:GetWeaponManager()
            if slua.isValid(uWeaponManager) and uWeaponManager.HideCurrentWeapon ~= true then
                local CurrentWeapon = uPlayerCharacter:GetCurrentShootWeapon()
                if slua.isValid(CurrentWeapon) then
                    local shootComp = CurrentWeapon.ShootWeaponComponent
                    local ShootEntity = CurrentWeapon.ShootWeaponEntity 
                    if not slua.isValid(ShootEntity) and slua.isValid(shootComp) then
                        ShootEntity = shootComp.ShootWeaponEntityComponent
                    end
                    local ShootEffect = CurrentWeapon.ShootWeaponEffect
                    if not slua.isValid(ShootEffect) and slua.isValid(shootComp) then
                        ShootEffect = shootComp.ShootWeaponEffectComp or shootComp.ShootWeaponEffectComponent
                    end
                    
                    if slua.isValid(ShootEntity) and slua.isValid(ShootEffect) then
                        if ShootEntity.AccessoriesVRecoilFactor ~= 0.11 then
                            ShootEntity.bRecordHitDetail = false
                            ShootEntity.RecoilKickADS = 0.11
                            ShootEntity.bCachedDefaultConfig = false
                            ShootEntity.AccessoriesVRecoilFactor = 0.11
                            ShootEntity.AccessoriesHRecoilFactor = 0.07
                            ShootEntity.GameDeviationFactor = 0.0
                            ShootEffect.CameraShakeInnerRadius = 0.0
                        end
                    end
                end
            end
        end

        -- 2. MOD XE
        if uPlayerCharacter.GetCurrentVehicle then
            local CurrentVehicle = uPlayerCharacter:GetCurrentVehicle()
            if slua.isValid(CurrentVehicle) then
                local VehicleCommon = CurrentVehicle:GetCommonComponent()
                LexusNotify("Đang kiểm tra xe...")
                if slua.isValid(VehicleCommon) then
                    if VehicleCommon.Fuel < 10.0 or (type(VehicleCommon.NoFuel) == "function" and VehicleCommon:NoFuel()) then
                        local MaxFuel = 100.0
                        if type(VehicleCommon.GetFuelMax) == "function" then MaxFuel = VehicleCommon:GetFuelMax()
                        elseif VehicleCommon.FuelMax then MaxFuel = VehicleCommon.FuelMax end
                        
                        if type(VehicleCommon.SetFuelMax) == "function" then VehicleCommon:SetFuelMax(MaxFuel, true) end
                        if type(VehicleCommon.SetFuel) == "function" then VehicleCommon:SetFuel(MaxFuel) else VehicleCommon.Fuel = MaxFuel end
                        if type(VehicleCommon.OnRep_Fuel) == "function" then VehicleCommon:OnRep_Fuel(MaxFuel) end
                    end
                    VehicleCommon.FuelConsumeFactor = 0.0
                end
                if CurrentVehicle.VehicleDamage ~= 0.0 then CurrentVehicle.VehicleDamage = 0.0 end
                CurrentVehicle.bEnableAntiCheat = false
            end
        end

        -- 3. QUÉT TÌM ĐỊCH & TẠO DẤU RADAR (SỬ DỤNG MARK POOL)
        for idx, enemy in pairs(_G.LexusEnemyCache) do
            if slua.isValid(enemy) then
                InGameMarkTools.HideMapMark(enemy.ActiveForceMark)
            end
        end
        _G.LexusEnemyCache = {} 
        _G.LexusVisibleMarks = {}
        
        if CharacterClass then
            local outActors = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
            UGameplayStatics.GetAllActorsOfClass(uPlayerController, CharacterClass, outActors)
            local myKey = uPlayerCharacter.PlayerKey
            local markIdx = 1
            
            for i = 0, outActors:Num() - 1 do
                local enemy = outActors:Get(i)
                if slua.isValid(enemy) and enemy.PlayerKey ~= myKey and enemy.TeamID ~= uPlayerCharacter.TeamID then
                    table.insert(_G.LexusEnemyCache, enemy)
                    
                    -- Gán mark từ pool (tái sử dụng)
                    if markIdx <= _G.LexusMaxVisibleMarks then
                        enemy.ActiveForceMark = LexusAssignMarkToEnemy(enemy, markIdx)
                        table.insert(_G.LexusVisibleMarks, {mark = enemy.ActiveForceMark, enemy = enemy, idx = markIdx})
                        markIdx = markIdx + 1
                    else
                        -- Nếu vượt quá pool, dùng direct draw thay vì mark
                        enemy.UseDirectDraw = true
                    end
                end
            end
        end
    end

    -- ==========================================
    -- [LUỒNG NHANH] Cập nhật hình ảnh mỗi 0.03 giây
    -- ==========================================
    local myLocation = uPlayerCharacter:K2_GetActorLocation()
    for _, markData in pairs(_G.LexusVisibleMarks) do
        local enemy = markData.enemy
        if slua.isValid(enemy) then
            local isAlive = type(enemy.IsAlive) == "function" and enemy:IsAlive() or true
            if isAlive then
                local enemyLocation = enemy:K2_GetActorLocation()
                local headLocation = type(enemy.GetHeadLocation) == "function" and enemy:GetHeadLocation(false) or enemyLocation
                
                -- Cập nhật mark location MỘT LẦN DÙNG UpdateMapMarkLocation (hiệu quả hơn)
                if markData.mark then
                    InGameMarkTools.UpdateMapMarkLocation(markData.mark, headLocation)
                end
                
                -- Vẽ ESP 3D (Duration = 0.0 để smooth)
                if slua.isValid(USTExtraGameplayStatics) then
                    local curHP = enemy.Health or 100
                    local maxHP = enemy.HealthMax or 100
                    local hpPercent = curHP / maxHP
                    
                    local espColor = FLinearColor(1.0, 0.0, 0.0, 1.0)
                    if hpPercent > 0.7 then espColor = FLinearColor(0.0, 1.0, 0.0, 1.0)
                    elseif hpPercent > 0.3 then espColor = FLinearColor(1.0, 1.0, 0.0, 1.0) end

                    if type(USTExtraGameplayStatics.ClientDrawDebugLine) == "function" then
                        USTExtraGameplayStatics.ClientDrawDebugLine(myLocation, enemyLocation, espColor, 0.0, 1.5)
                    end
                    if type(USTExtraGameplayStatics.ClientDrawDebugBox) == "function" then
                        local boxExtent = FVector(45.0, 45.0, 90.0) 
                        local boxCenter = FVector(enemyLocation.X, enemyLocation.Y, enemyLocation.Z + 90.0)
                        USTExtraGameplayStatics.ClientDrawDebugBox(boxCenter, boxExtent, espColor, enemy:K2_GetActorRotation(), 0.0, 1.5)
                    end
                    if type(USTExtraGameplayStatics.ClientDrawDebugString) == "function" then
                        local textLoc = FVector(headLocation.X, headLocation.Y, headLocation.Z + 35.0)
                        local bars = math.floor(hpPercent * 10)
                        local hpText = string.format("[%s%s] %dHP", string.rep("|", bars), string.rep(".", 10 - bars), math.floor(curHP))
                        USTExtraGameplayStatics.ClientDrawDebugString(textLoc, tostring(hpText), enemy, espColor, 0.0)
                    end
                end
            elseif not isAlive and markData.mark then
                InGameMarkTools.HideMapMark(markData.mark)
            end
        end
    end
    
    -- Vẽ direct marks cho địch vượt quá pool (không bị giới hạn 4)
    for _, enemy in pairs(_G.LexusEnemyCache) do
        if slua.isValid(enemy) and enemy.UseDirectDraw then
            local isAlive = type(enemy.IsAlive) == "function" and enemy:IsAlive() or true
            if isAlive then
                local enemyLocation = enemy:K2_GetActorLocation()
                local myLocation = uPlayerCharacter:K2_GetActorLocation()
                local curHP = enemy.Health or 100
                local maxHP = enemy.HealthMax or 100
                local hpPercent = curHP / maxHP
                
                local espColor = FLinearColor(1.0, 0.0, 0.0, 1.0)
                if hpPercent > 0.7 then espColor = FLinearColor(0.0, 1.0, 0.0, 1.0)
                elseif hpPercent > 0.3 then espColor = FLinearColor(1.0, 1.0, 0.0, 1.0) end

                -- Vẽ direct thay vì dùng marks (không có giới hạn 4)
                if slua.isValid(USTExtraGameplayStatics) then
                    if type(USTExtraGameplayStatics.ClientDrawDebugLine) == "function" then
                        USTExtraGameplayStatics.ClientDrawDebugLine(myLocation, enemyLocation, espColor, 0.0, 1.5)
                    end
                end
            end
        end
    end
end

-- ==========================================
-- BỘ KHỞI ĐỘNG ĐỘNG CƠ (CHẠY ĐỆ QUY)
-- ==========================================
if _G.LexusLoopRunning == nil then
    _G.LexusLoopRunning = true
    
    -- Khởi tạo mark pool trước
    LexusInitMarkPool()
    
    local function StartFastLoop()
        pcall(LexusMainLoop)
        local s, time_ticker = pcall(require, "common.time_ticker")
        if s and time_ticker and time_ticker.AddTimerOnce then
            -- Tự động gọi lại vòng lặp sau mỗi 0.03s (~33 FPS)
            time_ticker.AddTimerOnce(0.03, StartFastLoop)
        end
    end
    StartFastLoop()
    if _G.LexusNotify then _G.LexusNotify("Khởi động hệ thống ESP Real-time với Mark Pool (10 marks) thành công!") end
end
