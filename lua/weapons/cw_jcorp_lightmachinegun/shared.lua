AddCSLuaFile()


DEFINE_BASECLASS("simple_base_scoped")

SWEP.Base = "simple_base_scoped"

SWEP.RenderGroup = RENDERGROUP_BOTH

SWEP.PrintName = "Light Machine Gun"
SWEP.Category = "JSMC Dedicated Equipments Division"

SWEP.JCMS_COSTOVERRIDE = 550*4

SWEP.Slot = 2

SWEP.Spawnable = true

SWEP.UseHands = true

SWEP.ViewModelTargetFOV = 60

SWEP.ViewModel = Model("models/weapons/v_mg42.mdl")
SWEP.WorldModel = Model("models/weapons/w_mg42bd.mdl")

SWEP.HoldType = "ar2"
SWEP.LowerHoldType = "passive"

SWEP.Firemode = -1

SWEP.ScopeZoom = 1.1
-- SWEP.ScopeSound = "Simple_Weapons.CombineScope"

SWEP.Secondary.Automatic = false
-- SWEP.WalkSpeed = 100 -- default is 150
-- SWEP.RunSpeed = 200
SWEP.Aiming = false
SWEP.AimReleasedTime = 0
SWEP.AimReleaseDelay = 0.5

SWEP.Primary = {
	Ammo = "AR2",

	ClipSize = -1,
	DefaultClip = 200,

	RangeModifier = 1,
	Damage = 13,
	Count = 2,
	-- Delay = 60 / 1000,
	Delay = 0.07,
	Accuracy = 20,
	Range = 400,
	Recoil = {
		MinAng = Angle(-0.2, -0.5, 0),
		MaxAng = Angle(0.3, 0.5, 0),
		Punch = 1.0,
		Ratio = 0.2
	},
	Sound = "Simple_Weapons_JCORP_LMG1.Loop",
	
	
	
	Reload = {
		Time = 3.5
	},
	
	
	TracerName = "Tracer"
	-- TracerName = "AirboatGunTracer"
	-- TracerName = "LaserTracer"
}

SWEP.ViewOffset = Vector(-5, -1, -2)


local transitions = {
	-- [ACT_VM_PRIMARYATTACK] = ACT_VM_RELOAD,
	-- [ACT_VM_RECOIL1] = ACT_VM_RELOAD,
	-- [ACT_VM_RECOIL2] = ACT_VM_RELOAD,
	-- [ACT_VM_RECOIL3] = ACT_VM_RELOAD,
	-- [ACT_VM_PRIMARYATTACK] = ACT_VM_RECOIL1,
	-- [ACT_VM_RECOIL1] = ACT_VM_RECOIL2,
	-- [ACT_VM_RECOIL2] = ACT_VM_RECOIL3,
	-- [ACT_VM_RECOIL3] = ACT_VM_RECOIL3,
}

function SWEP:GetFireSound()
		return "Simple_Weapons_JCORP_LMG1.Loop"
end

function SWEP:TranslateWeaponAnim(act)
	if act == ACT_VM_PRIMARYATTACK then
		local lookup = transitions[self:GetActivity()]

		if lookup then
			act = lookup
		end
	end

	return act
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Bool", "IsFiring")
	self:NetworkVar("Bool", "Zoomed")
end

function SWEP:Deploy()
	BaseClass.Deploy(self)

	self:SetIsFiring(false)
	self:SetZoomed(false)
	self.Primary.Recoil = self.UnscopedStats.Recoil
	return true
end

SWEP.UnscopedStats = {
	Recoil = {
		MinAng = Angle(0.1, -0.3, 0),
		MaxAng = Angle(0.3, -0.1, 0),
		Punch = 1.8,
		Ratio = -0.4
	},
	Range = 400,
	Accuracy = 5,
}

SWEP.ScopedStats = {
	Recoil = {
		MinAng = Angle(-0.2, -0.2, 0),
		MaxAng = Angle(0.3, 0.1, 0),
		Punch = 0.6,
		Ratio = 0.2
	},
	Range = 1000,
	Accuracy = 20,
}

function SWEP:OwnerChanged()
	BaseClass.OwnerChanged(self)

	self:StopSound(self.Primary.Sound)

	local ply = self:GetOwner()

	if IsValid(ply) and ply:IsNPC() then
		hook.Add("Think", self, self.NPCThink)
	else
		hook.Remove("Think", self)
	end
end

function SWEP:OnRemove()
	self:StopSound(self.Primary.Sound)
end

function SWEP:EmitFireSound()
	local currentSound = self:GetFireSound()
	
		self:EmitSound("Simple_Weapons_JCORP_LMG1.Sweetener2")
		-- self:EmitSound("Simple_Weapons_JCORP_LMG1.Sweetener2")

	-- If we're not already firing, play the correct loop
	if not self:GetIsFiring() then
		self:EmitSound("Simple_Weapons_JCORP_LMG1.LoopBegin")
		self:EmitSound(currentSound)
		self:SetIsFiring(true)
		self.LastSoundZoomedState = self:GetZoomed()
		return
	end

	-- Already firing, but zoom state changed — switch loop
	if self.LastSoundZoomedState ~= self:GetZoomed() then
		self:EmitSound(currentSound)
		self.LastSoundZoomedState = self:GetZoomed()
	end
	
		self:EmitSound("Simple_Weapons_JCORP_LMG1.Sweetener")
end


