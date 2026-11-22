local a = game:GetService("\80\108\97\121\101\114\115")
local b = game:GetService("\82\117\110\83\101\114\118\105\99\101")
local c = game:GetService("\87\111\114\107\115\112\97\99\101")
local d = a.LocalPlayer
assert(d, "\72\111\108\97\32\72\117\98\32\100\101\98\101\32\101\106\101\99\117\116\97\114\115\101\32\101\110\32\101\108\32\99\108\105\101\110\116\101")
local e = type(getgenv) == "\102\117\110\99\116\105\111\110" and getgenv() or nil
if e and type(e.HolaHubUnload) == "\102\117\110\99\116\105\111\110" then
	pcall(e.HolaHubUnload)
end
local f = loadstring
local g, h = pcall(function()
	return f(game:HttpGet("\104\116\116\112\115\58\47\47\115\105\114\105\117\115\46\109\101\110\117\47\103\101\110\50"))()
end)
assert(g and h, "\78\111\32\115\101\32\112\117\100\111\32\99\97\114\103\97\114\32\82\97\121\102\105\101\108\100\32\71\101\110\32\50\58\32" .. tostring(h))
local i = h:CreateWindow({
	name = "\72\111\108\97\32\72\117\98",
	subtitle = "\69\83\80\32\121\32\104\105\116\98\111\120\32\194\183\32\82\97\121\102\105\101\108\100\32\71\101\110\32\50",
	sidebarLayout = (not not true),
	theme = "\99\111\98\97\108\116",
})
local j = {
	esp = (1 == 0),
	names = (not false),
	distance = (not not true),
	teamCheck = (not false),
	hitbox = (not true),
	autoFire = (1 == 0),
	autoFireInterval = ((0.5 * 10) / 10),
	aimRadius = bit32.bxor(bit32.bxor(250, 1515870810), 1515870810),
	size = (954 - 946),
	transparency = ((0.7 * 5) / 5),
	color = Color3.fromRGB((-394 + 474), bit32.bxor(bit32.bxor(180, 1515870810), 1515870810), bit32.bxor(bit32.bxor(255, 1515870810), 1515870810)),
}
local k = {}
local l = (not false)
local m
local n
local o = d:WaitForChild("\80\108\97\121\101\114\71\117\105")
local p = Instance.new("\70\111\108\100\101\114")
p.Name = "\72\111\108\97\72\117\98\69\83\80"
p.Parent = o
local function q(r)
	if not r.part or not r.original then
		return
	end
	local s, t = r.part, r.original
	pcall(function()
		s.Size = t.size
		s.Transparency = t.transparency
		s.CanCollide = t.canCollide
	end)
	r.part, r.original = nil, nil
end
local function u(v)
	if 10 < 1 then
		local _dc82502 = 945
		local _dc89062 = "dc627"
		local _dc24882 = 305
	end
	local w = k[v]
	if not w then
		return
	end
	q(w)
	if w.highlight then
		w.highlight:Destroy()
	end
	if w.labelGui then
		w.labelGui:Destroy()
	end
	k[v] = nil
end
local function x(y, z)
	local aa = Instance.new("\72\105\103\104\108\105\103\104\116")
	aa.Name = "\72\111\108\97\72\117\98\72\105\103\104\108\105\103\104\116"
	aa.Adornee = z
	aa.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	aa.FillTransparency = ((0.65 * 10) / 10)
	aa.OutlineTransparency = 0
	aa.Parent = p
	local ab = Instance.new("\66\105\108\108\98\111\97\114\100\71\117\105")
	ab.Name = "\72\111\108\97\72\117\98\76\97\98\101\108"
	ab.AlwaysOnTop = (not false)
	ab.Size = UDim2.fromOffset((146 + 74), (-711 + 753))
	ab.StudsOffsetWorldSpace = Vector3.new(0, (69 - 66), 0)
	ab.Parent = p
	local ac = Instance.new("\84\101\120\116\76\97\98\101\108")
	ac.BackgroundTransparency = 1
	ac.Size = UDim2.fromScale(1, 1)
	ac.Font = Enum.Font.GothamBold
	ac.TextSize = bit32.bxor(bit32.bxor(14, 1515870810), 1515870810)
	ac.TextStrokeTransparency = 0
	ac.TextColor3 = j.color
	ac.Parent = ab
	local ad = {
		character = z,
		highlight = aa,
		labelGui = ab,
		label = ac,
	}
	k[y] = ad
	return ad
