-- Urasi

local Urasi = {}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")

local function tween(obj, props, info)
	info = info or TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function addCorners(parent, color)
	local thick, length = 2, 12
	local positions = {
		{UDim2.new(0,0,0,0), UDim2.new(0, length, 0, thick)},
		{UDim2.new(0,0,0,0), UDim2.new(0, thick, 0, length)},
		{UDim2.new(1,-length,0,0), UDim2.new(0, length, 0, thick)},
		{UDim2.new(1,-thick,0,0), UDim2.new(0, thick, 0, length)},
		{UDim2.new(0,0,1,-thick), UDim2.new(0, length, 0, thick)},
		{UDim2.new(0,0,1,-length), UDim2.new(0, thick, 0, length)},
		{UDim2.new(1,-length,1,-thick), UDim2.new(0, length, 0, thick)},
		{UDim2.new(1,-thick,1,-length), UDim2.new(0, thick, 0, length)},
	}
	for _, dat in ipairs(positions) do
		local line = Instance.new("Frame", parent)
		line.BackgroundColor3 = color or Color3.fromRGB(255, 0, 85)
		line.BorderSizePixel = 0
		line.Position = dat[1]
		line.Size = dat[2]
	end
end

local function applyGrid(frame)
	local grid = Instance.new("ImageLabel", frame)
	grid.Size = UDim2.new(1, 0, 1, 0)
	grid.BackgroundTransparency = 1
	grid.Image = "rbxassetid://2151741365"
	grid.ImageTransparency = 0.95
	grid.ScaleType = Enum.ScaleType.Tile
	grid.TileSize = UDim2.new(0, 40, 0, 40)
	grid.ZIndex = 0
	grid.Parent = frame
end

local function makeLabel(parent, text, size, font, color, xAlign)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.BorderSizePixel = 0
	l.Text = text or "Label"
	l.Font = font
	l.TextSize = size
	l.TextColor3 = color
	l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.TextStrokeTransparency = 1
	l.RichText = false
	l.Parent = parent
	return l
end

local function makeDraggable(topbar, mainFrame)
	local dragging, dragInput, dragStart, startPos
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)
	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	topbar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

