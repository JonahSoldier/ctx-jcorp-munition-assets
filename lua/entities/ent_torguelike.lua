AddCSLuaFile()


DEFINE_BASECLASS("base_anim")

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Torguelike Rocket"
ENT.Spawnable = false


function ENT:Initialize()
    self.SpawnTime = CurTime()
    
	if SERVER then
	
        -- self:SetModel("models/weapons/w_missile.mdl")
        self:SetModel("models/xqm/jetengine.mdl")
        self:SetModelScale(0.1, 0)
        self:SetMoveType(MOVETYPE_FLY)
        self:SetSolid(SOLID_BBOX)
        self:DrawShadow(true)

        self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

        -- self:EmitSound("weapons/rpg/rocket1.wav")
    self:EmitSound("Simple_Weapons_JCORP_RocketRifle.Rocket")

        self:SetTrigger(true)
		
        ParticleEffectAttach("rocket_trail_effect", PATTACH_ABSORIGIN_FOLLOW, self, 0)

        -- Delay velocity slightly to avoid it colliding with player
        timer.Simple(0, function()
            if IsValid(self) then
                self:SetVelocity(self:GetForward() * 2250)
            end
        end)
    end
end


function ENT:Touch(ent)
    if ent == self:GetOwner() and CurTime() < (self.SpawnTime or 0) + 0.5 then return end
    if not SERVER then return end

    local owner = self:GetOwner()

    local dmginfo = DamageInfo()
    dmginfo:SetAttacker(IsValid(owner) and owner or self)
    dmginfo:SetInflictor(self)
    -- dmginfo:SetDamageType(DMG_BURN)
    dmginfo:SetDamageType(DMG_BLAST)
    dmginfo:SetDamage(120)

    util.BlastDamageInfo(dmginfo, self:GetPos(), 200)

    local effectData = EffectData()
    effectData:SetOrigin(self:GetPos())
    util.Effect("HelicopterMegaBomb", effectData)
    self:EmitSound("Simple_Weapons_JCORP_RocketRifle.Explode")
    self:EmitSound("Simple_Weapons_JCORP_RocketRifle.LFO")

    self:Remove()
end

-- function ENT:PhysicsCollide(data, phys)
    -- if not SERVER then return end

    -- local explode = ents.Create("env_explosion")
    -- explode:SetPos(self:GetPos())
    -- explode:SetOwner(self:GetOwner())
    -- explode:Spawn()
    -- explode:SetKeyValue("iMagnitude", "0") -- set to 0 so we can do custom damage
    -- explode:Fire("Explode", 0, 0)

    -- Custom damage
    -- local dmginfo = DamageInfo()
    -- dmginfo:SetAttacker(self:GetOwner())
    -- dmginfo:SetInflictor(self)
    -- dmginfo:SetDamage(80)
    -- dmginfo:SetDamageType(DMG_BURN) -- or any combo like DMG_ENERGYBEAM, etc.

    -- util.BlastDamageInfo(dmginfo, self:GetPos(), 200)

    -- self:Remove()
-- end
