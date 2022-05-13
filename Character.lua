local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()

local Camera = workspace.CurrentCamera

local BodyTransparency = 0.6


local CharacterModule = {}

function GetMotorForLimb(Limb)
	for _, Motor in next, Character:GetDescendants() do
		if Motor:IsA("Motor6D") and Motor.Part1 == Limb then
			return Motor
		end
	end
end

--
function CharacterModule.CreateVRNessecities(HeadScale)
	local vrparts, rhand, lhand, header, ToolTrack, HeadTrack, ratt, latt do
		vrparts = Instance.new("Folder", workspace); vrparts.Name = "VRParts"
		rhand = Instance.new("Part", vrparts); rhand.Anchored = true; rhand.CanCollide = false; rhand.Transparency = 1;
		ratt = Instance.new("Attachment", rhand);
		lhand = Instance.new("Part", vrparts); lhand.Anchored = true; lhand.CanCollide = false; lhand.Transparency = 1;
		latt = Instance.new("Attachment", lhand);
		header = Instance.new("Part", vrparts); header.Anchored = true; header.CanCollide = false; header.Transparency = 1;
		ToolTrack = Instance.new("Part", vrparts); ToolTrack.Anchored = true; ToolTrack.CanCollide = false; ToolTrack.Transparency = 1;
		HeadTrack = Instance.new("Part", vrparts); HeadTrack.Anchored = true; HeadTrack.CanCollide = false; HeadTrack.Transparency = 1;

		VRService.UserCFrameChanged:Connect(function()
			local LeftHandCFrame = VRService:GetUserCFrame(Enum.UserCFrame.LeftHand)
			local RightHandCFrame = VRService:GetUserCFrame(Enum.UserCFrame.RightHand)
			local HeadCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
			rhand.CFrame = (Camera.CFrame*CFrame.new(RightHandCFrame.p*HeadScale))*CFrame.fromEulerAnglesXYZ(RightHandCFrame:ToEulerAnglesXYZ())*CFrame.Angles(math.rad(90), math.rad(90), math.rad(0))
			lhand.CFrame = (Camera.CFrame*CFrame.new(LeftHandCFrame.p*HeadScale))*CFrame.fromEulerAnglesXYZ(LeftHandCFrame:ToEulerAnglesXYZ())*CFrame.Angles(math.rad(90), math.rad(90), math.rad(0))
			header.CFrame = (Camera.CFrame*CFrame.new(HeadCFrame.p*HeadScale)) *CFrame.fromEulerAnglesXYZ(HeadCFrame:ToEulerAnglesXYZ())
			ToolTrack.CFrame = (Camera.CFrame*CFrame.new(RightHandCFrame.p*HeadScale))*CFrame.fromEulerAnglesXYZ(RightHandCFrame:ToEulerAnglesXYZ())*CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)) * CFrame.new(0,1,0)
		end)
	end
	
	return vrparts, rhand, lhand, header, ToolTrack, HeadTrack, ratt, latt
end

function CharacterModule.CreateFakeArms(Character, R15)
	local torso = R15 and Character["UpperTorso"] or Character["Torso"]
	local rightarm = R15 and Character["RightHand"] or Character["Right Arm"]
	local leftarm = R15 and Character["LeftHand"] or Character["Left Arm"]
	local rightleg = R15 and Character["RightUpperLeg"] or Character:FindFirstChild("Right Leg")
	local leftleg = R15 and Character["LeftUpperLeg"] or Character:FindFirstChild("Left Leg")
	local motor = Character:FindFirstChild("LowerTorso") and Character.UpperTorso:FindFirstChild("LowerTorso") or GetMotorForLimb(Character:WaitForChild("HumanoidRootPart")) if motor then motor:Destroy() end

	local RUA, RLA, LUA, LLA, RH, LH =
		Instance.new("Part", Character),
		Instance.new("Part", Character),
		Instance.new("Part", Character),
		Instance.new("Part", Character),
		Instance.new("Part", Character), 
		Instance.new("Part", Character)


	do
		RUA.Name = "RUA [Fake]"; RUA.Size = Vector3.new(1, 2, 1); RUA.CanCollide = false;
		RLA.Name = "RLA [Fake]"; RLA.Size = Vector3.new(1, 2, 1); RLA.CanCollide = false;
		LUA.Name = "LUA [Fake]"; LUA.Size = Vector3.new(1, 2, 1); LUA.CanCollide = false;
		LLA.Name = "LLA [Fake]"; LLA.Size = Vector3.new(1, 2, 1); RUA.CanCollide = false; 
		RH.Name = "RH [Fake]"; RH.Size = Vector3.new(.7,.7,.7); RH.CanCollide = false;
		LH.Name = "LH [Fake]"; LH.Size = Vector3.new(.7,.7,.7); LH.CanCollide = false; 
	end
	
	return RUA, RLA, LUA, LLA, RH, LH, torso, rightarm, leftarm, rightleg, leftleg, motor
