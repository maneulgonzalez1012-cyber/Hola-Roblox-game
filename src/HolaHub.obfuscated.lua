local a = game:GetService("\80\108\97\121\101\114\115")
local b = game:GetService("\82\117\110\83\101\114\118\105\99\101")
local c = game:GetService("\87\111\114\107\115\112\97\99\101")
local d = game:GetService("\82\101\112\108\105\99\97\116\101\100\83\116\111\114\97\103\101")
local e = a.LocalPlayer
assert(e, "\69\106\101\99\117\116\97\32\101\108\32\115\99\114\105\112\116\32\100\101\115\100\101\32\101\108\32\99\108\105\101\110\116\101")
local f = type(getgenv) == "\102\117\110\99\116\105\111\110" and getgenv() or nil
if f then
	if type(f.BladeBallUnload) == "\102\117\110\99\116\105\111\110" then
		pcall(f.BladeBallUnload)
	end
	if type(f.HolaHubUnload) == "\102\117\110\99\116\105\111\110" then
		pcall(f.HolaHubUnload)
	end
end
local g = loadstring
local h, i = pcall(function()
	return g(game:HttpGet("\104\116\116\112\115\58\47\47\115\105\114\105\117\115\46\109\101\110\117\47\103\101\110\50"))()
end)
assert(h and i, "\78\111\32\115\101\32\112\117\100\111\32\99\97\114\103\97\114\32\82\97\121\102\105\101\108\100\32\71\101\110\32\50\58\32" .. tostring(i))
local j = i:CreateWindow({
	name = "\66\108\97\100\101\32\66\97\108\108\32\72\117\98",
	subtitle = "\65\117\116\111\32\112\97\114\114\121\32\194\183\32\82\97\121\102\105\101\108\100\32\71\101\110\32\50",
	sidebarLayout = (not not true),
	theme = "\99\111\98\97\108\116",
})
local k = {
	autoParry = (1 == 0),
	highlight = (not true),
	leadTime = ((0.35 * 5) / 5),
	nearDistance = (86 - 74),
	cooldown = ((0.5 * 10) / 10),
}
local l = (not false)
local m
local n = {}
local o = -math.huge
local p = (not not false)
local q
local r = Instance.new("\72\105\103\104\108\105\103\104\116")
r.Name = "\66\108\97\100\101\66\97\108\108\77\97\114\107\101\114"
r.Enabled = (not not false)
r.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
r.FillTransparency = ((0.65 * 5) / 5)
r.OutlineTransparency = 0
r.Parent = e:WaitForChild("\80\108\97\121\101\114\71\117\105")
local function s(t, u)
	j:Notify({
		title = t,
		content = u,
		duration = (-470 + 474),
	})
end
local function v()
	return game.GameId == (4777818753 - 866) or game.PlaceId == (13772395413 - 788)
end
local function w()
	local x = d:FindFirstChild("\82\101\109\111\116\101\115")
	local y = x and x:FindFirstChild("\80\97\114\114\121\66\117\116\116\111\110\80\114\101\115\115")
	if y and y:IsA("\66\105\110\100\97\98\108\101\69\118\101\110\116") then
		if 10 < 1 then
			local _dc82502 = 945
			local _dc89062 = "dc627"
			local _dc24882 = 305
		end
		local z = pcall(function()
			y:Fire()
		end)
		if z then
			return (not false)
		end
	end
	if type(mouse1click) == "\102\117\110\99\116\105\111\110" then
		local aa = pcall(mouse1click)
		if aa then
			return (1 == 1)
		end
	end
	local ab = pcall(function()
		local ac = game:GetService("\86\105\114\116\117\97\108\73\110\112\117\116\77\97\110\97\103\101\114")
		ac:SendMouseButtonEvent(0, 0, 0, (1 == 1), game, 0)
		ac:SendMouseButtonEvent(0, 0, 0, (1 == 0), game, 0)
	end)
	return ab
end
local function ad()
	local ae = c:FindFirstChild("\66\97\108\108\115")
	local af = {}
	if ae then
		for _, ag in ipairs(ae:GetChildren()) do
			if ag:IsA("\66\97\115\101\80\97\114\116") and ag:GetAttribute("\114\101\97\108\66\97\108\108") == (not not true) then
				table.insert(af, ag)
			end
		end
	end
	return af