function Urasi:CreateWindow(config)
	local self = {}
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local TOGGLE_KEY = config.Keybind or Enum.KeyCode.LeftAlt
	local ACCENT = config.Accent or Color3.fromRGB(255, 0, 85)
	local BG_PANEL = config.Background or Color3.fromRGB(8, 8, 12)
	local TEXT_MAIN = Color3.fromRGB(255, 255, 255)
	local TEXT_DIM = Color3.fromRGB(120, 120, 120)

	local FONT_TITLE = Enum.Font.GothamBlack
	local FONT_BODY = Enum.Font.GothamMedium
	local FONT_CODE = Enum.Font.Code
	
	local OPEN_TWEEN = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local CLOSE_TWEEN = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	local gui = Instance.new("ScreenGui")
	gui.Name = "UrasiLib"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	local root = Instance.new("Frame")
	root.Name = "Root"
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.Parent = gui

	local dim = Instance.new("Frame", root)
	dim.Name = "Dim"
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Color3.new(0, 0, 0)
	dim.BackgroundTransparency = 0.35

	local blur = Lighting:FindFirstChild("UrasiBlur") :: BlurEffect?
	if not blur then
		blur = Instance.new("BlurEffect")
		blur.Name = "UrasiBlur"
		blur.Size = 0
		blur.Parent = Lighting
	end

	local topBar = Instance.new("Frame", root)
	topBar.Size = UDim2.new(0, 700, 0, 22)
	topBar.Position = UDim2.new(0.5, -350, 0, 20)
	topBar.BackgroundColor3 = BG_PANEL
	topBar.BackgroundTransparency = 0.2
	addCorners(topBar, ACCENT)

	local statsLabel = Instance.new("TextLabel", topBar)
	statsLabel.Size = UDim2.new(1, 0, 1, 0)
	statsLabel.BackgroundTransparency = 1
	statsLabel.Font = FONT_CODE
	statsLabel.TextSize = 11
	statsLabel.TextColor3 = ACCENT
	statsLabel.Text = "Urasi Lib v1.0 | Initializing..."

	local mainPanel = Instance.new("Frame", root)
	mainPanel.Size = UDim2.new(0, 950, 0, 520)
	mainPanel.Position = UDim2.new(0.5, -620, 0.5, -260)
	mainPanel.BackgroundColor3 = BG_PANEL
	mainPanel.BackgroundTransparency = 0.1
	mainPanel.BorderSizePixel = 0
	addCorners(mainPanel, ACCENT)
	applyGrid(mainPanel)

	local mainDrag = Instance.new("Frame", mainPanel)
	mainDrag.Size = UDim2.new(1, 0, 0, 40)
	mainDrag.BackgroundTransparency = 1
	makeDraggable(mainDrag, mainPanel)

	local title = makeLabel(mainPanel, config.Title or "Urasi", 55, FONT_TITLE, TEXT_MAIN)
	title.Position = UDim2.new(0, 40, 0, 30)
	title.Size = UDim2.new(0, 300, 0, 60)

	local buildInfo = makeLabel(mainPanel, "Version: 1.0.0 // User: " .. player.Name, 12, FONT_TITLE, TEXT_MAIN)
	buildInfo.Position = UDim2.new(0, 42, 0, 85)
	buildInfo.Size = UDim2.new(0, 300, 0, 15)

	local barcode = makeLabel(mainPanel, "||||||| | ||| || ||| | || ||||| || |||", 14, FONT_TITLE, TEXT_MAIN)
	barcode.Position = UDim2.new(0, 42, 0, 100)
	barcode.Size = UDim2.new(0, 300, 0, 15)

	local sidebar = Instance.new("Frame", mainPanel)
	sidebar.Size = UDim2.new(0, 160, 0, 360)
	sidebar.Position = UDim2.new(0, 30, 0, 130)
	sidebar.BackgroundTransparency = 1
	
	local sidebarLayout = Instance.new("UIListLayout", sidebar)
	sidebarLayout.Padding = UDim.new(0, 15)
	sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local contentArea = Instance.new("Frame", mainPanel)
	contentArea.Size = UDim2.new(0, 720, 0, 360)
	contentArea.Position = UDim2.new(0, 200, 0, 130)
	contentArea.BackgroundTransparency = 1
	addCorners(contentArea, ACCENT)

	local subHeader = makeLabel(mainPanel, "ZONE A-1 | MODULE_CORE", 11, FONT_TITLE, ACCENT)
	subHeader.Position = UDim2.new(0, 200, 0, 110)
	subHeader.Size = UDim2.new(0, 200, 0, 15)

	local uiElements = {}
	local activeFadeTweens = {}
	local function captureUI(obj)
		local prop = nil
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then prop = "TextTransparency"
		elseif obj:IsA("ImageLabel") then prop = "ImageTransparency"
		elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then prop = "BackgroundTransparency" end
		if prop then table.insert(uiElements, {obj = obj, prop = prop, original = obj[prop]}) end
		for _, child in ipairs(obj:GetChildren()) do captureUI(child) end
	end
	for _, child in ipairs(root:GetChildren()) do captureUI(child) end

	local function fadeUI(target, duration)
		for _, t in ipairs(activeFadeTweens) do t:Cancel() end
		table.clear(activeFadeTweens)
		local info = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		for _, entry in ipairs(uiElements) do
			local val = (target == 1 and 1) or entry.original
			local t = TweenService:Create(entry.obj, info, {[entry.prop] = val})
			t:Play()
			table.insert(activeFadeTweens, t)
		end
		return activeFadeTweens
	end

	local isVisible = true
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == TOGGLE_KEY then
			isVisible = not isVisible
			if isVisible then
				root.Visible = true
				fadeUI(0, 0.28)
				tween(mainPanel, {Position = UDim2.new(0.5, -620, 0.5, -260)}, OPEN_TWEEN)
				tween(blur, {Size = 15}, OPEN_TWEEN)
			else
				fadeUI(1, 0.22)
				tween(mainPanel, {Position = UDim2.new(0.5, -620, 0.5, -210)}, CLOSE_TWEEN)
				tween(blur, {Size = 0}, CLOSE_TWEEN)
				local slideTween = tween(mainPanel, {Position = UDim2.new(0.5, -620, 0.5, -210)}, CLOSE_TWEEN)
				slideTween.Completed:Wait()
				if not isVisible then root.Visible = false end
			end
		end
	end)

	task.delay(0.1, function()
		root.Visible = true
		mainPanel.Position = UDim2.new(0.5, -620, 0.5, -210)
		fadeUI(0, 0.35)
		tween(mainPanel, {Position = UDim2.new(0.5, -620, 0.5, -260)}, OPEN_TWEEN)
		tween(blur, {Size = 15}, OPEN_TWEEN)
	end)

	local tabButtons = {}
	local tabFrames = {}
	local currentTab = nil

	local function createTab(name)
		local btn = Instance.new("TextButton", sidebar)
		btn.Size = UDim2.new(1, 0, 0, 20)
		btn.Text = "» " .. name
		btn.Font = FONT_TITLE
		btn.TextSize = 15
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.BackgroundTransparency = 1
		btn.TextColor3 = TEXT_DIM

		local frame = Instance.new("Frame", contentArea)
		frame.Size = UDim2.new(1, -20, 1, -20)
		frame.Position = UDim2.new(0, 15, 0, 10)
		frame.BackgroundTransparency = 1
		frame.Visible = false

		local accentBar = Instance.new("Frame", btn)
		accentBar.Size = UDim2.new(0, 0, 0, 18)
		accentBar.Position = UDim2.new(0, -6, 0.5, -9)
		accentBar.BackgroundColor3 = ACCENT
		accentBar.BackgroundTransparency = 1 
		accentBar.BorderSizePixel = 0
		
		btn.MouseButton1Click:Connect(function()
			if currentTab == name then return end
			
			if currentTab and tabButtons[currentTab] then
				local oldBtn = tabButtons[currentTab]
				oldBtn.Text = oldBtn.Text:gsub("» ", "")
				tween(oldBtn, {TextColor3 = TEXT_DIM}, TweenInfo.new(0.2))
				local oldBar = oldBtn:FindFirstChild("AccentBar")
				if oldBar then 
					tween(oldBar, {Size = UDim2.new(0, 0, 0, 18)}, TweenInfo.new(0.2))
					tween(oldBar, {BackgroundTransparency = 1}, TweenInfo.new(0.2))
				end
				tween(tabFrames[currentTab], {Position = UDim2.new(0, 15, 0, 10)}, TweenInfo.new(0.2))
			end
			
			currentTab = name
			
			btn.Text = "» " .. name
			tween(btn, {TextColor3 = TEXT_MAIN}, TweenInfo.new(0.2))
			tween(accentBar, {Size = UDim2.new(0, 6, 0, 18)}, TweenInfo.new(0.2))
			tween(accentBar, {BackgroundTransparency = 0}, TweenInfo.new(0.2))
			
			frame.Visible = true
			frame.Position = UDim2.new(0, 30, 0, 10)
			tween(frame, {Position = UDim2.new(0, 10, 0, 10)}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
		end)
		
		tabButtons[name] = btn
		tabFrames[name] = frame
		return frame
	end

	function self:CreateTab(name)
		local frame = createTab(name)
		
		if currentTab == nil then
			local btn = tabButtons[name]
			btn.Text = "» " .. name
			btn.TextColor3 = TEXT_MAIN
			local bar = btn:FindFirstChild("AccentBar")
			if bar then 
				bar.Size = UDim2.new(0, 6, 0, 18)
				bar.BackgroundTransparency = 0
			end
			frame.Visible = true
			frame.Position = UDim2.new(0, 10, 0, 10)
			currentTab = name
		end

		return {
			_Frame = frame,
			_TabName = name,
			CreateToggle = function(config)
				local toggleText = tostring(config.Text)
				if toggleText == "nil" or toggleText == "" then
					toggleText = "Toggle"
				end
				
				local holder = Instance.new("Frame", frame)
				holder.Size = UDim2.new(0, 210, 0, 32)
				holder.Position = config.Pos or UDim2.new(0, 10, 0, 10)
				holder.BackgroundTransparency = 1

				local boxBg = Instance.new("Frame", holder)
				boxBg.Size = UDim2.new(1, 0, 1, 0)
				boxBg.BackgroundColor3 = BG_PANEL
				boxBg.BackgroundTransparency = 1
				boxBg.BorderSizePixel = 0
				addCorners(boxBg, Color3.fromRGB(40,40,45))
				
				local label = makeLabel(holder, toggleText .. " [OFF]", 12, FONT_BODY, TEXT_MAIN)
				label.Size = UDim2.new(1, -10, 1, -10)
				label.Position = UDim2.new(0, 10, 0, 0)
				label.TextXAlignment = Enum.TextXAlignment.Left

				local accentBar = Instance.new("Frame", boxBg)
				accentBar.Size = UDim2.new(0, 0, 0, 2)
				accentBar.Position = UDim2.new(0, 0, 1, -4)
				accentBar.BackgroundColor3 = ACCENT
				accentBar.BackgroundTransparency = 1

				local btn = Instance.new("TextButton", holder)
				btn.Size = UDim2.new(1, 0, 1, 0)
				btn.BackgroundTransparency = 1
				btn.Text = ""

				local state = false
				local toggleObj = {
					State = false,
					SetState = function(newState)
						state = newState
						label.Text = toggleText .. (state and " [ON]" or " [OFF]")
						if state then
							tween(label, {TextColor3 = ACCENT}, TweenInfo.new(0.2))
							tween(boxBg, {BackgroundTransparency = 0.9}, TweenInfo.new(0.2))
							tween(accentBar, {BackgroundTransparency = 0, Size = UDim2.new(1, -10, 0, 2)}, TweenInfo.new(0.2)) 
						else
							tween(label, {TextColor3 = TEXT_MAIN}, TweenInfo.new(0.2))
							tween(boxBg, {BackgroundTransparency = 1}, TweenInfo.new(0.2))
							tween(accentBar, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 2)}, TweenInfo.new(0.2))
						end
						if config.Callback then config.Callback(state) end
					end,
					GetState = function() return state end
				}

				btn.MouseButton1Click:Connect(function()
					toggleObj:SetState(not state)
				end)
				return toggleObj
			end,
			CreateSlider = function(config)
				local holder = Instance.new("Frame", frame)
				holder.Size = UDim2.new(0, 210, 0, 40)
				holder.Position = config.Pos or UDim2.new(0, 10, 0, 10)
				holder.BackgroundTransparency = 1

				local label = makeLabel(holder, config.Text .. ": " .. config.Default, 11, FONT_BODY, ACCENT)
				label.Size = UDim2.new(1, 0, 0, 15)
				label.TextXAlignment = Enum.TextXAlignment.Left

				local barBg = Instance.new("Frame", holder)
				barBg.Size = UDim2.new(1, 0, 0, 2)
				barBg.Position = UDim2.new(0, 0, 0, 23)
				barBg.BackgroundColor3 = Color3.fromRGB(40, 20, 30)
				barBg.BorderSizePixel = 0

				local barFill = Instance.new("Frame", barBg)
				barFill.Size = UDim2.new((config.Default-config.Min)/(config.Max-config.Min), 0, 1, 0)
				barFill.BackgroundColor3 = ACCENT
				barFill.BorderSizePixel = 0

				local marker = Instance.new("Frame", barFill)
				marker.Size = UDim2.new(0, 6, 0, 14)
				marker.Position = UDim2.new(1, -3, 0.5, -7)
				marker.BackgroundColor3 = TEXT_MAIN
				marker.BorderSizePixel = 0
				local markerCorner = Instance.new("UICorner")
				markerCorner.CornerRadius = UDim.new(0, 2)
				markerCorner.Parent = marker

				local btn = Instance.new("TextButton", holder)
				btn.Size = UDim2.new(1, 0, 0, 20)
				btn.Position = UDim2.new(0, 0, 0, 12)
				btn.BackgroundTransparency = 1
				btn.Text = ""

				local dragging = false
				local currentVal = config.Default
				local sliderObj = {
					Value = currentVal,
					GetValue = function() return currentVal end,
					SetValue = function(v)
						v = math.clamp(v, config.Min, config.Max)
						currentVal = v
						local pct = (v - config.Min) / (config.Max - config.Min)
						tween(barFill, {Size = UDim2.new(pct, 0, 1, 0)}, TweenInfo.new(0.1))
						label.Text = config.Text .. ": " .. v
						if config.Callback then config.Callback(v) end
					end
				}

				btn.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						tween(marker, {Size = UDim2.new(0, 10, 0, 22), BackgroundColor3 = ACCENT}, TweenInfo.new(0.1))
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
						dragging = false
						tween(marker, {Size = UDim2.new(0, 6, 0, 14), BackgroundColor3 = TEXT_MAIN}, TweenInfo.new(0.1))
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						local pct = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
						local v = math.floor((config.Min + (config.Max - config.Min) * pct) * 10) / 10
						sliderObj:SetValue(v)
					end
				end)
				return sliderObj
			end
		}
	end

	function self:CreatePlayerList()
		local previewPanel = Instance.new("Frame", root)
		previewPanel.Size = UDim2.new(0, 220, 0, 520)
		previewPanel.Position = UDim2.new(0.5, 360, 0.5, -260)
		previewPanel.BackgroundColor3 = BG_PANEL
		previewPanel.BackgroundTransparency = 0.1
		previewPanel.BorderSizePixel = 0
		addCorners(previewPanel, ACCENT)
		applyGrid(previewPanel)
		makeDraggable(previewPanel, previewPanel)

		local prevTitle = makeLabel(previewPanel, "PLAYER LIST", 12, FONT_TITLE, ACCENT)
		prevTitle.Position = UDim2.new(0, 10, 0, 8)
		prevTitle.Size = UDim2.new(1, -20, 0, 16)

		local prevSub = makeLabel(previewPanel, "ONLINE: 0", 9, FONT_CODE, TEXT_DIM)
		prevSub.Position = UDim2.new(0, 10, 0, 22)
		prevSub.Size = UDim2.new(1, -20, 0, 14)

		local listScroller = Instance.new("ScrollingFrame")
		listScroller.Size = UDim2.new(1, -10, 1, -45)
		listScroller.Position = UDim2.new(0, 5, 0, 35)
		listScroller.BackgroundTransparency = 1
		listScroller.BorderSizePixel = 0
		listScroller.ScrollBarThickness = 2
		listScroller.ScrollBarImageColor3 = ACCENT
		listScroller.Parent = previewPanel

		local listLayout = Instance.new("UIListLayout")
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0, 1)
		listLayout.Parent = listScroller
		
		listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			listScroller.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
		end)

		local listObj = {}
		local function GetPlayerTeam(p)
			local attrTeam = p:GetAttribute("Team")
			if attrTeam and type(attrTeam) == "string" and attrTeam ~= "" then return attrTeam end
			return p.Team and p.Team.Name or "No Team"
		end

		function listObj:Update()
			for _, child in ipairs(listScroller:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end

			local players = Players:GetPlayers()
			local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

			local teams = {}
			for _, p in ipairs(players) do
				local teamName = GetPlayerTeam(p)
				if not teams[teamName] then teams[teamName] = {} end
				table.insert(teams[teamName], p)
			end

			local sortedTeamNames = {}
			for teamName, _ in pairs(teams) do table.insert(sortedTeamNames, teamName) end
			table.sort(sortedTeamNames)

			local order = 0
			for _, teamName in ipairs(sortedTeamNames) do
				local teamPlayers = teams[teamName]
				
				local header = Instance.new("Frame")
				header.Size = UDim2.new(1, -5, 0, 16)
				header.BackgroundTransparency = 1
				header.LayoutOrder = order
				order += 1
				header.Parent = listScroller

				local headerTitle = makeLabel(header, string.upper(teamName), 10, FONT_TITLE, ACCENT)
				headerTitle.Size = UDim2.new(1, 0, 1, 0)
				headerTitle.TextXAlignment = Enum.TextXAlignment.Left

				table.sort(teamPlayers, function(a, b) return a.Name < b.Name end)

				for _, p in ipairs(teamPlayers) do
					local row = Instance.new("Frame")
					row.Size = UDim2.new(1, -5, 0, 16)
					row.BackgroundTransparency = 1
					row.LayoutOrder = order
					order += 1
					row.Parent = listScroller

					local colorDot = Instance.new("Frame")
					colorDot.Size = UDim2.new(0, 8, 0, 8)
					colorDot.Position = UDim2.new(0, 0, 0.5, -4)
					colorDot.BackgroundColor3 = p.Team and p.TeamColor.Color or Color3.fromRGB(150, 150, 150)
					colorDot.BorderSizePixel = 0
					colorDot.Parent = row
					local dotCorner = Instance.new("UICorner")
					dotCorner.CornerRadius = UDim.new(0, 2)
					dotCorner.Parent = colorDot

					local nameLabel = makeLabel(row, p.Name, 10, FONT_BODY, TEXT_MAIN)
					nameLabel.Size = UDim2.new(1, -65, 1, 0)
					nameLabel.Position = UDim2.new(0, 14, 0, 0)
					nameLabel.TextXAlignment = Enum.TextXAlignment.Left
					nameLabel.TextTruncate = Enum.TextTruncate.AtEnd

					local dist = 0
					if rootPart and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
						dist = math.floor((rootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude)
					end
					local distLabel = makeLabel(row, string.format("%.0fm", dist), 9, FONT_CODE, TEXT_DIM)
					distLabel.Size = UDim2.new(0, 60, 1, 0)
					distLabel.Position = UDim2.new(1, -5, 0, 0)
					distLabel.TextXAlignment = Enum.TextXAlignment.Right
				end
			end
			prevSub.Text = string.format("ONLINE: %d", #players)
		end

		task.spawn(function()
			while task.wait(0.5) do
				listObj:Update()
			end
		end)

		return listObj
	end

	local startTime = tick()
	local frames = 0
	local worldName = game.Name
	task.spawn(function()
		while task.wait(0.1) do
			frames += 1
			if frames % 10 == 0 then
				local fps = math.floor(workspace:GetRealPhysicsFPS())
				local runTime = tick() - startTime
				local h = math.floor(runTime / 3600)
				local m = math.floor((runTime % 3600) / 60)
				local s = math.floor(runTime % 60)

				local pos = Vector3.zero
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					pos = player.Character.HumanoidRootPart.Position
				end
				statsLabel.Text = string.format(
					"FPS: %03d | RAM: %.0fMB | STAY: %02d:%02d:%02d | POS: %.0f, %.0f, %.0f | WORLD: %s",
					fps,
					Stats:GetTotalMemoryUsageMb(),
					h, m, s,
					pos.X, pos.Y, pos.Z,
					worldName
				)
			end
		end
	end)

	return self
end

return Urasi
