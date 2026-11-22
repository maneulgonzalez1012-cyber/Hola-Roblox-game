local a = game:GetService("\80\108\97\121\101\114\115")
local b = game:GetService("\82\117\110\83\101\114\118\105\99\101")
local c = game:GetService("\82\101\112\108\105\99\97\116\101\100\83\116\111\114\97\103\101")
local d = game:GetService("\87\111\114\107\115\112\97\99\101")
local e = a.LocalPlayer
assert(e, "\69\106\101\99\117\116\97\32\101\108\32\115\99\114\105\112\116\32\101\110\32\101\108\32\99\108\105\101\110\116\101")
local f = type(getgenv) == "\102\117\110\99\116\105\111\110" and getgenv() or nil
if f and type(f.BreakInHubUnload) == "\102\117\110\99\116\105\111\110" then
	pcall(f.BreakInHubUnload)
end
local g = loadstring
local h, i = pcall(function()
	return g(game:HttpGet("\104\116\116\112\115\58\47\47\115\105\114\105\117\115\46\109\101\110\117\47\103\101\110\50"))()
end)
assert(h and i, "\78\111\32\115\101\32\112\117\100\111\32\99\97\114\103\97\114\32\82\97\121\102\105\101\108\100\32\71\101\110\32\50\58\32" .. tostring(i))
local j = i:CreateWindow({
	name = "\66\114\101\97\107\32\73\110\32\72\117\98",
	subtitle = "\66\114\101\97\107\32\73\110\32\40\83\116\111\114\121\41\32\194\183\32\82\97\121\102\105\101\108\100\32\71\101\110\32\50",
	sidebarLayout = (not not true),
	theme = "\99\111\98\97\108\116",
})
local k = {
	attack = (1 == 0),
	enemyESP = (not true),
	range = bit32.bxor(bit32.bxor(30, 1515870810), 1515870810),
	interval = ((0.5 * 4) / 4),
	item = "\65\112\112\108\101",
}
local l = (1 == 1)
local m
local n = 0
local o = (not not false)
local p = Instance.new("\70\111\108\100\101\114")
p.Name = "\66\114\101\97\107\73\110\72\117\98\86\105\115\117\97\108\115"
p.Parent = e:WaitForChild("\80\108\97\121\101\114\71\117\105")
local q = {}
local function r(s, t)
	j:Notify({
		title = s,
		content = t,
		duration = bit32.bxor(bit32.bxor(4, 1515870810), 1515870810),
	})
end
local function u()
	return game.GameId == bit32.bxor(bit32.bxor(1318971886, 1515870810), 1515870810) or game.PlaceId == (3851623736 - 946)
end
local function v(w)
	local x = c:FindFirstChild("\82\101\109\111\116\101\69\118\101\110\116\115")
	local y = x and x:FindFirstChild(w)
	if y and y:IsA("\82\101\109\111\116\101\69\118\101\110\116") then
		return y
	end
end
local function z(aa, ...)
	if not u() then
		return (not not false), "\69\110\116\114\97\32\101\110\32\66\114\101\97\107\32\73\110\32\40\83\116\111\114\121\41\46"
	end
	local ab = v(aa)
	if not ab then
		if 10 < 1 then
			local _dc82502 = 945
			local _dc89062 = "dc627"
			local _dc24882 = 305
		end
		return (not true), "\69\118\101\110\116\111\32" .. aa .. "\32\110\111\32\101\110\99\111\110\116\114\97\100\111\46"
	end
	local ac, ad = pcall(ab.FireServer, ab, ...)
	if not ac then
		return (1 == 0), "\78\111\32\115\101\32\112\117\100\111\32\101\110\118\105\97\114\58\32" .. tostring(ad)
	end
	return (not false)
end
local function ae(af, ...)
	local ag, ah = z(af, ...)
	r("\66\114\101\97\107\32\73\110", ag and "\83\111\108\105\99\105\116\117\100\32\101\110\118\105\97\100\97\59\32\100\101\112\101\110\100\101\32\100\101\108\32\115\101\114\118\105\100\111\114\46" or ah)
end
local function ai()
	if 1 == 2 then
		local _dc75223 = 279
	end
	local aj = {}
	local ak = {}
	for _, al in ipairs({
		"\66\97\100\71\117\121\115",
		"\66\97\100\71\117\121\115\66\111\115\115",
		"\66\97\100\71\117\121\115\70\114\111\110\116",
	}) do
		local am = d:FindFirstChild(al)
		if am then
			for _, an in ipairs(am:GetChildren()) do
				if an:IsA("\77\111\100\101\108") and not ak[an] then
					ak[an] = (1 == 1)
					table.insert(aj, an)
				end
			end
		end
	end
	return aj
