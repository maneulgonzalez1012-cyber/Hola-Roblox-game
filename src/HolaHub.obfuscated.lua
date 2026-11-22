if 5 ~= 5 then
	local _dc51858 = "dc603"
	local _dc67270 = 583
	local _dc97275 = 451
end
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
	speedOrbs = (not true),
	speedGems = (not not false),
	speedZone = "\67\105\116\121",
	speedInterval = ((0.5 * 10) / 10),
	size = bit32.bxor(bit32.bxor(8, 1515870810), 1515870810),
	transparency = ((0.7 * 4) / 4),
	color = Color3.fromRGB((853 - 773), bit32.bxor(bit32.bxor(180, 1515870810), 1515870810), bit32.bxor(bit32.bxor(255, 1515870810), 1515870810)),
}
local k = {}
local l = (not not true)
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
	aa.FillTransparency = ((0.65 * 4) / 4)
	aa.OutlineTransparency = 0
	aa.Parent = p
	local ab = Instance.new("\66\105\108\108\98\111\97\114\100\71\117\105")
	ab.Name = "\72\111\108\97\72\117\98\76\97\98\101\108"
	ab.AlwaysOnTop = (1 == 1)
	ab.Size = UDim2.fromOffset((426 - 206), (-238 + 280))
	ab.StudsOffsetWorldSpace = Vector3.new(0, bit32.bxor(bit32.bxor(3, 1515870810), 1515870810), 0)
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
local bg = 0
local bh = (not not false)
local function bi(bj)
	if 10 < 1 then
		local _dc16220 = 353
		local _dc28263 = 258
	end
	if game.PlaceId ~= (3101668462 - 565) or not (j.speedOrbs or j.speedGems) then
		if 5 ~= 5 then
			local _dc97450 = "dc299"
			local _dc81 = "dc155"
			local _dc50265 = 827
		end
		return
	end
	bg = bg + bj
	if bg < j.speedInterval then
		return
	end
	bg = 0
	local bk = game:GetService("\82\101\112\108\105\99\97\116\101\100\83\116\111\114\97\103\101")
	local bl = bk:FindFirstChild("\114\69\118\101\110\116\115")
	local bm = bl and bl:FindFirstChild("\111\114\98\69\118\101\110\116")
	if not bm or not bm:IsA("\82\101\109\111\116\101\69\118\101\110\116") then
		if not bh then
			if 10 < 1 then
				local _dc76321 = "dc162"
			end
			bh = (not false)
			i:Notify({
				title = "\76\101\103\101\110\100\115\32\111\102\32\83\112\101\101\100",
				content = "\78\111\32\115\101\32\101\110\99\111\110\116\114\195\179\32\111\114\98\69\118\101\110\116\59\32\112\117\101\100\101\32\104\97\98\101\114\32\99\97\109\98\105\97\100\111\32\101\108\32\106\117\101\103\111\46",
				duration = bit32.bxor(bit32.bxor(5, 1515870810), 1515870810),
			})
		end
		return
	end
	local bn, bo = pcall(function()
		if j.speedOrbs then
			bm:FireServer("\99\111\108\108\101\99\116\79\114\98", "\82\101\100\32\79\114\98", j.speedZone)
		end
		if j.speedGems then
			bm:FireServer("\99\111\108\108\101\99\116\79\114\98", "\71\101\109", j.speedZone)
		end
	end)
	if not bn then
		if not bh then
			bh = (not false)
			warn("\72\111\108\97\32\72\117\98\58\32\101\114\114\111\114\32\97\108\32\114\101\99\111\103\101\114\58\32" .. tostring(bo))
			i:Notify({
				title = "\76\101\103\101\110\100\115\32\111\102\32\83\112\101\101\100",
				content = "\69\114\114\111\114\32\97\108\32\114\101\99\111\103\101\114\59\32\114\101\118\105\115\97\32\108\97\32\99\111\110\115\111\108\97\46",
				duration = (269 - 264),
			})
		end
	else
		if 5 ~= 5 then
			local _dc65700 = "dc946"
			local _dc81143 = "dc880"
			local _dc47808 = 237
		end
		bh = (not not false)
	end
