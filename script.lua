-- ==========================================
-- KHỞI TẠO BIẾN TOÀN CỤC & BỘ NHỚ ĐỆM
-- ==========================================

_G.LexusEnemyCache = _G.LexusEnemyCache or {}
_G.LexusLastScan = _G.LexusLastScan or 0
local LastProcessedVehicle = nil

_G.LexusNotify = function(msg)
    pcall(function()
        local s3, IngameTipsTools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if s3 and IngameTipsTools and IngameTipsTools.BattleNormalTips then
            IngameTipsTools.BattleNormalTips("Lexusmod: " .. msg, 2, 3)
        end

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

-- ==========================================
-- HÀM LOGIC CHÍNH
-- ==========================================

local function LexusMainLoop()
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not s or not GameplayData then return end
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then return end
    local uPlayerCharacter = uPlayerController:GetCurPawn()
    if not slua.isValid(uPlayerCharacter) then return end

    local sMark, InGameMarkTools = pcall(require, "GameLua.Mod.BaseMod.Common.InGameMarkTools")
    local UGameplayStatics = import("GameplayStatics")
    local CharacterClass = import("/Script/Engine.Character")

    local currentTime = os.clock()

    -- [LUỒNG CHẬM] 2 Giây/lần: Quét địch, Súng, Xe
    if currentTime - _G.LexusLastScan > 2.0 then
        _G.LexusLastScan = currentTime

        -- 1. MOD SÚNG (Giảm giật)
        if uPlayerCharacter.GetCurrentShootWeapon then
            local uWeaponManager = uPlayerCharacter:GetWeaponManager()
            if slua.isValid(uWeaponManager) and uWeaponManager.HideCurrentWeapon ~= true then
                local CurrentWeapon = uPlayerCharacter:GetCurrentShootWeapon()
                if slua.isValid(CurrentWeapon) then
                    local shootComp = CurrentWeapon.ShootWeaponComponent
                    local ShootEntity = CurrentWeapon.ShootWeaponEntity or (shootComp and shootComp.ShootWeaponEntityComponent)
                    local ShootEffect = CurrentWeapon.ShootWeaponEffect or (shootComp and (shootComp.ShootWeaponEffectComp or shootComp.ShootWeaponEffectComponent))

                    if slua.isValid(ShootEntity) and slua.isValid(ShootEffect) then
                        if ShootEntity.AccessoriesVRecoilFactor ~= 0.11 then
                            ShootEntity.bRecordHitDetail = false
                            ShootEntity.RecoilKickADS = 0.11
                            ShootEntity.AccessoriesVRecoilFactor = 0.11
                            ShootEntity.AccessoriesHRecoilFactor = 0.07
                            ShootEntity.GameDeviationFactor = 0.0
                            ShootEffect.CameraShakeInnerRadius = 0.0
                        end
                    end
                end
            end
        end

        -- 2. MOD XE (Xăng & Skin)
        local playerVehicle = uPlayerCharacter:GetVehicleCommon()
        if slua.isValid(playerVehicle) then
            -- [A] Hồi xăng (Chỉ nạp khi xăng dưới 10%)
            local currentFuel = playerVehicle.Fuel or 0
            if currentFuel < 10 then
                local FuelMax = playerVehicle:GetFuelMax()
                playerVehicle:OnRep_Fuel(FuelMax)
                playerVehicle:SetFuelMax(FuelMax, true)
                LexusNotify("Đã nạp đầy xăng!")
            end

            -- [B] Đổi Skin (Sử dụng API uPlayerController:GetVehicleAvatar())
            if LastProcessedVehicle ~= playerVehicle then
                LexusNotify("Đổi skin!")
                local AvatarComp = nil
                if type(uPlayerController.GetVehicleAvatar) == "function" then
                    AvatarComp = uPlayerController:GetVehicleAvatar()
                    LexusNotify("Nhận avtarvh")
                end

                if not slua.isValid(AvatarComp) then
                    local VehicleCommon = playerVehicle:GetCommonComponent()
                    if slua.isValid(VehicleCommon) and type(VehicleCommon.GetAvatarComponent) == "function" then
                        AvatarComp = VehicleCommon:GetAvatarComponent()
                    end
                end

                if slua.isValid(AvatarComp) and type(AvatarComp.ChangeItemAvatar) == "function" then
                    AvatarComp:ChangeItemAvatar(1961020, true)
                    LexusNotify("client")

                    if type(uPlayerController.ServerChangeVehicleAvatar) == "function" then
                        uPlayerController:ServerChangeVehicleAvatar(1961020)
                    end

                    LexusNotify("Đã áp dụng skin siêu xe!")
                    LastProcessedVehicle = playerVehicle
                end
            end
        else
            LastProcessedVehicle = nil
        end

        -- 3. QUÉT ĐỊCH (ESP RADAR)
        for _, enemy in pairs(_G.LexusEnemyCache) do
            if slua.isValid(enemy) and enemy.ActiveForceMark and sMark then
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

    -- [LUỒNG NHANH] Cập nhật vị trí Radar (0.03s)
    for _, enemy in pairs(_G.LexusEnemyCache) do
        if slua.isValid(enemy) then
            local isAlive = type(enemy.IsAlive) == "function" and enemy:IsAlive() or true
            if isAlive and enemy.ActiveForceMark and sMark then
                local headLoc = type(enemy.GetHeadLocation) == "function" and enemy:GetHeadLocation(false) or enemy:K2_GetActorLocation()
                InGameMarkTools.UpdateMapMarkLocation(enemy.ActiveForceMark, headLoc)
            end
        end
    end
end

-- ==========================================
-- KHỞI CHẠY HỆ THỐNG
-- ==========================================

if _G.LexusLoopRunning == nil then
    _G.LexusLoopRunning = true

    local function StartFastLoop()
        pcall(LexusMainLoop)
        local s, time_ticker = pcall(require, "common.time_ticker")
        if s and time_ticker and time_ticker.AddTimerOnce then
            time_ticker.AddTimerOnce(0.03, StartFastLoop)
        end
    end

    StartFastLoop()
    _G.LexusNotify("Hệ thống Lexus Mod đã kích hoạt!")
end


-- ==========================================
-- ĐĂNG KÝ CLASS XE
-- ==========================================

local LexusVehicleClass = {}

function LexusVehicleClass:ChangeSkin(VH_SkinID)
    local CurrentVehicle = self:GetOwner()
    if slua.isValid(CurrentVehicle) then
        local VehicleCommon = self:GetCommonComponent()
        if slua.isValid(VehicleCommon) then
            local AvatarComponent = VehicleCommon:GetAvatarComponent()
            if slua.isValid(AvatarComponent) then
                AvatarComponent:ChangeItemAvatar(VH_SkinID, true)
            end
        end
    end
end

local class = require("class")
local CVehicleBase = require("GameLua.GameCore.Module.Vehicle.ALuaVehicleBase")
local CLexusVehicle = class(CVehicleBase, nil, LexusVehicleClass)

return CLexusVehicle