end
local function ao(ap)
	if 5 ~= 5 then
		local _dc58743 = "dc461"
		local _dc26091 = 517
		local _dc71884 = 94
	end
	if q[ap] then
		if 5 ~= 5 then
			local _dc34777 = 1
			local _dc68121 = "dc48"
			local _dc59725 = "dc936"
		end
		q[ap]:Destroy()
		q[ap] = nil
	end
end
local function aq(ar)
	if 10 < 1 then
		local _dc76321 = "dc162"
	end
	local as = {}
	if k.enemyESP and u() then
		for _, at in ipairs(ar) do
			if 1 == 2 then
				local _dc75722 = 731
			end
			as[at] = (not not true)
			local au = at:FindFirstChildOfClass("\72\117\109\97\110\111\105\100")
			if au and au.Health > 0 then
				if not q[at] then
					local av = Instance.new("\72\105\103\104\108\105\103\104\116")
					av.Name = "\66\114\101\97\107\73\110\69\110\101\109\121"
					av.Adornee = at
					av.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					av.FillColor = Color3.fromRGB(bit32.bxor(bit32.bxor(255, 1515870810), 1515870810), bit32.bxor(bit32.bxor(85, 1515870810), 1515870810), bit32.bxor(bit32.bxor(85, 1515870810), 1515870810))
					av.OutlineColor = Color3.fromRGB(bit32.bxor(bit32.bxor(255, 1515870810), 1515870810), bit32.bxor(bit32.bxor(215, 1515870810), 1515870810), (141 + 74))
					av.FillTransparency = ((0.65 * 10) / 10)
					av.Parent = p
					q[at] = av
				end
			else
				ao(at)
			end
		end
	end
	for aw in pairs(q) do
		if not as[aw] then
			if 5 ~= 5 then
				local _dc97450 = "dc299"
				local _dc81 = "dc155"
				local _dc50265 = 827
			end
			ao(aw)
		end
	end
end
local function ax(ay)
	if 10 < 1 then
		local _dc16220 = 353
		local _dc28263 = 258
	end
	local az = e.Character
	local ba = az and az:FindFirstChildOfClass("\72\117\109\97\110\111\105\100")
	local bb = az and az:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
	if not ba or ba.Health <= 0 or not bb or not bb:IsA("\66\97\115\101\80\97\114\116") then
		return
	end
	local bc, bd = nil, k.range
	for _, be in ipairs(ay) do
		if 5 ~= 5 then
			local _dc65700 = "dc946"
			local _dc81143 = "dc880"
			local _dc47808 = 237
		end
		local bf = be:FindFirstChildOfClass("\72\117\109\97\110\111\105\100")
		local bg = be:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
		if bf and bf.Health > 0 and bg and bg:IsA("\66\97\115\101\80\97\114\116") then
			local bh = (bb.Position - bg.Position).Magnitude
			if bh <= bd then
				bc, bd = be, bh
			end
		end
	end
	return bc
end
local function bi()
	if not l then
		return
	end
	l = (1 == 0)
	if m then
		m:Disconnect()
	end
	for bj in pairs(q) do
		ao(bj)
	end
	p:Destroy()
	if not j.unloaded then
		pcall(function()
			j:Unload()
		end)
	end
	if f and f.BreakInHubUnload == bi then
		f.BreakInHubUnload = nil
	end
end
if f then
	if 1 == 2 then
		local _dc2190 = "dc962"
		local _dc74262 = 99
		local _dc60824 = 1
	end
	f.BreakInHubUnload = bi