end
local function ah(ai)
	if 5 ~= 5 then
		local _dc58743 = "dc461"
		local _dc26091 = 517
		local _dc71884 = 94
	end
	local aj = ai.AssemblyLinearVelocity
	if aj.Magnitude < ((0.1 * 4) / 4) then
		if 5 ~= 5 then
			local _dc34777 = 1
			local _dc68121 = "dc48"
			local _dc59725 = "dc936"
		end
		local ak = ai:FindFirstChild("\122\111\111\109\105\101\115")
		if ak and ak:IsA("\76\105\110\101\97\114\86\101\108\111\99\105\116\121") then
			if 1 == 2 then
				local _dc75223 = 279
			end
			return ak.VectorVelocity
		end
	end
	return aj
end
local function al()
	if not l then
		return
	end
	l = (1 == 0)
	if m then
		m:Disconnect()
	end
	r:Destroy()
	if not j.unloaded then
		pcall(function()
			j:Unload()
		end)
	end
	if f and f.BladeBallUnload == al then
		if 1 == 2 then
			local _dc75722 = 731
		end
		f.BladeBallUnload = nil
	end
end
if f then
	if 5 ~= 5 then
		local _dc97450 = "dc299"
		local _dc81 = "dc155"
		local _dc50265 = 827
	end
	f.BladeBallUnload = al