function SWEP:Think()
	BaseClass.Think(self)
	
    if self.Aiming and not self.Owner:KeyDown(IN_ATTACK2) then
        self.Aiming = false
        self.AimReleasedTime = CurTime()
    end

    if not self:IsValid() or self:GetOwner():GetActiveWeapon() ~= self then
        self:StopSound(self.Primary.Sound)
        return
    end

	local owner = self:GetOwner()

	if IsValid(owner) and owner:IsPlayer() then
		local wantsZoom = owner:KeyDown(IN_ATTACK2)

		if wantsZoom ~= self:GetZoomed() then
			self:SetZoomed(wantsZoom)		
		end
	
			if wantsZoom then
				self.Primary.Recoil = self.ScopedStats.Recoil
				self.Primary.Range = self.ScopedStats.Range
				self.Primary.Accuracy = self.ScopedStats.Accuracy
				-- self.Owner:SetWalkSpeed(130)
				-- self.Owner:SetRunSpeed(130)
			else
				self.Primary.Recoil = self.UnscopedStats.Recoil
				self.Primary.Range = self.UnscopedStats.Range
				self.Primary.Accuracy = self.UnscopedStats.Accuracy
				-- self.Owner:SetWalkSpeed(180)
				-- self.Owner:SetRunSpeed(280)
			end
		

	-- Stop firing sound if needed
	if self:GetIsFiring() and CurTime() > self:GetNextFire() + engine.TickInterval() then	
				if IsValid(self) then
					self:SetIsFiring(false)
					self:EmitSound("Simple_Weapons_JCORP_LMG1.End")
					self:SetNextFire(CurTime() + 0.1)
				end
			-- end)
	end
end
end

function SWEP:DoImpactEffect(tr, dmgtype)
			self:DoAR2Impact(tr) 
end

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()

	if self:GetNextFire() > CurTime() or not self:CanPrimaryFire() then	return end
	
    if CurTime() < self.AimReleasedTime + self.AimReleaseDelay then return end

	self:PrimaryFire()
end

function SWEP:SecondaryAttack()
	if CLIENT or not IsFirstTimePredicted() then return end
	
	if self:GetIsFiring() then 
		self.IsFiring = false
        self:StopSound(self.Primary.Sound)
		self:EmitSound("Simple_Weapons_JCORP_LMG1.End")
	end

	self:SetZoomed(true)
	self:SetNextFire(CurTime() + 0.5)
	self.Aiming = true
end

function SWEP:AltFire()
	self.Primary.Automatic = true
	self:CycleScope()
end

if CLIENT then
	local currentFOV = nil

	function SWEP:TranslateFOV(fov)
		local targetFOV = fov

		if self:GetZoomed() then
			targetFOV = fov / self.ScopeZoom
		end

		currentFOV = Lerp(FrameTime() * 2, currentFOV or fov, targetFOV)
		return currentFOV
	end

	function SWEP:AdjustMouseSensitivity()
		if self:GetZoomed() then
			return 1 / self.ScopeZoom
		end

		return nil -- default sensitivity
	end
end

function SWEP:Holster()
    self:SetIsFiring(false)

    timer.Simple(0, function()
        if IsValid(self) then
            self:StopSound(self.Primary.Sound)
        end
    end)

    return BaseClass.Holster(self)
end

function SWEP:StartReload()
    local reload = self.Primary.Reload

    self:GetOwner():SetAnimation(PLAYER_RELOAD)

    if reload.Shotgun then
        self:SendTranslatedWeaponAnim(ACT_SHOTGUN_RELOAD_START)
        self:SetFirstReload(true)
    else
        self:SendTranslatedWeaponAnim(ACT_VM_RELOAD)
        self:EmitReloadSound()
    end

    local vm = self:GetOwner():GetViewModel()
    if IsValid(vm) then
        vm:SetPlaybackRate(1.5)
    end

    local duration = self:GetReloadTime()

    self:SetFinishReload(CurTime() + duration)
    self:SetNextIdle(CurTime() + duration)
end




sound.Add({
	name = "Simple_Weapons_JCORP_LMG1.Loop",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 130,
	pitch = 100,
	sound = "weapons/ctx_jcorp_lightmachinegun/fire_loopsound.wav"
})



sound.Add({
	name = "Simple_Weapons_JCORP_LMG1.End",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 130,
	pitch = {110, 130},
	sound = "weapons/ctx_jcorp_lightmachinegun/fire_end.wav"
})



sound.Add({
	name = "Simple_Weapons_JCORP_LMG1.Sweetener",
	channel = CHAN_STATIC,
	volume = {0.8, 1},
	level = 130,
	pitch = {100, 100},
	sound = "weapons/ctx_jcorp_lightmachinegun/fire_sweeteneralso.wav"
})




sound.Add({
	name = "Simple_Weapons_JCORP_LMG1.Sweetener2",
	channel = CHAN_STATIC,
	volume = {0.5, 0.5},
	level = 130,
	pitch = {100, 100},
	sound = "weapons/ctx_jcorp_lightmachinegun/fire_sweetener.wav"
})



sound.Add({
	name = "Simple_Weapons_JCORP_LMG1.LoopBegin",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = {100, 100},
	sound = {
	"weapons/ctx_jcorp_lightmachinegun/fire_loopbegin1.wav",
	"weapons/ctx_jcorp_lightmachinegun/fire_loopbegin2.wav",
	}
})