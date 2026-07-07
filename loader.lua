-- MM2 Ultimate Script for Xeno Executor
local P,R,C,U,W,L,M=game:GetService("Players"),game:GetService("RunService"),game:GetService("CoreGui"),game:GetService("UserInputService"),game:GetService("Workspace"),game:GetService("Lighting"),game:GetService("VirtualUser")
local LP,CM=P.LocalPlayer,W.CurrentCamera
local GUI=Instance.new("ScreenGui")GUI.Name="MM2_Colin"GUI.ResetOnSpawn=false GUI.Parent=C
local MF=Instance.new("Frame")MF.Size=UDim2.new(0,320,0,450)MF.Position=UDim2.new(0.7,0,0.2,0)MF.BackgroundColor3=Color3.fromRGB(20,20,20)MF.BorderSizePixel=0 MF.Active=true MF.Draggable=true MF.Parent=GUI
Instance.new("UICorner",MF).CornerRadius=UDim.new(0,10)
local TB=Instance.new("Frame")TB.Size=UDim2.new(1,0,0,40)TB.BackgroundColor3=Color3.fromRGB(30,30,30)TB.Parent=MF
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,10)
local TT=Instance.new("TextLabel")TT.Size=UDim2.new(0.7,0,1,0)TT.Position=UDim2.new(0.02,0,0,0)TT.BackgroundTransparency=1 TT.TextColor3=Color3.new(1,1,1)TT.Text="MM2 Ultimate v1.0"TT.Font=Enum.Font.SourceSansBold TT.TextSize=18 TT.TextXAlignment=Enum.TextXAlignment.Left TT.Parent=TB
local CB=Instance.new("TextButton")CB.Size=UDim2.new(0,35,0,30)CB.Position=UDim2.new(1,-40,0,5)CB.BackgroundColor3=Color3.fromRGB(220,0,0)CB.TextColor3=Color3.new(1,1,1)CB.Text="X"CB.Font=Enum.Font.SourceSansBold CB.TextSize=16 CB.Parent=MF
Instance.new("UICorner",CB).CornerRadius=UDim.new(0,8)CB.MouseButton1Click:Connect(function()GUI:Destroy()end)
local SF=Instance.new("ScrollingFrame")SF.Size=UDim2.new(1,-10,1,-45)SF.Position=UDim2.new(0,5,0,43)SF.BackgroundColor3=Color3.fromRGB(25,25,25)SF.BorderSizePixel=0 SF.ScrollBarThickness=5 SF.CanvasSize=UDim2.new(0,0,0,1000)SF.Parent=MF
local SL=Instance.new("UIListLayout")SL.Padding=UDim.new(0,5)SL.FillDirection=Enum.FillDirection.Vertical SL.SortOrder=Enum.SortOrder.LayoutOrder SL.Parent=SF

local function CT(n,f)
    local B=Instance.new("TextButton")B.Size=UDim2.new(1,-5,0,38)B.BackgroundColor3=Color3.fromRGB(50,50,50)B.TextColor3=Color3.new(1,1,1)B.Text=n.." : OFF"B.Font=Enum.Font.SourceSansBold B.TextSize=14 B.Parent=SF
    Instance.new("UICorner",B).CornerRadius=UDim.new(0,6)
    local e=false
    B.MouseButton1Click:Connect(function()
        e=not e B.Text=n.." : "..(e and "ON" or "OFF")B.BackgroundColor3=e and Color3.fromRGB(0,150,0)or Color3.fromRGB(50,50,50)
        f(e)
    end)
    return B
end