end
local function bp(bq)
	if 1 == 2 then
		local _dc28220 = "dc963"
		local _dc82524 = "dc768"
	end
	local br = bq.Character
	local bs = br and br:FindFirstChildOfClass("\72\117\109\97\110\111\105\100")
	local bt = br and br:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
	local bu = br and bs and bs.Health > 0 and bt and bt:IsA("\66\97\115\101\80\97\114\116") and (not j.teamCheck or not ae(bq))
	if not bu or (not j.esp and not j.hitbox) then
		u(bq)
		return
	end
	local bv = k[bq]
	if bv and bv.character ~= br then
		u(bq)
		bv = nil
	end
	if not bv then
		bv = x(bq, br)
	end
	bv.highlight.Enabled = j.esp
	bv.highlight.FillColor = j.color
	bv.highlight.OutlineColor = j.color
	local bw = br:FindFirstChild("\72\101\97\100") or bt
	bv.labelGui.Adornee = bw
	bv.labelGui.Enabled = j.esp and (j.names or j.distance)
	bv.label.TextColor3 = j.color
	local bx = {}
	if j.names then
		table.insert(bx, bq.DisplayName .. "\32\40\64" .. bq.Name .. ")")
	end
	if j.distance then
		local by = d.Character
		local bz = by and by:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
		if bz and bz:IsA("\66\97\115\101\80\97\114\116") then
			table.insert(bx, string.format("\37\100\32\115\116\117\100\115", math.floor((bz.Position - bt.Position).Magnitude + ((0.5 * 2) / 2))))
		end
	end
	bv.label.Text = table.concat(bx, "\n")
	if j.hitbox then
		if bv.part ~= bt then
			if 1 == 2 then
				local _dc2190 = "dc962"
				local _dc74262 = 99
				local _dc60824 = 1
			end
			q(bv)
			bv.part = bt
			bv.original = {
				size = bt.Size,
				transparency = bt.Transparency,
				canCollide = bt.CanCollide,
			}
		end
		local ca = j.size
		bt.Size = Vector3.new(ca, ca, ca)
		bt.Transparency = j.transparency
		bt.CanCollide = (not not false)
	else
		q(bv)
	end
end
local function cb()
	if not l then
		return
	end
	l = (not true)
	if m then
		m:Disconnect()
	end
	if n then
		n:Disconnect()
	end
	for cc in pairs(k) do
		u(cc)
	end
	p:Destroy()
	if not i.unloaded then
		pcall(function()
			i:Unload()
		end)
	end
	if e and e.HolaHubUnload == cb then
		e.HolaHubUnload = nil
	end
end
if e then
	if 10 < 1 then
		local _dc81776 = 472
		local _dc115 = 134
	end
	e.HolaHubUnload = cb