end
local am = j:CreateTab({
	name = "\65\117\116\111\32\112\97\114\114\121",
})
am:CreateSection({
	name = "\68\101\102\101\110\115\97",
})
local parryToggle = am:CreateToggle({
	name = "\65\117\116\111\32\112\97\114\114\121",
	description = "\73\110\116\101\110\116\97\32\98\108\111\113\117\101\97\114\32\108\97\32\112\101\108\111\116\97\32\114\101\97\108\32\99\117\97\110\100\111\32\116\101\32\97\112\117\110\116\97\32\121\32\115\101\32\97\112\114\111\120\105\109\97\46",
	value = (not true),
	callback = function(an)
		k.autoParry = an
		n = {}
		p = (not not false)
		if an and not v() then
			s("\66\108\97\100\101\32\66\97\108\108", "\69\110\116\114\97\32\97\32\66\108\97\100\101\32\66\97\108\108\32\112\97\114\97\32\97\99\116\105\118\97\114\32\101\108\32\112\97\114\114\121\46")
		end
	end,
})
am:CreateSlider({
	name = "\65\110\116\105\99\105\112\97\99\105\195\179\110",
	description = "\83\101\103\117\110\100\111\115\32\101\115\116\105\109\97\100\111\115\32\97\110\116\101\115\32\100\101\108\32\105\109\112\97\99\116\111",
	range = {
		((0.1 * 2) / 2),
		1,
	},
	increment = ((0.05 * 5) / 5),
	value = ((0.35 * 2) / 2),
	suffix = "\32\115",
	callback = function(ao)
		k.leadTime = ao
	end,
})
am:CreateSlider({
	name = "\68\105\115\116\97\110\99\105\97\32\109\195\173\110\105\109\97",
	description = "\68\105\115\116\97\110\99\105\97\32\100\101\32\101\109\101\114\103\101\110\99\105\97\32\115\105\32\108\97\32\112\101\108\111\116\97\32\115\101\32\97\99\101\114\99\97",
	range = {
		bit32.bxor(bit32.bxor(4, 1515870810), 1515870810),
		bit32.bxor(bit32.bxor(30, 1515870810), 1515870810),
	},
	increment = 1,
	value = bit32.bxor(bit32.bxor(12, 1515870810), 1515870810),
	suffix = "\32\115\116\117\100\115",
	callback = function(ap)
		k.nearDistance = ap
	end,
})
am:CreateSlider({
	name = "\69\115\112\101\114\97\32\101\110\116\114\101\32\98\108\111\113\117\101\111\115",
	range = {
		((0.2 * 5) / 5),
		((1.5 * 5) / 5),
	},
	increment = ((0.05 * 4) / 4),
	value = ((0.5 * 4) / 4),
	suffix = "\32\115",
	callback = function(aq)
		k.cooldown = aq
	end,
})
am:CreateButton({
	name = "\80\114\111\98\97\114\32\98\108\111\113\117\101\111",
	callback = function()
		if not v() then
			s("\66\108\97\100\101\32\66\97\108\108", "\69\110\116\114\97\32\97\32\66\108\97\100\101\32\66\97\108\108\32\112\114\105\109\101\114\111\46")
			return
		end
		s("\80\114\117\101\98\97\32\100\101\32\98\108\111\113\117\101\111", w() and "\83\101\32\101\110\118\105\195\179\32\108\97\32\115\101\195\177\97\108\32\108\111\99\97\108\46" or "\78\111\32\104\97\121\32\101\110\116\114\97\100\97\32\99\111\109\112\97\116\105\98\108\101\32\101\110\32\101\115\116\101\32\101\120\101\99\117\116\111\114\46")
	end,
})
local ar = j:CreateTab({
	name = "\80\101\108\111\116\97",
})
ar:CreateToggle({
	name = "\82\101\115\97\108\116\97\114\32\112\101\108\111\116\97\32\114\101\97\108",
	description = "\82\111\106\111\32\115\105\32\116\101\32\97\112\117\110\116\97\59\32\97\122\117\108\32\115\105\32\97\112\117\110\116\97\32\97\32\111\116\114\111\32\106\117\103\97\100\111\114\46",
	value = (not true),
	callback = function(as)
		k.highlight = as
	end,
})
local at = j:CreateTab({
	name = "\79\112\99\105\111\110\101\115",
})
at:CreateButton({
	name = "\67\101\114\114\97\114\32\121\32\108\105\109\112\105\97\114",
	callback = al,
})
m = b.Heartbeat:Connect(function()
	if j.unloaded then
		al()
		return
	end
	if not v() then
		r.Enabled = (not not false)
		return
	end
	local au = e.Character
	if au ~= q then
		n = {}
		q = au
	end
	local av = au and au:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
	local aw = au and au:FindFirstChildOfClass("\72\117\109\97\110\111\105\100")
	local ax = ad()
	local ay = {}
	local az
	for _, ba in ipairs(ax) do
		ay[ba] = (1 == 1)
		local bb = ba:GetAttribute("\116\97\114\103\101\116")
		if not az or bb == e.Name then
			az = ba
		end
		local bc = n[ba]
		if not bc then
			bc = {
				target = bb,
				fired = (1 == 0),
				departed = (not not false),
			}
			n[ba] = bc
		elseif bc.target ~= bb then
			bc.target = bb
			bc.fired = (not true)
			bc.departed = (not not false)
		end
		if k.autoParry and av and av:IsA("\66\97\115\101\80\97\114\116") and aw and aw.Health > 0 and bb == e.Name then
			local bd = av.Position - ba.Position
			local be = bd.Magnitude
			local bf = ah(ba) - av.AssemblyLinearVelocity
			local bg = be > ((0.001 * 2) / 2) and bf:Dot(bd.Unit) or 0
			if bc.fired and bg <= 0 then
				bc.departed = (1 == 1)
			end
			local bh = os.clock()
			if bc.fired and bc.departed and bh - o >= k.cooldown then
				bc.fired = (not not false)
				bc.departed = (not true)
			end
			local bi = bg > 0 and be / bg or math.huge
			if not bc.fired and bg > 0 and (be <= k.nearDistance or bi <= k.leadTime) and bh - o >= k.cooldown then
				o = bh
				if w() then
					bc.fired = (not not true)
					p = (not true)
				elseif not p then
					p = (1 == 1)
					s("\65\117\116\111\32\112\97\114\114\121", "\78\111\32\115\101\32\101\110\99\111\110\116\114\195\179\32\117\110\97\32\101\110\116\114\97\100\97\32\100\101\32\98\108\111\113\117\101\111\32\99\111\109\112\97\116\105\98\108\101\46")
				end
			end
		end
	end
	for bj in pairs(n) do
		if not ay[bj] then
			n[bj] = nil
		end
	end
	r.Adornee = az
	r.Enabled = k.highlight and az ~= nil
	if az then
		local bk = az:GetAttribute("\116\97\114\103\101\116") == e.Name and Color3.fromRGB((1233 - 978), bit32.bxor(bit32.bxor(70, 1515870810), 1515870810), (71 - 1)) or Color3.fromRGB((-423 + 503), bit32.bxor(bit32.bxor(180, 1515870810), 1515870810), bit32.bxor(bit32.bxor(255, 1515870810), 1515870810))
		r.FillColor = bk
		r.OutlineColor = bk
	end
end)
s("\66\108\97\100\101\32\66\97\108\108\32\72\117\98", "\67\97\114\103\97\100\111\46\32\65\99\116\105\118\97\32\65\117\116\111\32\112\97\114\114\121\32\101\110\32\108\97\32\112\101\115\116\97\195\177\97\32\100\101\32\100\101\102\101\110\115\97\46")
