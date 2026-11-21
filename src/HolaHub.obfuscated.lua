local a = game:GetService("\80\108\97\121\101\114\115")
local b = game:GetService("\82\117\110\83\101\114\118\105\99\101")
local c = a.LocalPlayer
assert(c, "\72\111\108\97\32\72\117\98\32\100\101\98\101\32\101\106\101\99\117\116\97\114\115\101\32\101\110\32\101\108\32\99\108\105\101\110\116\101")
local d = type(getgenv) == "\102\117\110\99\116\105\111\110" and getgenv() or nil
if d and type(d.HolaHubUnload) == "\102\117\110\99\116\105\111\110" then
	pcall(d.HolaHubUnload)
end
local e = loadstring
local f, g = pcall(function()
	return e(game:HttpGet("\104\116\116\112\115\58\47\47\115\105\114\105\117\115\46\109\101\110\117\47\103\101\110\50"))()
end)
assert(f and g, "\78\111\32\115\101\32\112\117\100\111\32\99\97\114\103\97\114\32\82\97\121\102\105\101\108\100\32\71\101\110\32\50\58\32" .. tostring(g))
local h = g:CreateWindow({
	name = "\72\111\108\97\32\72\117\98",
	subtitle = "\69\83\80\32\121\32\104\105\116\98\111\120\32\194\183\32\82\97\121\102\105\101\108\100\32\71\101\110\32\50",
	sidebarLayout = (not not true),
	theme = "\99\111\98\97\108\116",
})
local i = {
	esp = (1 == 0),
	names = (not false),
	distance = (not not true),
	teamCheck = (not false),
	hitbox = (not true),
	size = (775 - 767),
	transparency = ((0.7 * 4) / 4),
	color = Color3.fromRGB(bit32.bxor(bit32.bxor(80, 1515870810), 1515870810), bit32.bxor(bit32.bxor(180, 1515870810), 1515870810), bit32.bxor(bit32.bxor(255, 1515870810), 1515870810)),
}
local j = {}
local k = (not false)
local l
local m
local n = c:WaitForChild("\80\108\97\121\101\114\71\117\105")
local o = Instance.new("\70\111\108\100\101\114")
o.Name = "\72\111\108\97\72\117\98\69\83\80"
o.Parent = n
local function p(q)
	if not q.part or not q.original then
		return
	end
	local r, s = q.part, q.original
	pcall(function()
		r.Size = s.size
		r.Transparency = s.transparency
		r.CanCollide = s.canCollide
	end)
	q.part, q.original = nil, nil
end
local function t(u)
	if 10 < 1 then
		local _dc82502 = 945
		local _dc89062 = "dc627"
		local _dc24882 = 305
	end
	local v = j[u]
	if not v then
		return
	end
	p(v)
	if v.highlight then
		v.highlight:Destroy()
	end
	if v.labelGui then
		v.labelGui:Destroy()
	end
	j[u] = nil
end
local function w(x, y)
	local z = Instance.new("\72\105\103\104\108\105\103\104\116")
	z.Name = "\72\111\108\97\72\117\98\72\105\103\104\108\105\103\104\116"
	z.Adornee = y
	z.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	z.FillTransparency = ((0.65 * 4) / 4)
	z.OutlineTransparency = 0
	z.Parent = o
	local aa = Instance.new("\66\105\108\108\98\111\97\114\100\71\117\105")
	aa.Name = "\72\111\108\97\72\117\98\76\97\98\101\108"
	aa.AlwaysOnTop = (1 == 1)
	aa.Size = UDim2.fromOffset(bit32.bxor(bit32.bxor(220, 1515870810), 1515870810), bit32.bxor(bit32.bxor(42, 1515870810), 1515870810))
	aa.StudsOffsetWorldSpace = Vector3.new(0, bit32.bxor(bit32.bxor(3, 1515870810), 1515870810), 0)
	aa.Parent = o
	local ab = Instance.new("\84\101\120\116\76\97\98\101\108")
	ab.BackgroundTransparency = 1
	ab.Size = UDim2.fromScale(1, 1)
	ab.Font = Enum.Font.GothamBold
	ab.TextSize = bit32.bxor(bit32.bxor(14, 1515870810), 1515870810)
	ab.TextStrokeTransparency = 0
	ab.TextColor3 = i.color
	ab.Parent = aa
	local ac = {
		character = y,
		highlight = z,
		labelGui = aa,
		label = ab,
	}
	j[x] = ac
	return ac
end
local function ad(ae)
	return not c.Neutral and not ae.Neutral and c.Team ~= nil and c.Team == ae.Team