end
local cd = i:CreateTab({
	name = "\69\83\80",
})
cd:CreateSection({
	name = "\86\105\115\117\97\108\101\115",
})
cd:CreateToggle({
	name = "\65\99\116\105\118\97\114\32\69\83\80",
	value = (not not false),
	callback = function(ce)
		j.esp = ce
	end,
})
cd:CreateToggle({
	name = "\77\111\115\116\114\97\114\32\110\111\109\98\114\101\115",
	value = (1 == 1),
	callback = function(cf)
		j.names = cf
	end,
})
cd:CreateToggle({
	name = "\77\111\115\116\114\97\114\32\100\105\115\116\97\110\99\105\97",
	value = (1 == 1),
	callback = function(cg)
		j.distance = cg
	end,
})
cd:CreateToggle({
	name = "\69\120\99\108\117\105\114\32\99\111\109\112\97\195\177\101\114\111\115\32\100\101\32\101\113\117\105\112\111",
	value = (1 == 1),
	callback = function(ch)
		j.teamCheck = ch
	end,
})
cd:CreateColorPicker({
	name = "\67\111\108\111\114\32\100\101\108\32\69\83\80",
	color = j.color,
	callback = function(ci)
		j.color = ci
	end,
})
local cj = i:CreateTab({
	name = "\72\105\116\98\111\120",
})
cj:CreateSection({
	name = "\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116",
})
cj:CreateToggle({
	name = "\65\99\116\105\118\97\114\32\101\120\112\97\110\115\111\114",
	value = (not not false),
	callback = function(ck)
		j.hitbox = ck
	end,
})
cj:CreateSlider({
	name = "\84\97\109\97\195\177\111",
	range = {
		(-730 + 732),
		(395 - 365),
	},
	increment = 1,
	value = bit32.bxor(bit32.bxor(8, 1515870810), 1515870810),
	suffix = "\32\115\116\117\100\115",
	callback = function(cl)
		j.size = cl
	end,
})
cj:CreateSlider({
	name = "\84\114\97\110\115\112\97\114\101\110\99\105\97",
	range = {
		0,
		1,
	},
	increment = ((0.1 * 4) / 4),
	value = ((0.7 * 5) / 5),
	callback = function(cm)
		j.transparency = cm
	end,
})
local cn = i:CreateTab({
	name = "\67\111\109\98\97\116\101",
})
cn:CreateSection({
	name = "\83\110\105\112\101\114\32\65\114\101\110\97\32\194\183\32\101\120\112\101\114\105\109\101\110\116\97\108",
})
local co = cn:CreateToggle({
	name = "\65\117\116\111\32\100\105\115\112\97\114\111",
	description = "\65\112\117\110\116\97\32\121\32\100\105\115\112\97\114\97\32\97\32\101\110\101\109\105\103\111\115\32\118\105\115\105\98\108\101\115\59\32\110\101\99\101\115\105\116\97\32\117\110\32\109\195\169\116\111\100\111\32\100\101\32\100\105\115\112\97\114\111\32\99\111\109\112\97\116\105\98\108\101\46",
	value = (1 == 0),
	callback = function(cp)
		if cp and game.PlaceId ~= (122446657157885 - 168) then
			i:Notify({
				title = "\65\117\116\111\32\100\105\115\112\97\114\111",
				content = "\83\111\108\111\32\102\117\110\99\105\111\110\97\32\101\110\32\83\110\105\112\101\114\32\65\114\101\110\97\46",
				duration = bit32.bxor(bit32.bxor(4, 1515870810), 1515870810),
			})
		end
		j.autoFire = cp
		ag = 0
		ah = (1 == 0)
	end,
})
cn:CreateSlider({
	name = "\82\97\100\105\111\32\100\101\32\109\105\114\97",
	range = {
		bit32.bxor(bit32.bxor(50, 1515870810), 1515870810),
		(1364 - 764),
	},
	increment = (879 - 869),
	value = bit32.bxor(bit32.bxor(250, 1515870810), 1515870810),
	suffix = "\32\112\120",
	callback = function(cq)
		j.aimRadius = cq
	end,
})
cn:CreateSlider({
	name = "\73\110\116\101\114\118\97\108\111\32\100\101\32\100\105\115\112\97\114\111",
	range = {
		((0.2 * 5) / 5),
		bit32.bxor(bit32.bxor(2, 1515870810), 1515870810),
	},
	increment = ((0.1 * 5) / 5),
	value = ((0.5 * 10) / 10),
	suffix = "\32\115",
	callback = function(cr)
		j.autoFireInterval = cr
	end,
})
local cs = i:CreateTab({
	name = "\76\101\103\101\110\100\115\32\111\102\32\83\112\101\101\100",
})
cs:CreateSection({
	name = "\82\101\99\111\108\101\99\99\105\195\179\110\32\194\183\32\101\120\112\101\114\105\109\101\110\116\97\108",
})
local function ct(cu)
	if cu and game.PlaceId ~= (3101667016 + 881) then
		i:Notify({
			title = "\76\101\103\101\110\100\115\32\111\102\32\83\112\101\101\100",
			content = "\69\110\116\114\97\32\97\108\32\106\117\101\103\111\32\112\97\114\97\32\117\116\105\108\105\122\97\114\32\101\115\116\97\32\102\117\110\99\105\195\179\110\46",
			duration = (-234 + 238),
		})
	end