end

function CharacterModule.CreateVRObjects(Character, rhand, lhand)
	local fakerightarm, fakeleftarm, RHA, LHA do
		fakeleftarm, fakerightarm = Instance.new("Part", Character), Instance.new("Part", Character)
		fakeleftarm.CFrame = lhand.CFrame
		fakeleftarm.Name = "Fake Left"
		fakeleftarm.Size = Vector3.new(1,1,.5)
		fakeleftarm.Transparency = 1
		fakerightarm.CFrame = rhand.CFrame
		fakerightarm.Name = "Fake Right"
		fakerightarm.Size = Vector3.new(1,1,.5)
		fakerightarm.Transparency = 1

		local nocol = Character.Library.NoCollide(fakeleftarm, fakerightarm)

		local Rap = Instance.new("AlignPosition", fakerightarm);
		Rap.RigidityEnabled = false; Rap.ReactionForceEnabled = true; Rap.ApplyAtCenterOfMass = false; Rap.MaxForce = 10000000; Rap.MaxVelocity = math.huge/9e110; Rap.Responsiveness = 75;
		local Rao = Instance.new("AlignOrientation", fakerightarm);
		Rao.RigidityEnabled = false; Rao.ReactionTorqueEnabled = false; Rao.PrimaryAxisOnly = false; Rao.MaxTorque = 10000000; Rao.MaxAngularVelocity = math.huge/9e110; Rao.Responsiveness = 75;
		local Lap = Instance.new("AlignPosition", fakeleftarm);
		Lap.RigidityEnabled = false; Lap.ReactionForceEnabled = true; Lap.ApplyAtCenterOfMass = false; Lap.MaxForce = 10000000; Lap.MaxVelocity = math.huge/9e110; Lap.Responsiveness = 75;
		local Lao = Instance.new("AlignOrientation", fakeleftarm); 
		Lao.RigidityEnabled = false; Lao.ReactionTorqueEnabled = false; Lao.PrimaryAxisOnly = false; Lao.MaxTorque = 10000000; Lao.MaxAngularVelocity = math.huge/9e110; Lao.Responsiveness = 75;

		local Ratt = Instance.new("Attachment", fakerightarm)
		RHA = Instance.new("Attachment", Character.HumanoidRootPart)
		local Latt = Instance.new("Attachment", fakeleftarm)
		LHA = Instance.new("Attachment", Character.HumanoidRootPart)

		Rap.Attachment0 = Ratt; Rap.Attachment1 = RHA
		Rao.Attachment0 = Ratt; Rao.Attachment1 = RHA
		Lap.Attachment0 = Latt; Lap.Attachment1 = LHA
		Lao.Attachment0 = Latt; Lao.Attachment1 = LHA
	end
	
	return fakerightarm, fakeleftarm, RHA, LHA
end


