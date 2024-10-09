local mainModule = {}
local ContentProvider = game:GetService("ContentProvider")
local isStudio = game:GetService("RunService"):IsStudio()

local TS = game:GetService("TweenService")

local camera = workspace.CurrentCamera

function mainModule.init(plr:Player)
	local self = setmetatable({}, mainModule)
	self.connections = {} -- for garbage collection

	self.plr = plr
	self.Character = self.plr.Character
	self.tweenFOV = 70

	self.mouse = self.plr:GetMouse()

	self.mouse.Icon = "http://www.roblox.com/asset/?id=12829852445"
	self.Character.Humanoid.AutoRotate = false

	self.part = Instance.new("Part", workspace)
	self.part.Name = "camPart"
	self.part.Anchored = true
	self.part.BrickColor = BrickColor.new("Really red")
	self.part.CFrame = CFrame.new(-0.5, 30.5, -1.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	self.part.CanCollide = false
	self.part.Massless = true
	self.part.Size = Vector3.new(1, 1, 1)
	self.part.Transparency = 1
	self.part.CastShadow = false

	self.Character.HumanoidRootPart.CFrame = self.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, 90, 0) -- strange ahh movement bug fix

	self.part.CFrame = self.Character.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
	self.startingDistanceFromCharacter = self.plr:DistanceFromCharacter(self.part.Position)

	camera.CameraType = Enum.CameraType.Scriptable

	self.connections["renderedStepped"] = game:GetService("RunService").RenderStepped:Connect(function()
		camera.CFrame = self.part.CFrame
		self.movePlayerTowardsCamera()

		local newCFrame = CFrame.new(self.Character.HumanoidRootPart.CFrame.Position) * CFrame.new(0, 25, 0)
		local tweenInfo = TweenInfo.new(
			0.35,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		)

		local tweenTo = TS:Create(self.part, tweenInfo, {
			CFrame = newCFrame * CFrame.Angles(math.rad(-90), 0, 0)
		})

		local cameraFOVTween = TS:Create(
			camera, 
			TweenInfo.new(
				0.5,
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.Out),
			{ FieldOfView = self.tweenFOV }
		)

		cameraFOVTween:Play()
		tweenTo:Play()
	end)

	self.movePlayerTowardsCamera = function() 
		self.Character.HumanoidRootPart.CFrame = CFrame.new(self.Character.HumanoidRootPart.Position, Vector3.new(self.mouse.Hit.Position.X, self.Character.HumanoidRootPart.Position.Y, self.mouse.Hit.Position.Z))
	end

	self.connections["humRunning"] = self.Character.Humanoid.Running:Connect(function(speed)
        if speed > 0 then
            self.tweenFOV = 75
        else
            self.tweenFOV = 70
        end
    end)

    self.connections["humDied"] = self.Character.Humanoid.Died:Connect(function()
	self.part:Destroy()

	for _,con in self.connections do
		con:Disconnect()
	end

	self.connections = {}
	self = nil
   end)

   return self
end

return mainModule