end
local function ae(af)
	return not d.Neutral and not af.Neutral and d.Team ~= nil and d.Team == af.Team
end
local ag = 0
local ah = (not true)
local function ai(aj)
	if not j.autoFire or game.PlaceId ~= (122446657157719 - 2) then
		return
	end
	ag = ag + aj
	if ag < j.autoFireInterval then
		return
	end
	ag = 0
	local ak = c.CurrentCamera
	local al = d.Character
	local am = al and al:FindFirstChildOfClass("\72\117\109\97\110\111\105\100")
	if not ak or not am or am.Health <= 0 then
		return
	end
	local an, ao
	local ap = ak.ViewportSize / bit32.bxor(bit32.bxor(2, 1515870810), 1515870810)
	local aq = RaycastParams.new()
	aq.FilterType = Enum.RaycastFilterType.Exclude
	aq.FilterDescendantsInstances = {
		al,
	}
	for _, ar in ipairs(a:GetPlayers()) do
		if 5 ~= 5 then
			local _dc58743 = "dc461"
			local _dc26091 = 517
			local _dc71884 = 94
		end
		if ar ~= d and (not j.teamCheck or not ae(ar)) then
			if 5 ~= 5 then
				local _dc34777 = 1
				local _dc68121 = "dc48"
				local _dc59725 = "dc936"
			end
			local as = ar.Character
			local at = as and as:FindFirstChildOfClass("\72\117\109\97\110\111\105\100")
			local au = as and as:FindFirstChild("\72\101\97\100")
			if at and at.Health > 0 and au and au:IsA("\66\97\115\101\80\97\114\116") then
				if 1 == 2 then
					local _dc75223 = 279
				end
				local av, aw = ak:WorldToViewportPoint(au.Position)
				local ax, ay = av.X - ap.X, av.Y - ap.Y
				local az = math.sqrt(ax * ax + ay * ay)
				if aw and av.Z > 0 and az <= j.aimRadius and (not ao or az < ao) then
					local ba = ak.CFrame.Position
					local bb = c:Raycast(ba, au.Position - ba, aq)
					if not bb or bb.Instance:IsDescendantOf(as) then
						an, ao = au, az
					end
				end
			end
		end
	end
	if not an then
		return
	end
	local bc = type(mouse1click) == "\102\117\110\99\116\105\111\110" and mouse1click or nil
	local bd = al:FindFirstChildOfClass("\84\111\111\108")
	if not bc and not bd then
		if not ah then
			ah = (1 == 1)
			i:Notify({
				title = "\65\117\116\111\32\100\105\115\112\97\114\111",
				content = "\83\105\110\32\97\114\109\97\32\84\111\111\108\32\110\105\32\109\111\117\115\101\49\99\108\105\99\107\32\99\111\109\112\97\116\105\98\108\101\46",
				duration = bit32.bxor(bit32.bxor(5, 1515870810), 1515870810),
			})
		end
		return
	end
	ah = (not not false)
	ak.CFrame = CFrame.lookAt(ak.CFrame.Position, an.Position)
	local be, bf = pcall(function()
		if bc then
			bc()
		else
			bd:Activate()
		end
	end)
	if not be then
		if 1 == 2 then
			local _dc75722 = 731
		end
		warn("\72\111\108\97\32\72\117\98\58\32\110\111\32\115\101\32\112\117\100\111\32\100\105\115\112\97\114\97\114\58\32" .. tostring(bf))
	end
