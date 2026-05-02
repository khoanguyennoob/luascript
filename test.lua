🚗 Vehicle Effect Change 🚗

local VehicleAvatarComponent = require("GameLua.GameCore.Module.Vehicle.Component.VehicleAvatarComponent")

VehicleAvatarComponent.__inner_impl.CheckCanPlaySkinSwitchEffect = function(self, curVehicleId, lastVehicleId)
    return true
end

VehicleAvatarComponent.__inner_impl.ShowVehicleSwitchEffect = function(self)
    if not self.curSwitchEffectId or self.curSwitchEffectId <= 0 then
        self.curSwitchEffectId = 7303001
    end

    local vehicleActor = self:GetOwner()
    if not slua.isValid(vehicleActor) then return false end

    if self.uSwitchEffectActor then
        self:StopSkinSwitchEffect()
        self.uSwitchEffectActor:K2_DestroyActor()
        self.uSwitchEffectActor = nil
    end

    if not self.lastEquipedAvatarId or self.lastEquipedAvatarId <= 0 then
        self.lastEquipedAvatarId = vehicleActor.ClientUsedAvatarID or vehicleActor:GetDefaultAvatarID() or 0
    end

    local currentAvatarID = vehicleActor.ClientUsedAvatarID or self.lastEquipedAvatarId or 0
    local bIsLobbyActor = self:IsLobbyActor()
    local world = slua_GameFrontendHUD:GetWorld()
    local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
    local SkinSwitchEffectActorPath = VehiclePlateLicenseUtil.GetSwitchEffectActorPath()
    local BP_DissolveVehicleClass = import(SkinSwitchEffectActorPath)

    self.uSwitchEffectActor = world:SpawnActor(BP_DissolveVehicleClass, nil, nil, nil)
    if not slua.isValid(self.uSwitchEffectActor) then
        self.uSwitchEffectActor = nil
        return false
    end

    self.uSwitchEffectActor:K2_AttachToActor(vehicleActor, "None", 1, 1, 1, false)
    self.uSwitchEffectActor:K2_SetActorRelativeLocation(FVector(0, 0, 0), false, nil, false)
    self.uSwitchEffectActor:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, false)
    self:ChangeFakeSwitchVehicleAvatar(self.uSwitchEffectActor.Mesh, self.lastEquipedAvatarId)
    self.uSwitchEffectActor:SetAnimInsAndAnimState(self.uOldVehicleMeshAnimClass, vehicleActor)
    self.uSwitchEffectActor:StartVehicleSwitchEffect(vehicleActor, self.curSwitchEffectId, self.lastEquipedAvatarId, currentAvatarID, bIsLobbyActor)
    self.uOldVehicleMeshAnimClass = nil
    return true
end

VehicleAvatarComponent.__inner_impl.ResetAnimationState = function(self)
    if self.uSwitchEffectActor then
        self:StopSkinSwitchEffect()
        self.uSwitchEffectActor:K2_DestroyActor()
        self.uSwitchEffectActor = nil
    end
    self.lastEquipedAvatarId = 0
    self.curSwitchEffectId = 7303001
end

local Hama = SDKDumper

local O_ReceiveBeginPlay = VehicleAvatarComponent.__inner_impl.ReceiveBeginPlay
VehicleAvatarComponent.__inner_impl.ReceiveBeginPlay = function(self)
    O_ReceiveBeginPlay(self)
    self:ResetAnimationState()
end
❤️Credit: HaMa

By @Kong_Mods_Owner
Join Our Chat Group ✅
Join @SRC_HUB