-- Silent Aim
CT("Silent Aim",function(s)
    if s then
        local old=hookmetamethod(game,"__namecall",function(self,...)
            local m=getnamecallmethod()local a={...}
            if m=="FireServer"and(tostring(self)=="Shoot"or tostring(self)=="ShootGun")and LP.Character then
                local t,cd=nil,math.huge
                for _,p in ipairs(P:GetPlayers())do
                    if p~=LP and p.Character and p.Character:FindFirstChild("Head")then
                        local ps,os=CM:WorldToScreenPoint(p.Character.Head.Position)
                        local d=(Vector2.new(ps.X,ps.Y)-Vector2.new(CM.ViewportSize.X/2,CM.ViewportSize.Y/2)).Magnitude
                        if os and d<250 and d<cd then cd=d t=p end
                    end
                end
                if t then a[1]=t.Character.Head.Position end
            end
            return old(self,unpack(a))
        end)
    end
end)

-- Hitbox Expander
CT("Hitbox Expander",function(s)
    task.spawn(function()while s and task.wait(0.3)do
        for _,p in ipairs(P:GetPlayers())do
            if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart")then
                p.Character.HumanoidRootPart.Size=Vector3.new(4,4,4)p.Character.HumanoidRootPart.Transparency=0.7
            end
        end
    end end)
end)

-- Instant Reload
CT("Instant Reload",function(s)
    task.spawn(function()while s and task.wait(0.2)do
        for _,t in ipairs(LP.Backpack:GetChildren())do
            if t:IsA("Tool")and t:FindFirstChild("Ammo")then t.Ammo.Value=99 end
        end
        local ct=LP.Character and LP.Character:FindFirstChildOfClass("Tool")
        if ct and ct:FindFirstChild("Ammo")then ct.Ammo.Value=99 end
    end end)
end)

-- Triggerbot
CT("Triggerbot",function(s)
    task.spawn(function()while s and task.wait(0.1)do
        pcall(function()
            local ray=Ray.new(CM.CFrame.Position,CM.CFrame.LookVector*500)
            local hit=W:FindPartOnRay(ray,LP.Character)
            if hit and hit.Parent:FindFirstChildOfClass("Humanoid")and hit.Parent~=LP.Character then
                local tool=LP.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Shoot")then
                    tool:FindFirstChild("Shoot"):FireServer()
                end
            end
        end)
    end end)
end)

-- Player ESP
CT("Player ESP",function(s)
    task.spawn(function()while s and task.wait(0.03)do
        local objs={}
        for _,p in ipairs(P:GetPlayers())do
            if p~=LP and p.Character and p.Character:FindFirstChild("Head")and p.Character:FindFirstChild("HumanoidRootPart")then
                local hp=CM:WorldToScreenPoint(p.Character.Head.Position+Vector3.new(0,0.5,0))
                local lp=CM:WorldToScreenPoint(p.Character.HumanoidRootPart.Position-Vector3.new(0,3,0))
                if hp.Z>0 then
                    local h=math.abs(hp.Y-lp.Y)local w=h/2
                    local bx=Drawing.new("Square")bx.Color=p.Team and p.Team.TeamColor.Color or Color3.fromRGB(255,0,0)bx.Thickness=1.5 bx.Size=Vector2.new(w,h)bx.Position=Vector2.new(hp.X-w/2,hp.Y)bx.Visible=true bx.Filled=false table.insert(objs,bx)
                    local nm=Drawing.new("Text")nm.Text=p.Name nm.Color=Color3.new(1,1,1)nm.Size=13 nm.Position=Vector2.new(hp.X,hp.Y-25)nm.Center=true nm.Visible=true table.insert(objs,nm)
                    local dist=math.floor((LP.Character.HumanoidRootPart.Position-p.Character.HumanoidRootPart.Position).Magnitude)
                    local dt=Drawing.new("Text")dt.Text=dist.."m"dt.Color=Color3.fromRGB(200,200,200)dt.Size=12 dt.Position=Vector2.new(hp.X,hp.Y-13)dt.Center=true dt.Visible=true table.insert(objs,dt)
                end
            end
        end
        task.wait(0.03)for _,obj in ipairs(objs)do obj:Remove()end
    end end)
end)