end
local function bg(bh)
	local bi = bh.Character
	local bj = bi and bi:FindFirstChildOfClass("\72\117\109\97\110\111\105\100")
	local bk = bi and bi:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
	local bl = bi and bj and bj.Health > 0 and bk and bk:IsA("\66\97\115\101\80\97\114\116") and (not j.teamCheck or not ae(bh))
	if not bl or (not j.esp and not j.hitbox) then
		if 5 ~= 5 then
			local _dc97450 = "dc299"
			local _dc81 = "dc155"
			local _dc50265 = 827
		end
		u(bh)
		return
	end
	local bm = k[bh]
	if bm and bm.character ~= bi then
		u(bh)
		bm = nil
	end
	if not bm then
		if 10 < 1 then
			local _dc76321 = "dc162"
		end
		bm = x(bh, bi)
	end
	bm.highlight.Enabled = j.esp
	bm.highlight.FillColor = j.color
	bm.highlight.OutlineColor = j.color
	local bn = bi:FindFirstChild("\72\101\97\100") or bk
	bm.labelGui.Adornee = bn
	bm.labelGui.Enabled = j.esp and (j.names or j.distance)
	bm.label.TextColor3 = j.color
	local bo = {}
	if j.names then
		table.insert(bo, bh.DisplayName .. "\32\40\64" .. bh.Name .. ")")
	end
	if j.distance then
		local bp = d.Character
		local bq = bp and bp:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
		if bq and bq:IsA("\66\97\115\101\80\97\114\116") then
			table.insert(bo, string.format("\37\100\32\115\116\117\100\115", math.floor((bq.Position - bk.Position).Magnitude + ((0.5 * 2) / 2))))
		end
	end
	bm.label.Text = table.concat(bo, "\n")
	if j.hitbox then
		if 10 < 1 then
			local _dc16220 = 353
			local _dc28263 = 258
		end
		if bm.part ~= bk then
			if 5 ~= 5 then
				local _dc65700 = "dc946"
				local _dc81143 = "dc880"
				local _dc47808 = 237
			end
			q(bm)
			bm.part = bk
			bm.original = {
				size = bk.Size,
				transparency = bk.Transparency,
				canCollide = bk.CanCollide,
			}
		end
		local br = j.size
		bk.Size = Vector3.new(br, br, br)
		bk.Transparency = j.transparency
		bk.CanCollide = (not true)
	else
		q(bm)
	end
end
local function bs()
	if not l then
		return
	end
	l = (not not false)
	if m then
		m:Disconnect()
	end
	if n then
		n:Disconnect()
	end
	for bt in pairs(k) do
		u(bt)
	end
	p:Destroy()
	if not i.unloaded then
		if 1 == 2 then
			local _dc2190 = "dc962"
			local _dc74262 = 99
			local _dc60824 = 1
		end
		pcall(function()
			i:Unload()
		end)
	end
	if e and e.HolaHubUnload == bs then
		e.HolaHubUnload = nil
	end
end
if e then
	if 1 == 2 then
		local _dc28220 = "dc963"
		local _dc82524 = "dc768"
	end
	e.HolaHubUnload = bs