end
local function af(ag)
	local ah = ag.Character
	local ai = ah and ah:FindFirstChildOfClass("\72\117\109\97\110\111\105\100")
	local aj = ah and ah:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
	local ak = ah and ai and ai.Health > 0 and aj and aj:IsA("\66\97\115\101\80\97\114\116") and (not i.teamCheck or not ad(ag))
	if not ak or (not i.esp and not i.hitbox) then
		t(ag)
		return
	end
	local al = j[ag]
	if al and al.character ~= ah then
		t(ag)
		al = nil
	end
	if not al then
		al = w(ag, ah)
	end
	al.highlight.Enabled = i.esp
	al.highlight.FillColor = i.color
	al.highlight.OutlineColor = i.color
	local am = ah:FindFirstChild("\72\101\97\100") or aj
	al.labelGui.Adornee = am
	al.labelGui.Enabled = i.esp and (i.names or i.distance)
	al.label.TextColor3 = i.color
	local an = {}
	if i.names then
		table.insert(an, ag.DisplayName .. "\32\40\64" .. ag.Name .. ")")
	end
	if i.distance then
		if 1 == 2 then
			local _dc75223 = 279
		end
		local ao = c.Character
		local ap = ao and ao:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
		if ap and ap:IsA("\66\97\115\101\80\97\114\116") then
			table.insert(an, string.format("\37\100\32\115\116\117\100\115", math.floor((ap.Position - aj.Position).Magnitude + ((0.5 * 5) / 5))))
		end
	end
	al.label.Text = table.concat(an, "\n")
	if i.hitbox then
		if 5 ~= 5 then
			local _dc58743 = "dc461"
			local _dc26091 = 517
			local _dc71884 = 94
		end
		if al.part ~= aj then
			if 5 ~= 5 then
				local _dc34777 = 1
				local _dc68121 = "dc48"
				local _dc59725 = "dc936"
			end
			p(al)
			al.part = aj
			al.original = {
				size = aj.Size,
				transparency = aj.Transparency,
				canCollide = aj.CanCollide,
			}
		end
		local aq = i.size
		aj.Size = Vector3.new(aq, aq, aq)
		aj.Transparency = i.transparency
		aj.CanCollide = (not true)
	else
		p(al)
	end
end
local function ar()
	if not k then
		return
	end
	k = (1 == 0)
	if l then
		if 1 == 2 then
			local _dc75722 = 731
		end
		l:Disconnect()
	end
	if m then
		m:Disconnect()
	end
	for as in pairs(j) do
		if 5 ~= 5 then
			local _dc97450 = "dc299"
			local _dc81 = "dc155"
			local _dc50265 = 827
		end
		t(as)
	end
	o:Destroy()
	if not h.unloaded then
		pcall(function()
			h:Unload()
		end)
	end
	if d and d.HolaHubUnload == ar then
		if 10 < 1 then
			local _dc76321 = "dc162"
		end
		d.HolaHubUnload = nil
	end
end
if d then
	d.HolaHubUnload = ar
end
local at = h:CreateTab({
	name = "\69\83\80",
})
at:CreateSection({
	name = "\86\105\115\117\97\108\101\115",
})
at:CreateToggle({
	name = "\65\99\116\105\118\97\114\32\69\83\80",
	value = (1 == 0),
	callback = function(au)
		i.esp = au
	end,
})
at:CreateToggle({
	name = "\77\111\115\116\114\97\114\32\110\111\109\98\114\101\115",
	value = (1 == 1),
	callback = function(av)
		i.names = av
	end,
})
at:CreateToggle({
	name = "\77\111\115\116\114\97\114\32\100\105\115\116\97\110\99\105\97",
	value = (not not true),
	callback = function(aw)
		i.distance = aw
	end,
})
at:CreateToggle({
	name = "\69\120\99\108\117\105\114\32\99\111\109\112\97\195\177\101\114\111\115\32\100\101\32\101\113\117\105\112\111",
	value = (1 == 1),
	callback = function(ax)
		i.teamCheck = ax
	end,
})
at:CreateColorPicker({
	name = "\67\111\108\111\114\32\100\101\108\32\69\83\80",
	color = i.color,
	callback = function(ay)
		i.color = ay
	end,
})
local az = h:CreateTab({
	name = "\72\105\116\98\111\120",
})
az:CreateSection({
	name = "\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116",
})
az:CreateToggle({
	name = "\65\99\116\105\118\97\114\32\101\120\112\97\110\115\111\114",
	value = (1 == 0),
	callback = function(ba)
		i.hitbox = ba
	end,
})
az:CreateSlider({
	name = "\84\97\109\97\195\177\111",
	range = {
		(632 - 630),
		(-182 + 212),
	},
	increment = 1,
	value = bit32.bxor(bit32.bxor(8, 1515870810), 1515870810),
	suffix = "\32\115\116\117\100\115",
	callback = function(bb)
		i.size = bb
	end,
})
az:CreateSlider({
	name = "\84\114\97\110\115\112\97\114\101\110\99\105\97",
	range = {
		0,
		1,
	},
	increment = ((0.1 * 2) / 2),
	value = ((0.7 * 5) / 5),
	callback = function(bc)
		i.transparency = bc
	end,
})
local bd = h:CreateTab({
	name = "\79\112\99\105\111\110\101\115",
})
bd:CreateButton({
	name = "\67\101\114\114\97\114\32\121\32\114\101\115\116\97\117\114\97\114",
	callback = ar,
})
m = a.PlayerRemoving:Connect(t)
local be = 0
l = b.Heartbeat:Connect(function(bf)
	if h.unloaded then
		ar()
		return
	end
	be = be + bf
	if be < ((0.2 * 2) / 2) then
		return
	end
	be = 0
	for _, bg in ipairs(a:GetPlayers()) do
		if bg ~= c then
			local bh, bi = pcall(af, bg)
			if not bh then
				t(bg)
				warn("\72\111\108\97\32\72\117\98\58\32\101\114\114\111\114\32\97\108\32\97\99\116\117\97\108\105\122\97\114\32" .. bg.Name .. "\58\32" .. tostring(bi))
			end
		end
	end
end)
h:Notify({
	title = "\72\111\108\97\32\72\117\98",
	content = "\69\83\80\32\121\32\104\105\116\98\111\120\32\108\105\115\116\111\115\46",
	duration = bit32.bxor(bit32.bxor(4, 1515870810), 1515870810),
})