-- Coin ESP
CT("Coin ESP",function(s)
    task.spawn(function()while s and task.wait(0.1)do
        local objs={}
        for _,o in ipairs(W:GetDescendants())do
            if o.Name=="Coin"and o:IsA("BasePart")then
                local ps,os=CM:WorldToScreenPoint(o.Position)
                if os then
                    local tg=Drawing.new("Text")tg.Text="💰"tg.Color=Color3.fromRGB(255,215,0)tg.Size=18 tg.Position=Vector2.new(ps.X,ps.Y)tg.Center=true tg.Visible=true table.insert(objs,tg)
                end
            end
        end
        task.wait(0.1)for _,obj in ipairs(objs)do obj:Remove()end
    end end)
end)

-- Gun ESP
CT("Gun ESP",function(s)
    task.spawn(function()while s and task.wait(0.1)do
        local objs={}
        for _,o in ipairs(W:GetDescendants())do
            if o.Name=="GunDrop"and o:IsA("BasePart")then
                local ps,os=CM:WorldToScreenPoint(o.Position)
                if os then
                    local tg=Drawing.new("Text")tg.Text="🔫 Gun"tg.Color=Color3.fromRGB(0,150,255)tg.Size=14 tg.Position=Vector2.new(ps.X,ps.Y)tg.Center=true tg.Visible=true table.insert(objs,tg)
                end
            end
        end
        task.wait(0.1)for _,obj in ipairs(objs)do obj:Remove()end
    end end)
end)

-- Tracers
CT("Tracers",function(s)
    task.spawn(function()while s and task.wait(0.03)do
        local objs={}
        for _,p in ipairs(P:GetPlayers())do
            if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart")then
                local ps,os=CM:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
                if os then
                    local ln=Drawing.new("Line")ln.Color=Color3.fromRGB(255,255,255)ln.Thickness=1 ln.From=Vector2.new(CM.ViewportSize.X/2,CM.ViewportSize.Y)ln.To=Vector2.new(ps.X,ps.Y)ln.Visible=true table.insert(objs,ln)
                end
            end
        end
        task.wait(0.03)for _,obj in ipairs(objs)do obj:Remove()end
    end end)
end)

-- Speed Hack
CT("Speed Hack",function(s)
    R.Stepped:Connect(function()
        if s and LP.Character and LP.Character:FindFirstChild("Humanoid")then
            LP.Character.Humanoid.WalkSpeed=35
        end
    end)
end)

-- NoClip
CT("NoClip",function(s)
    R.Stepped:Connect(function()
        if s and LP.Character then
            for _,v in ipairs(LP.Character:GetDescendants())do
                if v:IsA("BasePart")then v.CanCollide=false end
            end
        end
    end)
end)