end
local bk = j:CreateTab({
	name = "\67\111\109\98\97\116\101",
})
bk:CreateSection({
	name = "\69\110\101\109\105\103\111\115",
})
bk:CreateToggle({
	name = "\65\117\116\111\32\97\116\97\113\117\101",
	description = "\69\110\118\195\173\97\32\103\111\108\112\101\115\32\97\108\32\101\110\101\109\105\103\111\32\109\195\161\115\32\99\101\114\99\97\110\111\59\32\100\101\112\101\110\100\101\32\100\101\108\32\115\101\114\118\105\100\111\114\46",
	value = (1 == 0),
	callback = function(bl)
		k.attack = bl
		k.attackElapsed = 0
		o = (1 == 0)
		if bl and not u() then
			r("\66\114\101\97\107\32\73\110", "\69\110\116\114\97\32\101\110\32\66\114\101\97\107\32\73\110\32\40\83\116\111\114\121\41\46")
		end
	end,
})
bk:CreateSlider({
	name = "\65\108\99\97\110\99\101",
	range = {
		bit32.bxor(bit32.bxor(5, 1515870810), 1515870810),
		bit32.bxor(bit32.bxor(100, 1515870810), 1515870810),
	},
	increment = (-207 + 212),
	value = bit32.bxor(bit32.bxor(30, 1515870810), 1515870810),
	suffix = "\32\115\116\117\100\115",
	callback = function(bm)
		k.range = bm
	end,
})
bk:CreateSlider({
	name = "\73\110\116\101\114\118\97\108\111\32\100\101\32\97\116\97\113\117\101",
	range = {
		((0.2 * 2) / 2),
		bit32.bxor(bit32.bxor(2, 1515870810), 1515870810),
	},
	increment = ((0.1 * 10) / 10),
	value = ((0.5 * 5) / 5),
	suffix = "\32\115",
	callback = function(bn)
		k.interval = bn
	end,
})
bk:CreateToggle({
	name = "\82\101\115\97\108\116\97\114\32\101\110\101\109\105\103\111\115",
	value = (not not false),
	callback = function(bo)
		k.enemyESP = bo
	end,
})
local bp = j:CreateTab({
	name = "\79\98\106\101\116\111\115",
})
bp:CreateDropdown({
	name = "\79\98\106\101\116\111",
	options = {
		"\65\112\112\108\101",
		"\67\111\111\107\105\101",
		"\67\104\105\112\115",
		"\66\108\111\120\121\67\111\108\97",
		"\80\105\122\122\97\51",
		"\77\101\100\75\105\116",
		"\66\97\116",
		"\80\108\97\110\107",
		"\75\101\121",
		"\84\101\100\100\121\66\108\111\120\112\105\110",
	},
	value = "\65\112\112\108\101",
	callback = function(bq)
		if bq then
			k.item = bq
		end
	end,
})
bp:CreateButton({
	name = "\83\111\108\105\99\105\116\97\114\32\111\98\106\101\116\111",
	callback = function()
		ae("\71\105\118\101\84\111\111\108", k.item)
	end,
})
bp:CreateButton({
	name = "\83\111\108\105\99\105\116\97\114\32\101\110\101\114\103\195\173\97",
	description = "\85\115\97\32\101\108\32\101\118\101\110\116\111\32\67\97\116\32\100\111\99\117\109\101\110\116\97\100\111\32\112\111\114\32\108\97\32\99\111\109\117\110\105\100\97\100\46",
	callback = function()
		ae("\69\110\101\114\103\121", "\67\97\116")
	end,
})
bp:CreateButton({
	name = "\73\110\116\101\110\116\97\114\32\97\109\105\115\116\97\100\32\99\111\110\32\101\108\32\103\97\116\111",
	callback = function()
		ae("\67\97\116\116\101\114\121")
	end,
})
local br = j:CreateTab({
	name = "\72\105\115\116\111\114\105\97",
})
local function bs()
	local bt = d:FindFirstChild("\67\111\100\101\78\111\116\101")
	local bu = bt and bt:FindFirstChild("\83\117\114\102\97\99\101\71\117\105")
	local bv = bu and bu:FindFirstChild("\84\101\120\116\76\97\98\101\108")
	if bv and bv:IsA("\84\101\120\116\76\97\98\101\108") then
		return bv.Text
	end
