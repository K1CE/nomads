local NOrbitUnit = import('/lua/nomadsunits.lua').NOrbitUnit
local OrbitalGun = import('/lua/nomadsweapons.lua').OrbitalGun

---@class XEA0002 : TAirUnit
xno2302 = Class(NOrbitUnit) {
    DestroyNoFallRandomChance = 100,

     Weapons = {
        MainGun = Class(OrbitalGun) {
            CreateProjectileAtMuzzle = function(self, muzzle)
                local bp = self:GetBlueprint()
                if bp.Audio.FireSpecial then
                    self:PlaySound(bp.Audio.FireSpecial)
                end
                
                --allow the projectile to transfer veterancy to its parent unit
                local proj = OrbitalGun.CreateProjectileAtMuzzle(self, muzzle)
                proj.Launcher = self.unit.parent or proj.Launcher
            end,
    },

    OnDestroy = function(self)
        if not self.IsDying and self.Parent then
            self.Parent.Satellite = nil
            if self:GetAIBrain().BrainType ~= 'Human' then
                IssueBuildFactory({ self.Parent }, 'XNO2302', 1)
            end
        end
        NOrbitUnit.OnDestroy(self)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.IsDying then
            return
        end

       -- local wep = self:GetWeaponByLabel('OrbitalDeathLaserWeapon')
       -- for _, v in wep.Beams do
        --    v.Beam:Disable()
       -- end

        self.IsDying = true

        if self.Parent then
            self.Parent.Satellite = nil
            if self:GetAIBrain().BrainType ~= 'Human' then
                IssueBuildFactory({ self.Parent }, 'XNO2302', 1)
            end
        end

        NOrbitUnit.OnKilled(self, instigator, type, overkillRatio)

        local vx, vy, vz = self:GetVelocity()

        -- randomize falling animation to prevent cntrl-k on nuke abuse
        -- use default animation if x or z speed > 0.1
        if math.abs(vx) < 0.1 and math.abs(vz) < 0.1 then
            self:AttachBoneTo(0, self.colliderProj, 'anchor')
            self.colliderProj:SetLocalAngularVelocity(0.5, 0.5, 0.5)
            local rng = Random(1, 8)
            local randomSetups = {
                { x = 1, z = 1 },
                { x = 1, z = 0 },
                { x = 1, z = -1 },
                { x = 0, z = 1 },
                { x = -1, z = -1 },
                { x = -1, z = 0 },
                { x = -1, z = 1 },
                { x = 0, z = -1 },
            }
            local x = randomSetups[rng].x
            local z = randomSetups[rng].z

            if x > 0 then
                x = x + Random(0, 8) / 10
            elseif x < 0 then
                x = x - Random(0, 8) / 10
            else
                if Random(1, 2) == 1 then
                    x = x + Random(0, 8) / 10
                else
                    x = x - Random(0, 8) / 10
                end
            end

            if z > 0 then
                z = z + Random(0, 8) / 10
            elseif z < 0 then
                z = z - Random(0, 8) / 10
            else
                if Random(1, 2) == 1 then
                    z = z + Random(0, 8) / 10
                else
                    z = z - Random(0, 8) / 10
                end
            end

            self.colliderProj:SetVelocity(x, 0, z)
        end
    end,

    --Open = function(self)
    --    ChangeState(self, self.OpenState)
   -- end,

   -- OpenState = State() {
    --    Main = function(self)
            -- Create the animator to open the fins
           -- self.OpenAnim = CreateAnimator(self)
           -- self.Trash:Add(self.OpenAnim)

            -- Play the fist part of the animation
            --self.OpenAnim:PlayAnim('/units/XEA0002/xea0002_aopen01.sca')
           -- WaitFor(self.OpenAnim)

            -- Hide desired bones and play part two
           -- for _, v in self.HideBones do
           --     self:HideBone(v, true)
          --  end
          --  self.OpenAnim:PlayAnim('/units/XEA0002/xea0002_aopen02.sca')
       -- end,
    },
}

TypeClass = xno2302