-- Infinite Jump
CT("Infinite Jump",function(s)
    U.JumpRequest:Connect(function()
        if s and LP.Character and LP.Character:FindFirstChild("Humanoid")then
            LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end)

-- Fly
CT("Fly",function(s)
    task.spawn(function()while s and task.wait()do
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")then
            local hrp=LP.Character.HumanoidRootPart
            local bg=hrp:FindFirstChild("BG")or Instance.new("BodyGyro",hrp)
            local bv=hrp:FindFirstChild("BV")or Instance.new("BodyVelocity",hrp)
            bg.Name="BG"bg.CFrame=CM.CFrame bg.MaxTorque=Vector3.new(9e9,9e9,9e9)
            bv.Name="BV"bv.MaxForce=Vector3.new(9e9,9e9,9e9)
            local vel=Vector3.new(0,0,0)
            if U:IsKeyDown(Enum.KeyCode.W)then vel=vel+CM.CFrame.LookVector*60 end
            if U:IsKeyDown(Enum.KeyCode.S)then vel=vel-CM.CFrame.LookVector*60 end
            if U:IsKeyDown(Enum.KeyCode.Space)then vel=vel+Vector3.new(0,60,0)end
            if U:IsKeyDown(Enum.KeyCode.LeftShift)then vel=vel+Vector3.new(0,-60,0)end
            bv.Velocity=vel
        end
    end end)
end)

-- Auto-Farm Coins
CT("Auto-Farm Coins",function(s)
    task.spawn(function()while s and task.wait(0.15)do
        for _,o in ipairs(W:GetDescendants())do
            if o.Name=="Coin"and o:IsA("BasePart")and LP.Character and(o.Position-LP.Character.HumanoidRootPart.Position).Magnitude<200 then
                firetouchinterest(LP.Character.HumanoidRootPart,o,0)firetouchinterest(LP.Character.HumanoidRootPart,o,1)
            end
        end
    end end)
end)

-- Auto-Pickup Gun
CT("Auto-Pickup Gun",function(s)
    task.spawn(function()while s and task.wait(0.5)do
        for _,o in ipairs(W:GetDescendants())do
            if o.Name=="GunDrop"and o:IsA("BasePart")and LP.Character and(o.Position-LP.Character.HumanoidRootPart.Position).Magnitude<80 then
                firetouchinterest(LP.Character.HumanoidRootPart,o,0)firetouchinterest(LP.Character.HumanoidRootPart,o,1)
            end
        end
    end end)
end)

-- Role Reveal
CT("Role Reveal",function(s)
    task.spawn(function()while s and task.wait(1)do
        for _,p in ipairs(P:GetPlayers())do
            if p~=LP and p.Character and p.Character:FindFirstChild("Head")then
                local r="Innocent"
                if p.Backpack:FindFirstChild("Knife")or p.Character:FindFirstChild("Knife")then r="🔪 Murderer"
                elseif p.Backpack:FindFirstChild("Gun")or p.Character:FindFirstChild("Gun")then r="🔫 Sheriff"end
                local bb=p.Character.Head:FindFirstChild("RT")or Instance.new("BillboardGui",p.Character.Head)
                bb.Name="RT"bb.Size=UDim2.new(0,120,0,35)bb.StudsOffset=Vector3.new(0,3,0)bb.AlwaysOnTop=true
                local tl=bb:FindFirstChild("TL")or Instance.new("TextLabel",bb)
                tl.Name="TL"tl.Size=UDim2.new(1,0,1,0)tl.BackgroundTransparency=1 tl.TextColor3=r=="🔪 Murderer"and Color3.fromRGB(255,0,0)or Color3.fromRGB(0,255,0)tl.Text=r tl.Font=Enum.Font.SourceSansBold tl.TextSize=16 tl.TextStrokeTransparency=0
            end
        end
    end end)
end)

-- Teleport to Killer
CT("Teleport to Killer",function(s)
    task.spawn(function()while s and task.wait(2)do
        for _,p in ipairs(P:GetPlayers())do
            if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart")and(p.Backpack:FindFirstChild("Knife")or p.Character:FindFirstChild("Knife"))then
                LP.Character.HumanoidRootPart.CFrame=p.Character.HumanoidRootPart.CFrame+Vector3.new(0,5,0)
            end
        end
    end end)
end)

-- Fullbright
CT("Fullbright",function(s)
    if s then L.Brightness=2 L.ClockTime=14 L.FogEnd=100000 L.GlobalShadows=false L.OutdoorAmbient=Color3.fromRGB(200,200,200)end
end)

-- Fog Remover
CT("Fog Remover",function(s)
    if s then L.FogEnd=1000000 L.FogStart=0 end
end)

-- Anti-AFK
CT("Anti-AFK",function(s)
    task.spawn(function()while s and task.wait(100)do
        pcall(function()M:Button2Down(Vector2.new(0,0),CM.CFrame)task.wait(0.1)M:Button2Up(Vector2.new(0,0),CM.CFrame)end)
    end end)
end)

print("✅ MM2 Ultimate Script Loaded - GUI visible top-right")