CharacterModule.Library = {
	NoCollide = function(a, b)
		local NoCollision = Instance.new("NoCollisionConstraint")
		NoCollision.Part0 = a
		NoCollision.Part1 = b
		NoCollision.Parent = a
	end,

	Motor6D = function(part0, part1, c0, c1, name)
		part1.Transparency = 1;
		part1.Massless = true
		local motor = Instance.new("Motor6D", part1); motor.Name = name; motor.Part0 = part0; motor.Part1 = part1; motor.C0 = c0; motor.C1 = c1;
		return motor, motor.C0
	end,

	SolveIK = function(originCF, targetPos, l1, l2)	
		local localized = originCF:pointToObjectSpace(targetPos)
		local localizedUnit = localized.unit
		local l3 = localized.magnitude
		local axis = Vector3.new(0, 0, -1):Cross(localizedUnit)
		local angle = math.acos(-localizedUnit.Z)
		local planeCF = originCF * CFrame.fromAxisAngle(axis, angle)
		if l3 < math.max(l2, l1) - math.min(l2, l1) then
			return planeCF * CFrame.new(0, 0,  math.max(l2, l1) - math.min(l2, l1) - l3), -math.pi/2, math.pi
		elseif l3 > l1 + l2 then
			return planeCF, math.pi/2, 0
		else
			local a1 = -math.acos((-(l2 * l2) + (l1 * l1) + (l3 * l3)) / (2 * l1 * l3))
			local a2 = math.acos(((l2  * l2) - (l1 * l1) + (l3 * l3)) / (2 * l2 * l3))
			return planeCF, a1 + math.pi/2, a2 - a1
		end
	end,

	GetMotorForLimb = function(Limb)
		for _, Motor in next, Character:GetDescendants() do
			if Motor:IsA("Motor6D") and Motor.Part1 == Limb then
				return Motor
			end
		end
	end,

	Align = function(a, b, pos, rot, options)
		if typeof(options) ~= 'table' then
			options = {type = "None", resp = 200, length = 5, reactiontorque = false, reactionforce = false}
		end
		local a1
		local att0, att1 do
			att0 = a:IsA("Accessory") and Instance.new("Attachment", a.Handle) or Instance.new("Attachment", a)
			att1 = Instance.new("Attachment", b); 
			att1.Position = pos or Vector3.new(0,0,0); att1.Orientation = rot or Vector3.new(0,0,0);
		end

		local Handle = a:IsA("Accessory") and a.Handle or a;
		Handle.Massless = true;
		Handle.CanCollide = false;

		if a:IsA("Accessory") then Handle.AccessoryWeld:Destroy()  Handle:FindFirstChildOfClass("SpecialMesh"):Destroy()end
		local Motor = GetMotorForLimb(a); if Motor then Motor:Destroy() end

		if options.type == "rope" then 
			att0.Position = rot
			local al = Instance.new("RopeConstraint", Handle);
			al.Attachment0 = att0; al.Attachment1 = att1;
			al.Length = options.length or 0.5
		elseif options.type == "ball" then
			att0.Position = rot
			local al = Instance.new("BallSocketConstraint", Handle)
			al.Attachment0 = att0
			al.Attachment1 = att1
			al.Restitution = 1
			al.LimitsEnabled = true
			al.MaxFrictionTorque = 10
			al.TwistLimitsEnabled = true
			al.UpperAngle = 50
			al.TwistLowerAngle = 10
			al.TwistUpperAngle = -100
		elseif type == "hinge" then
			att0.Position = rot
			local al = Instance.new("HingeConstraint", Handle)
			al.Attachment0 = att0
			al.Attachment1 = att1
		else
			local al = Instance.new("AlignPosition", Handle);
			al.Attachment0 = att0; al.Attachment1 = att1;
			al.RigidityEnabled = true;
			al.ReactionForceEnabled = options.reactionforce or false;
			al.ApplyAtCenterOfMass = true;
			al.MaxForce = 10000000;
			al.MaxVelocity = math.huge/9e110;
			al.Responsiveness = options.resp or 200;
			local ao = Instance.new("AlignOrientation", Handle);    
			ao.Attachment0 = att0; ao.Attachment1 = att1;
			ao.RigidityEnabled = true;
			ao.ReactionTorqueEnabled = options.reactiontorque or true;
			ao.PrimaryAxisOnly = false;
			ao.MaxTorque = 10000000;
			ao.MaxAngularVelocity = math.huge/9e110;
			ao.Responsiveness = 200;
		end
		return att1
	end,

	AlignHand = function(hand, pospart, rotpart, pos, rot)
		local Motor = GetMotorForLimb(hand); if Motor then Motor:Destroy() end

		local handatt = Instance.new("Attachment", hand)
		local posatt = Instance.new("Attachment", pospart)
		posatt.Position = pos or Vector3.new(0,0,0)
		local rotatt = Instance.new("Attachment", rotpart)
		rotatt.Orientation = rot or Vector3.new(0,0,0)

		local al = Instance.new("AlignPosition", hand);
		al.RigidityEnabled = true;
		al.ReactionForceEnabled = false;
		al.ApplyAtCenterOfMass = true;
		al.MaxForce = 10000000;
		al.MaxVelocity = math.huge/9e110;
		al.Responsiveness = 200;
		local ao = Instance.new("AlignOrientation", hand);    
		ao.RigidityEnabled = true;
		ao.ReactionTorqueEnabled = false;
		ao.PrimaryAxisOnly = false;
		ao.MaxTorque = 10000000;
		ao.MaxAngularVelocity = math.huge/9e110;
		ao.Responsiveness = 200;

		al.Attachment0 = handatt
		al.Attachment1 = posatt

		ao.Attachment0 = handatt
		ao.Attachment1 = rotatt
	end

}

return CharacterModule