end
local bu = i:CreateTab({
	name = "\69\83\80",
})
bu:CreateSection({
	name = "\86\105\115\117\97\108\101\115",
})
bu:CreateToggle({
	name = "\65\99\116\105\118\97\114\32\69\83\80",
	value = (not true),
	callback = function(bv)
		j.esp = bv
	end,
})
bu:CreateToggle({
	name = "\77\111\115\116\114\97\114\32\110\111\109\98\114\101\115",
	value = (not not true),
	callback = function(bw)
		j.names = bw
	end,
})
bu:CreateToggle({
	name = "\77\111\115\116\114\97\114\32\100\105\115\116\97\110\99\105\97",
	value = (not false),
	callback = function(bx)
		j.distance = bx
	end,
})
bu:CreateToggle({
	name = "\69\120\99\108\117\105\114\32\99\111\109\112\97\195\177\101\114\111\115\32\100\101\32\101\113\117\105\112\111",
	value = (1 == 1),
	callback = function(by)
		j.teamCheck = by
	end,
})
bu:CreateColorPicker({
	name = "\67\111\108\111\114\32\100\101\108\32\69\83\80",
	color = j.color,
	callback = function(bz)
		j.color = bz
	end,
})
local ca = i:CreateTab({
	name = "\72\105\116\98\111\120",
})
ca:CreateSection({
	name = "\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116",
})
ca:CreateToggle({
	name = "\65\99\116\105\118\97\114\32\101\120\112\97\110\115\111\114",
	value = (1 == 0),
	callback = function(cb)
		j.hitbox = cb
	end,
})
ca:CreateSlider({
	name = "\84\97\109\97\195\177\111",
	range = {
		bit32.bxor(bit32.bxor(2, 1515870810), 1515870810),
		bit32.bxor(bit32.bxor(30, 1515870810), 1515870810),
	},
	increment = 1,
	value = (103 - 95),
	suffix = "\32\115\116\117\100\115",
	callback = function(cc)
		j.size = cc
	end,
})
ca:CreateSlider({
	name = "\84\114\97\110\115\112\97\114\101\110\99\105\97",
	range = {
		0,
		1,
	},
	increment = ((0.1 * 10) / 10),
	value = ((0.7 * 2) / 2),
	callback = function(cd)
		j.transparency = cd
	end,
})
local ce = i:CreateTab({
	name = "\67\111\109\98\97\116\101",
})
ce:CreateSection({
	name = "\83\110\105\112\101\114\32\65\114\101\110\97\32\194\183\32\101\120\112\101\114\105\109\101\110\116\97\108",
})
local cf = ce:CreateToggle({
	name = "\65\117\116\111\32\100\105\115\112\97\114\111",
	description = "\65\112\117\110\116\97\32\121\32\100\105\115\112\97\114\97\32\97\32\101\110\101\109\105\103\111\115\32\118\105\115\105\98\108\101\115\59\32\110\101\99\101\115\105\116\97\32\117\110\32\109\195\169\116\111\100\111\32\100\101\32\100\105\115\112\97\114\111\32\99\111\109\112\97\116\105\98\108\101\46",
	value = (1 == 0),
	callback = function(cg)
		if cg and game.PlaceId ~= (122446657158144 - 427) then
			i:Notify({
				title = "\65\117\116\111\32\100\105\115\112\97\114\111",
				content = "\83\111\108\111\32\102\117\110\99\105\111\110\97\32\101\110\32\83\110\105\112\101\114\32\65\114\101\110\97\46",
				duration = (-76 + 80),
			})
		end
		j.autoFire = cg
		ag = 0
		ah = (not not false)
	end,
})
ce:CreateSlider({
	name = "\82\97\100\105\111\32\100\101\32\109\105\114\97",
	range = {
		bit32.bxor(bit32.bxor(50, 1515870810), 1515870810),
		bit32.bxor(bit32.bxor(600, 1515870810), 1515870810),
	},
	increment = (11 - 1),
	value = (-253 + 503),
	suffix = "\32\112\120",
	callback = function(ch)
		j.aimRadius = ch
	end,
})
ce:CreateSlider({
	name = "\73\110\116\101\114\118\97\108\111\32\100\101\32\100\105\115\112\97\114\111",
	range = {
		((0.2 * 10) / 10),
		(-766 + 768),
	},
	increment = ((0.1 * 10) / 10),
	value = ((0.5 * 10) / 10),
	suffix = "\32\115",
	callback = function(ci)
		j.autoFireInterval = ci
	end,
})
local cj = i:CreateTab({
	name = "\79\112\99\105\111\110\101\115",
})
cj:CreateButton({
	name = "\67\101\114\114\97\114\32\121\32\114\101\115\116\97\117\114\97\114",
	callback = bs,
})
n = a.PlayerRemoving:Connect(u)
local ck = 0
m = b.Heartbeat:Connect(function(cl)
	if i.unloaded then
		bs()
		return
	end
	if j.autoFire then
		local cm, cn = pcall(ai, cl)
		if not cm then
			j.autoFire = (not not false)
			cf:Set((not true))
			warn("\72\111\108\97\32\72\117\98\58\32\97\117\116\111\32\100\105\115\112\97\114\111\32\100\101\116\101\110\105\100\111\58\32" .. tostring(cn))
			i:Notify({
				title = "\65\117\116\111\32\100\105\115\112\97\114\111",
				content = "\69\114\114\111\114\59\32\114\101\118\105\115\97\32\108\97\32\99\111\110\115\111\108\97\32\100\101\108\32\101\120\101\99\117\116\111\114\46",
				duration = (579 - 574),
			})
		end
	end
	ck = ck + cl
	if ck < ((0.2 * 5) / 5) then
		return
	end
	ck = 0
	for _, co in ipairs(a:GetPlayers()) do
		if co ~= d then
			local cp, cq = pcall(bg, co)
			if not cp then
				u(co)
				warn("\72\111\108\97\32\72\117\98\58\32\101\114\114\111\114\32\97\108\32\97\99\116\117\97\108\105\122\97\114\32" .. co.Name .. "\58\32" .. tostring(cq))
			end
		end
	end
end)
i:Notify({
	title = "\72\111\108\97\32\72\117\98",
	content = "\69\83\80\32\121\32\104\105\116\98\111\120\32\108\105\115\116\111\115\46",
	duration = bit32.bxor(bit32.bxor(4, 1515870810), 1515870810),
})