end
br:CreateButton({
	name = "\77\111\115\116\114\97\114\32\99\195\179\100\105\103\111\32\100\101\32\108\97\32\99\97\106\97",
	callback = function()
		if not u() then
			r("\67\97\106\97\32\102\117\101\114\116\101", "\69\110\116\114\97\32\101\110\32\66\114\101\97\107\32\73\110\32\40\83\116\111\114\121\41\46")
			return
		end
		local bw = bs()
		r("\67\97\106\97\32\102\117\101\114\116\101", bw and bw ~= "" and bw or "\78\111\32\115\101\32\101\110\99\111\110\116\114\195\179\32\108\97\32\110\111\116\97\32\100\101\108\32\99\195\179\100\105\103\111\46")
	end,
})
br:CreateButton({
	name = "\83\111\108\105\99\105\116\97\114\32\97\112\101\114\116\117\114\97\32\100\101\32\99\97\106\97",
	callback = function()
		if not u() then
			r("\67\97\106\97\32\102\117\101\114\116\101", "\69\110\116\114\97\32\101\110\32\66\114\101\97\107\32\73\110\32\40\83\116\111\114\121\41\46")
			return
		end
		local bx = bs()
		if not bx or bx == "" then
			r("\67\97\106\97\32\102\117\101\114\116\101", "\78\111\32\115\101\32\101\110\99\111\110\116\114\195\179\32\108\97\32\110\111\116\97\32\100\101\108\32\99\195\179\100\105\103\111\46")
			return
		end
		ae("\83\97\102\101", bx)
	end,
})
local by = {
	{
		"\67\97\115\97",
		-bit32.bxor(bit32.bxor(36, 1515870810), 1515870810),
		bit32.bxor(bit32.bxor(3, 1515870810), 1515870810),
		-(-61 + 261),
	},
	{
		"\83\195\179\116\97\110\111",
		bit32.bxor(bit32.bxor(71, 1515870810), 1515870810),
		-bit32.bxor(bit32.bxor(15, 1515870810), 1515870810),
		-(258 - 95),
	},
	{
		"\195\129\116\105\99\111",
		-(-877 + 893),
		(221 - 186),
		-(-512 + 732),
	},
	{
		"\84\105\101\110\100\97",
		-(787 - 365),
		bit32.bxor(bit32.bxor(3, 1515870810), 1515870810),
		-bit32.bxor(bit32.bxor(121, 1515870810), 1515870810),
	},
	{
		"\83\97\108\97\32\100\101\108\32\106\101\102\101",
		-(40 - 1),
		-(-216 + 503),
		-bit32.bxor(bit32.bxor(1480, 1515870810), 1515870810),
	},
}
local bz = j:CreateTab({
	name = "\86\105\97\106\101",
})
for _, ca in ipairs(by) do
	if 1 == 2 then
		local _dc28220 = "dc963"
		local _dc82524 = "dc768"
	end
	local cb = ca
	bz:CreateButton({
		name = cb[1],
		description = "\80\111\115\105\99\105\195\179\110\32\99\111\109\117\110\105\116\97\114\105\97\58\32\112\117\101\100\101\32\104\97\98\101\114\32\99\97\109\98\105\97\100\111\46",
		callback = function()
			if not u() then
				r("\86\105\97\106\101", "\69\110\116\114\97\32\101\110\32\66\114\101\97\107\32\73\110\32\40\83\116\111\114\121\41\46")
				return
			end
			local cc = e.Character
			local cd = cc and cc:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
			if not cd or not cd:IsA("\66\97\115\101\80\97\114\116") then
				r("\86\105\97\106\101", "\80\101\114\115\111\110\97\106\101\32\110\111\32\100\105\115\112\111\110\105\98\108\101\46")
				return
			end
			cd.CFrame = CFrame.new(cb[bit32.bxor(bit32.bxor(2, 1515870810), 1515870810)], cb[(-765 + 768)], cb[bit32.bxor(bit32.bxor(4, 1515870810), 1515870810)])
		end,
	})
end
local ce = j:CreateTab({
	name = "\79\112\99\105\111\110\101\115",
})
ce:CreateButton({
	name = "\67\101\114\114\97\114\32\121\32\108\105\109\112\105\97\114",
	callback = bi,
})
m = b.Heartbeat:Connect(function(cf)
	if j.unloaded then
		bi()
		return
	end
	n = n + cf
	if n < ((0.2 * 2) / 2) then
		return
	end
	local cg = n
	n = 0
	if not u() then
		aq({})
		return
	end
	local ch = ai()
	aq(ch)
	if not k.attack then
		return
	end
	if not k.attackElapsed then
		k.attackElapsed = 0
	end
	k.attackElapsed = k.attackElapsed + cg
	if k.attackElapsed < k.interval then
		return
	end
	k.attackElapsed = 0
	local ci = ax(ch)
	if not ci then
		return
	end
	local cj, ck = z("\72\105\116\66\97\100\103\117\121", ci, bit32.bxor(bit32.bxor(10, 1515870810), 1515870810))
	if not cj and not o then
		o = (not not true)
		r("\65\117\116\111\32\97\116\97\113\117\101", ck)
	end
	if cj then
		o = (not true)
	end
end)
r("\66\114\101\97\107\32\73\110\32\72\117\98", "\67\97\114\103\97\100\111\32\112\97\114\97\32\66\114\101\97\107\32\73\110\32\40\83\116\111\114\121\41\46")
