local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")

local Camera = workspace.Camera




-- Settings
local GitHubUserlink = "https://raw.githubusercontent.com/madrwr/Clover/main/"
local HighLevelAccess = false

local AutoRun = false
local BodyVelocity = {-17.5, 0, -17.5}
local HatVelocity = {-17.5, 0, -17.5}

local HeadScale = 1.5










-- Module prepare
function GetModule(module)
	if HighLevelAccess then
		local Success, Returned = pcall(function() -- // HttpsGetAsync is a hidden function that is unlocked by the executor, wrapped incase of 
			return loadstring(game:HttpGetAsync(GitHubUserlink .. module .. ".lua"))()
		end)
		
		return Success and Returned or nil
	else
		return require(script.Parent:WaitForChild(module))
	end
end

local CharacterModule = GetModule("Character")

local Library = CharacterModule.Library


if not CharacterModule then
	warn("Something has gone wrong")
	return function(...)end
end



--
function Start()
	local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	Character:WaitForChild("HumanoidRootPart")
	Character:WaitForChild("Torso")
	Character:WaitForChild("Humanoid")
	
	if Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Character:WaitForChild("UpperTorso")
		Character:WaitForChild("LowerTorso")
	else
		Character:WaitForChild("Torso")
	end
	
	
	local vrparts, rhand, lhand, header, ToolTrack, HeadTrack, ratt, latt = CharacterModule.CreateVRNessecities(HeadScale)
	local RUA, RLA, LUA, LLA, RH, LH, torso, rightarm, leftarm, rightleg, leftleg, motor = CharacterModule.CreateFakeArms(Character, Character.Humanoid.RigType==Enum.HumanoidRigType.R15)
	local fakerightarm, fakeleftarm, RHA, LHA = CharacterModule.CreateVRObjects(Character, rhand, lhand)
	
	local rightShoulder, RSHOULDER_C0_CACHE = Library.Motor6D(torso, RUA, CFrame.new(1.5,1,0), CFrame.new(0,1,0), "RS");
	local rightElbow, RELBOW_C0_CACHE = Library.Motor6D(RUA, RLA, CFrame.new(0,-1,0), CFrame.new(0,1,0), "RE");
	local rightWrist = Library.Motor6D(RLA, RH, CFrame.new(0,-0.5,0), CFrame.new(0,0.5,0), "RW");
	local leftShoulder, LSHOULDER_C0_CACHE = Library.Motor6D(torso, LUA, CFrame.new(-1.5,1,0), CFrame.new(0,1,0), "LS");
	local leftElbow, LELBOW_C0_CACHE = Library.Motor6D(LUA, LLA, CFrame.new(0,-1,0), CFrame.new(0,1,0), "LE");
	local leftWrist = Library.Motor6D(LLA, LH, CFrame.new(0,-0.5,0), CFrame.new(0,0.5,0), "LW");
	
	local RUPPER_LENGTH	= math.abs(rightShoulder.C1.Y) + math.abs(rightElbow.C0.Y)
	local RLOWER_LENGTH	= math.abs(rightElbow.C1.Y) + math.abs(rightWrist.C0.Y) + math.abs(rightWrist.C1.Y)
	local LUPPER_LENGTH	= math.abs(leftShoulder.C1.Y) + math.abs(leftElbow.C0.Y)
	local LLOWER_LENGTH	= math.abs(leftElbow.C1.Y) + math.abs(leftWrist.C0.Y) + math.abs(leftWrist.C1.Y)
	
	
	
	for Index, Part in pairs(Character:GetDescendants()) do
		if Part:IsA("BasePart") then
			if Part ~= Character.HumanoidRootPart and Part ~= fakeleftarm and Part ~= fakerightarm then
				local bv = Instance.new("BodyVelocity")
				bv.Velocity = Vector3.new(0,0,0)
				bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
				bv.P = 9000
				bv.Parent = Part
				RunService.Heartbeat:connect(function()
					Part.AssemblyLinearVelocity = Vector3.new(70,0,0)
				end)

				for i,v in pairs(Character:GetChildren()) do
					if v:IsA("BasePart") then
						Library.NoCollide(Part, v)
					end
				end

				if Part.Name:find("Arm") or Part.Name:find("Leg") or Part.Name:find("tHand") or Part.Name:find("Foot") then
					Part.Transparency = 0
					RunService.Stepped:connect(function()
						Part.CanCollide = false
					end)
				elseif Part == RH or Part == LH or Part == RLA or Part == LLA or Part == RUA or Part == LUA  then
					Part.Transparency = 1
				elseif Part.Parent:IsA("Tool") then
					Part.Parent.Parent = Players.LocalPlayer.Backpack
				else
					Part.Transparency = 0.6
				end
			elseif Part == fakeleftarm or Part == fakerightarm then
				Part.Transparency = 1
				Part.CustomPhysicalProperties = PhysicalProperties.new(10, 1000, -100, 100,100)
				Part.Massless = false
			else
				Part.CustomPhysicalProperties = PhysicalProperties.new(20, 100, 0, 100,100)
				game:GetService("RunService").Stepped:connect(function()
					Part.CanCollide = true
				end)
			end
			if Part == torso or Part.Name == "Head" then
				game:GetService("RunService").Stepped:connect(function()
					Part.CanCollide = false
				end)
			end
			if Part.Name == "LowerTorso" or Part.Name:find("Foot") then
				Part:Destroy()
			end
		end
	end
	
	wait(.1)

	Library.Align(torso, header, Vector3.new(0,-.8,0))

	if Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Library.Align(Character["RightUpperLeg"],RUA, Vector3.new(0,.5,0), Vector3.new(0,0,0))
		Library.Align(Character["RightLowerLeg"],RUA, Vector3.new(0,-.5,0), Vector3.new(0,0,0))
		Library.Align(Character["RightUpperArm"],RLA, Vector3.new(0,.5,0), Vector3.new(0,0,0))
		Library.Align(Character["RightLowerArm"],RLA, Vector3.new(0,-.5,0), Vector3.new(0,0,0))
		Library.Align(Character["LeftUpperLeg"],LUA, Vector3.new(0,.5,0), Vector3.new(0,0,0))
		Library.Align(Character["LeftLowerLeg"],LUA, Vector3.new(0,-.5,0), Vector3.new(0,0,0))
		Library.Align(Character["LeftUpperArm"],LLA, Vector3.new(0,.5,0), Vector3.new(0,0,0))
		Library.Align(Character["LeftLowerArm"],LLA, Vector3.new(0,-.5,0), Vector3.new(0,0,0))
		Library.AlignHand(Character["RightHand"], RH, fakerightarm, Vector3.new(0,-.2,0), Vector3.new(0,-90,0))
		Library.AlignHand(Character["LeftHand"], LH, fakeleftarm, Vector3.new(0,-.2,0), Vector3.new(0,-90,0))
	else
		Library.Align(rightleg,RUA, Vector3.new(0,0,0), Vector3.new(0,0,0))
		Library.Align(rightarm,RLA, Vector3.new(0,0,0), Vector3.new(0,-90,0))
		Library.Align(leftleg,LUA, Vector3.new(0,0,0), Vector3.new(0,0,0))
		Library.Align(leftarm,LLA, Vector3.new(0,0,0), Vector3.new(0,-90,0))
	end
	
	
	
	--
	local LastUserPosition = VRService:GetUserCFrame(Enum.UserCFrame.Head).Position
	local Turn = CFrame.fromEulerAnglesXYZ(0,0,0)
	local IsTurning = false
	
	--local CameraPosition = Camera.CFrame


	--	
	local OnStepped
	OnStepped = RunService.Stepped:Connect(function()
		rightShoulder.Transform = CFrame.new()
		rightElbow.Transform = CFrame.new()
		rightWrist.Transform = CFrame.new()
		leftShoulder.Transform = CFrame.new()
		leftElbow.Transform = CFrame.new()
		leftWrist.Transform = CFrame.new()
	end)


	local OnRenderStepped
	OnRenderStepped = RunService.RenderStepped:Connect(function(Delta)
		if not (Character and Character:FindFirstChild("HumanoidRootPart")) then warn("No Character or HumanoidRootPart") return end
		local UserCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)


		Camera.CameraSubject = nil
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.HeadScale = HeadScale
		
		--
		local RshoulderCFrame = torso.CFrame * RSHOULDER_C0_CACHE
		local RplaneCF, RshoulderAngle, RelbowAngle = Library.SolveIK(RshoulderCFrame, fakerightarm.Position, RUPPER_LENGTH, RLOWER_LENGTH)
		local LshoulderCFrame = torso.CFrame * LSHOULDER_C0_CACHE
		local LplaneCF, LshoulderAngle, LelbowAngle = Library.SolveIK(LshoulderCFrame, fakeleftarm.Position, LUPPER_LENGTH, LLOWER_LENGTH)
		rightShoulder.C0 = torso.CFrame:toObjectSpace(RplaneCF) * CFrame.Angles(RshoulderAngle, 0, 0)
		rightElbow.C0 = RELBOW_C0_CACHE * CFrame.Angles(RelbowAngle, 0, 0)
		leftShoulder.C0 = torso.CFrame:toObjectSpace(LplaneCF) * CFrame.Angles(LshoulderAngle, 0, 0)
		leftElbow.C0 = LELBOW_C0_CACHE * CFrame.Angles(LelbowAngle, 0, 0)



		RHA.WorldCFrame = rhand.CFrame
		LHA.WorldCFrame = lhand.CFrame
		
		
		local _CFrame = CFrame.new((Character.HumanoidRootPart.Position - UserCFrame.Position * HeadScale) + Vector3.new(0,1.5,0)) * Turn;
		Camera.CFrame = (_CFrame * CFrame.fromEulerAnglesXYZ(CFrame.new(UserCFrame.p * HeadScale):ToEulerAnglesXYZ()))
		
		
		
		for Index, Hat in pairs(Character:GetChildren()) do
			if Hat:IsA("Accessory") and Hat:FindFirstChild("Handle") then
				Hat.Handle.Transparency = 1 
			end
		end

		LastUserPosition = UserCFrame.Position
	end)


	--
	ContextActionService:BindAction("ThumbStick2", function(Name, State, Input)
		if not IsTurning and math.abs(Input.Position.X) > 0.7 then
			IsTurning = true

			local TurnDirection = 30 * -math.sign(Input.Position.X)				
			Turn = Turn * CFrame.fromEulerAnglesXYZ(0, math.rad(TurnDirection), 0)
		elseif IsTurning and math.abs(Input.Position.X) < 0.7 then
			IsTurning = false
		end
	end, false, Enum.KeyCode.Thumbstick2)
	
	
	Character.HumanoidRootPart:GetPropertyChangedSignal("Position"):Connect(function()
		Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
		fakeleftarm.Velocity = Vector3.new(0,0,0)
		fakerightarm.Velocity = Vector3.new(0,0,0)
		Character.HumanoidRootPart.Anchored = true
		torso.CFrame = Character.HumanoidRootPart.CFrame
		fakeleftarm.CFrame = Character.HumanoidRootPart.CFrame
		fakerightarm.CFrame = Character.HumanoidRootPart.CFrame
		wait(2)
		Character.HumanoidRootPart.Anchored = false
		for i = 1,4 do
			Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
			fakeleftarm.Velocity = Vector3.new(0,0,0)
			fakerightarm.Velocity = Vector3.new(0,0,0)
		end
	end)
	

	--
	if HighLevelAccess then
		settings().Physics.AllowSleep = false 
		settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
		
		for Index, _Instance in pairs(Character:GetChildren()) do
			for _, Connection in pairs(getconnections(_Instance.ChildAdded)) do
				Connection:Disable()
			end
		end
	end
end


return function(Data)
	if Data.HighLevelAccess then
		HighLevelAccess = Data.HighLevelAccess
	end
	
	if Data.AutoRun then
		AutoRun = Data.AutoRun
	end
	
	if Data.BodyVelocity then
		BodyVelocity = Data.BodyVelocity
	end
	
	if Data.HatVelocity then
		HatVelocity = Data.HatVelocity
	end
	
	Start()
end