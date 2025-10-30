AddCSLuaFile()


net.Receive("JImpactLight", function()
    local pos = net.ReadVector()

    local dlight = DynamicLight(LocalPlayer():EntIndex())
    if dlight then
        dlight.pos = pos
        dlight.r = 255
        dlight.g = 0
        dlight.b = 0
        dlight.brightness = 3
        dlight.Decay = 1000
        dlight.Size = 150
        dlight.DieTime = CurTime() + 0.05
    end
end)

net.Receive("JImpactLightSmall", function()
    local pos = net.ReadVector()

    local dlight = DynamicLight(LocalPlayer():EntIndex())
    if dlight then
        dlight.pos = pos
        dlight.r = 255
        dlight.g = 0
        dlight.b = 0
        dlight.brightness = 3
        dlight.Decay = 2000
        dlight.Size = 80
        dlight.DieTime = CurTime() + 0.1
    end
end)

net.Receive("JImpactLightLarge", function()
    local pos = net.ReadVector()

    local dlight = DynamicLight(LocalPlayer():EntIndex())
    if dlight then
        dlight.pos = pos
        dlight.r = 255
        dlight.g = 5
        dlight.b = 5
        dlight.brightness = 50
        dlight.Decay = 80
        dlight.Size = 30
        dlight.DieTime = CurTime() + 0.8
    end
end)