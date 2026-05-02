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

local LexusVehicle = {}

function LexusVehicle:ChangeSkin(VH_SkinID)
    local CurrentVehicle = self:GetOwner()
            if slua.isValid(CurrentVehicle) then
                LexusNotify("Đang kiểm tra xe...")
                local VehicleCommon = self:GetCommonComponent()
                if slua.isValid(VehicleCommon) then
                    local AvatarComponent = VehicleCommon:GetAvatarComponent()
                    if slua.isValid(AvatarComponent) then
                        AvatarComponent:ChangeItemAvatar(
                    VH_SkinID, true)
                        LexusNotify("Đã thay đổi skin xe thành công!")
                    else
                        LexusNotify("Không tìm thấy AvatarComponent trên xe.")
                    end
                end
                if CurrentVehicle.VehicleDamage ~= 0.0 then CurrentVehicle.VehicleDamage = 0.0 end
                CurrentVehicle.bEnableAntiCheat = false
            end

end
local class = require("class")
local CVehicleBase = require("GameLua.GameCore.Module.Vehicle.ALuaVehicleBase")
local CLexusVehicle = class(CVehicleBase, nil, LexusVehicle)
return CLexusVehicle


_G.LexusEnemyCache = _G.LexusEnemyCache or {}
_G.LexusLastScan = _G.LexusLastScan or 0

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

        -- 2. MOD XE - CHỈNH SỬA XE CỦA PLAYER
        local playerVehicle = uPlayerController:GetVehicleUserComp()
        if slua.isValid(playerVehicle) then
            LexusNotify("Có component")
            -- Gọi ChangeSkin nếu xe có hàm này
            if type(playerVehicle.ChangeSkin) == "function" then
                playerVehicle:ChangeSkin(1001) -- Thay 1001 bằng SkinID mong muốn
            end
        end

        -- 3. QUÉT TÌM ĐỊCH & TẠO DẤU RADAR
        for _, enemy in pairs(_G.LexusEnemyCache) do
            if slua.isValid(enemy) and enemy.ActiveForceMark and sMark and type(InGameMarkTools.HideMapMark) == "function" then
                InGameMarkTools.HideMapMark(enemy.ActiveForceMark)
                enemy.ActiveForceMark = nil
            end
        end
        _G.LexusEnemyCache = {} 
        if CharacterClass then
            local outActors = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
            UGameplayStatics.GetAllActorsOfClass(uPlayerController, CharacterClass, outActors)
            local myKey = uPlayerCharacter.PlayerKey
            for i = 0, outActors:Num() - 1 do
                local enemy = outActors:Get(i)
                if slua.isValid(enemy) and enemy.PlayerKey ~= myKey and enemy.TeamID ~= uPlayerCharacter.TeamID then
                    table.insert(_G.LexusEnemyCache, enemy)
                    if sMark and type(InGameMarkTools.ClientAddMapMark) == "function" then
                        local loc = type(enemy.GetHeadLocation) == "function" and enemy:GetHeadLocation(false) or enemy:K2_GetActorLocation()
                        enemy.ActiveForceMark = InGameMarkTools.ClientAddMapMark(1003, loc, 0, "", i, nil)
                    end
                end
            end
        end
    end

    -- ==========================================
    -- [LUỒNG NHANH] Cập nhật hình ảnh mỗi 0.03 giây
    -- ==========================================
    local myLocation = uPlayerCharacter:K2_GetActorLocation()
    for _, enemy in pairs(_G.LexusEnemyCache) do
        if slua.isValid(enemy) then
            local isAlive = type(enemy.IsAlive) == "function" and enemy:IsAlive() or true
            if isAlive then
                local enemyLocation = enemy:K2_GetActorLocation()
                local headLocation = type(enemy.GetHeadLocation) == "function" and enemy:GetHeadLocation(false) or enemyLocation
                
                -- Cập nhật vị trí mark trên radar
                if enemy.ActiveForceMark and sMark and type(InGameMarkTools.UpdateMapMarkLocation) == "function" then
                    InGameMarkTools.UpdateMapMarkLocation(enemy.ActiveForceMark, headLocation)
                end
            elseif not isAlive and enemy.ActiveForceMark then
                if sMark and type(InGameMarkTools.HideMapMark) == "function" then
                    InGameMarkTools.HideMapMark(enemy.ActiveForceMark)
                    enemy.ActiveForceMark = nil
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
    local function StartFastLoop()
        pcall(LexusMainLoop)
        local s, time_ticker = pcall(require, "common.time_ticker")
        if s and time_ticker and time_ticker.AddTimerOnce then
            -- Tự động gọi lại vòng lặp sau mỗi 0.03s (~33 FPS)
            time_ticker.AddTimerOnce(0.03, StartFastLoop)
        end
    end
    StartFastLoop()
    if _G.LexusNotify then _G.LexusNotify("Khởi động hệ thống ESP Real-time thành công!") end
end