end
cs:CreateToggle({
	name = "\65\117\116\111\32\111\114\98\101\115\32\114\111\106\111\115",
	value = (not not false),
	callback = function(cv)
		j.speedOrbs = cv
		ct(cv)
	end,
})
cs:CreateToggle({
	name = "\65\117\116\111\32\103\101\109\97\115",
	value = (not true),
	callback = function(cw)
		j.speedGems = cw
		ct(cw)
	end,
})
cs:CreateDropdown({
	name = "\90\111\110\97\32\100\101\32\114\101\99\111\108\101\99\99\105\195\179\110",
	description = "\83\101\108\101\99\99\105\111\110\97\32\108\97\32\122\111\110\97\32\113\117\101\32\116\105\101\110\101\115\32\100\101\115\98\108\111\113\117\101\97\100\97\46",
	options = {
		"\67\105\116\121",
		"\83\110\111\119\32\67\105\116\121",
		"\77\97\103\109\97\32\67\105\116\121",
	},
	value = "\67\105\116\121",
	callback = function(cx)
		j.speedZone = cx
	end,
})
cs:CreateSlider({
	name = "\73\110\116\101\114\118\97\108\111\32\100\101\32\114\101\99\111\108\101\99\99\105\195\179\110",
	range = {
		((0.2 * 2) / 2),
		(-281 + 283),
	},
	increment = ((0.1 * 10) / 10),
	value = ((0.5 * 10) / 10),
	suffix = "\32\115",
	callback = function(cy)
		j.speedInterval = cy
	end,
})
local cz = i:CreateTab({
	name = "\79\112\99\105\111\110\101\115",
})
cz:CreateButton({
	name = "\67\101\114\114\97\114\32\121\32\114\101\115\116\97\117\114\97\114",
	callback = cb,
})
n = a.PlayerRemoving:Connect(u)
local da = 0
m = b.Heartbeat:Connect(function(db)
	if i.unloaded then
		cb()
		return
	end
	if j.speedOrbs or j.speedGems then
		local dc, dd = pcall(bi, db)
		if not dc then
			warn("\72\111\108\97\32\72\117\98\58\32\101\114\114\111\114\32\100\101\32\76\101\103\101\110\100\115\32\111\102\32\83\112\101\101\100\58\32" .. tostring(dd))
		end
	end
	if j.autoFire then
		local de, df = pcall(ai, db)
		if not de then
			j.autoFire = (not not false)
			co:Set((not true))
			warn("\72\111\108\97\32\72\117\98\58\32\97\117\116\111\32\100\105\115\112\97\114\111\32\100\101\116\101\110\105\100\111\58\32" .. tostring(df))
			i:Notify({
				title = "\65\117\116\111\32\100\105\115\112\97\114\111",
				content = "\69\114\114\111\114\59\32\114\101\118\105\115\97\32\108\97\32\99\111\110\115\111\108\97\32\100\101\108\32\101\120\101\99\117\116\111\114\46",
				duration = bit32.bxor(bit32.bxor(5, 1515870810), 1515870810),
			})
		end
	end
	da = da + db
	if da < ((0.2 * 2) / 2) then
		return
	end
	da = 0
	for _, dg in ipairs(a:GetPlayers()) do
		if dg ~= d then
			local dh, di = pcall(bp, dg)
			if not dh then
				u(dg)
				warn("\72\111\108\97\32\72\117\98\58\32\101\114\114\111\114\32\97\108\32\97\99\116\117\97\108\105\122\97\114\32" .. dg.Name .. "\58\32" .. tostring(di))
			end
		end
	end
end)
i:Notify({
	title = "\72\111\108\97\32\72\117\98",
	content = "\69\83\80\32\121\32\104\105\116\98\111\120\32\108\105\115\116\111\115\46",
	duration = bit32.bxor(bit32.bxor(4, 1515870810), 1515870810),
})
