local UILibrary = {}
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
UILibrary.CurrentTabSelect = nil
UILibrary.CurrentModSelect = nil

local CurrentUICreated = {}

local UIConfigFrame = {
	["DropDown"] = function(Config,Parent,SaveProp)
		local dropdown = Instance.new("Frame")
		dropdown.Name = "Dropdown"
		dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dropdown.BackgroundTransparency = 1
		dropdown.LayoutOrder = 0
		dropdown.Size = UDim2.fromScale(1, 0.1)

		local background = Instance.new("TextButton")
		background.Name = "Background"
		background.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
		background.Text = ""
		background.TextColor3 = Color3.fromRGB(255, 255, 255)
		background.TextSize = 14
		background.AutoButtonColor = false
		background.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		background.BorderSizePixel = 0
		background.Position = UDim2.fromScale(0.05, 0)
		background.Size = UDim2.fromScale(0.923, 1)

		local uICorner = Instance.new("UICorner")
		uICorner.Name = "UICorner"
		uICorner.Parent = background

		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.FontFace = Font.new(
			"rbxasset://fonts/families/GothamSSm.json",
			Enum.FontWeight.Bold,
			Enum.FontStyle.Normal
		)
		title.Text = Config.DisplayText or "I DONT KNOW ANYMORE"
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		title.BackgroundTransparency = 1
		title.Position = UDim2.fromScale(0.0228, 0)
		title.Size = UDim2.fromScale(0.477, 1)
		title.Parent = background

		local arrowImg = Instance.new("ImageLabel")
		arrowImg.Name = "ArrowImg"
		arrowImg.Image = "http://www.roblox.com/asset/?id=6034818372"
		arrowImg.ImageColor3 = Color3.fromRGB(212, 212, 212)
		arrowImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		arrowImg.BackgroundTransparency = 1
		arrowImg.Position = UDim2.fromScale(0.943, -0.0192)
		arrowImg.Size = UDim2.fromScale(0.05, 1)
		arrowImg.Parent = background

		background.Parent = dropdown
		dropdown.Parent = Parent

		--// Create DropDown Plus
		local dropdownPlus = Instance.new("Frame")
		dropdownPlus.Name = "DropdownPlus"
		dropdownPlus.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dropdownPlus.BackgroundTransparency = 1
		dropdownPlus.Position = UDim2.fromScale(0.0797, 0.445)
		dropdownPlus.Size = UDim2.new(1, 0, 0, 73)
		dropdownPlus.Visible = false
		local dropDownBackground = Instance.new("TextButton")
		dropDownBackground.Name = "DropDownBackground"
		dropDownBackground.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
		dropDownBackground.Text = ""
		dropDownBackground.TextColor3 = Color3.fromRGB(255, 255, 255)
		dropDownBackground.TextSize = 14
		dropDownBackground.AutoButtonColor = false
		dropDownBackground.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		dropDownBackground.BorderSizePixel = 0
		dropDownBackground.Position = UDim2.fromScale(0.05, 0)
		dropDownBackground.Size = UDim2.fromScale(0.922, 1)

		local uICorner = Instance.new("UICorner")
		uICorner.Name = "UICorner"
		uICorner.Parent = dropDownBackground

		local itemHolder = Instance.new("ScrollingFrame")
		itemHolder.Name = "ItemHolder"
		itemHolder.CanvasSize = UDim2.new()
		itemHolder.ScrollBarImageColor3 = Color3.fromRGB(28, 29, 32)
		itemHolder.ScrollBarThickness = 6
		itemHolder.Active = true
		itemHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		itemHolder.BackgroundTransparency = 1
		itemHolder.BorderSizePixel = 0
		itemHolder.Position = UDim2.fromScale(0.0223, 0)
		itemHolder.Size = UDim2.fromScale(0.959, 1)

		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Name = "UIListLayout"
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = itemHolder

		itemHolder.Parent = dropDownBackground

		dropDownBackground.Parent = dropdownPlus
		dropdownPlus.Parent = Parent
		background.MouseButton1Click:Connect(function()
			dropdownPlus.Visible = not dropdownPlus.Visible
		end)

		local function PickChanged()
			title.Text = (Config.DisplayText or "I DONT KNOW ANYMORE") .. ": " .. Config.Value
		end

		--// Create List for dropdown
		for i , v in pairs(Config.List) do
			local item = Instance.new("TextButton")
			item.Name = "Item"
			item.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
			item.Text = ""
			item.TextColor3 = Color3.fromRGB(0, 0, 0)
			item.TextSize = 14
			item.AutoButtonColor = false
			item.BackgroundColor3 = Color3.fromRGB(42, 44, 48)
			item.BackgroundTransparency = 1
			item.Size = UDim2.fromOffset(379, 29)

			local itemCorner = Instance.new("UICorner")
			itemCorner.Name = "ItemCorner"
			itemCorner.CornerRadius = UDim.new(0, 4)
			itemCorner.Parent = item

			local itemText = Instance.new("TextLabel")
			itemText.Name = "ItemText"
			itemText.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
			itemText.Text = v or "passionfruit"
			itemText.TextColor3 = Color3.fromRGB(212, 212, 212)
			itemText.TextSize = 14
			itemText.TextXAlignment = Enum.TextXAlignment.Left
			itemText.BackgroundColor3 = Color3.fromRGB(42, 44, 48)
			itemText.BackgroundTransparency = 1
			itemText.Position = UDim2.fromScale(0.0211, 0)
			itemText.Size = UDim2.fromOffset(192, 29)
			itemText.Parent = item
			item.Parent = itemHolder
			item.MouseButton1Click:Connect(function()
				Config.Value = v
				PickChanged()
				dropdownPlus.Visible = false
				if Config.Callback then
					SaveProp[Config.DisplayText] = Config.Value
					Config.Callback(Config.Value)
				end
			end)
			itemHolder.CanvasSize = UDim2.new(0,0,0,uIListLayout.AbsoluteContentSize.Y)
		end
		PickChanged()
	end,
	["Label"] = function(Config, Parent)
		local label = Instance.new("Frame")
		label.Name = "Label"
		label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 0.06)

		local bar = Instance.new("Frame")
		bar.Name = "Bar"
		bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		bar.BorderSizePixel = 0
		bar.Position = UDim2.fromScale(0.05, 0)
		bar.Size = UDim2.fromScale(0.005, 1)
		bar.Parent = label

		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.FontFace =
			Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		title.Text = Config.DisplayText or "Label here"
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.TextScaled = true
		title.TextSize = 14
		title.TextTransparency = 0.3
		title.TextWrapped = true
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.AnchorPoint = Vector2.new(0, 0.5)
		title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		title.BackgroundTransparency = 1
		title.BorderSizePixel = 0
		title.Position = UDim2.fromScale(0.071, 0.5)
		title.Size = UDim2.fromScale(1, 0.784)
		title.Parent = label
		label.Parent = Parent
		return
	end,
	["Slider"] = function(Config, Parent,SaveProp)
		local dragging = false

		local slider = Instance.new("Frame")
		slider.Name = "Slider"
		slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		slider.BackgroundTransparency = 1
		slider.Size = UDim2.fromScale(1, 0.1)
		slider.Parent = Parent
		local background = Instance.new("TextButton")
		background.Name = "Background"
		background.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
		background.Text = ""
		background.TextColor3 = Color3.fromRGB(255, 255, 255)
		background.TextSize = 14
		background.AutoButtonColor = false
		background.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		background.BorderSizePixel = 0
		background.Position = UDim2.fromScale(0.05, 0)
		background.Size = UDim2.fromScale(0.923, 1)

		local uICorner = Instance.new("UICorner")
		uICorner.Name = "UICorner"
		uICorner.Parent = background

		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.FontFace =
			Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		title.Text = Config.DisplayText or "I DONT KNOW ANYMORE"
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		title.BackgroundTransparency = 1
		title.Position = UDim2.fromScale(0.0228, 0)
		title.Size = UDim2.fromScale(0.477, 1)
		title.Parent = background

		local sliderFrame = Instance.new("Frame")
		sliderFrame.Name = "SliderFrame"
		sliderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		sliderFrame.BackgroundColor3 = Color3.fromRGB(79, 84, 92)
		sliderFrame.Position = UDim2.fromScale(0.8, 0.5)
		sliderFrame.Size = UDim2.fromScale(0.253, 0.192)

		local sliderFrameCorner = Instance.new("UICorner")
		sliderFrameCorner.Name = "SliderFrameCorner"
		sliderFrameCorner.Parent = sliderFrame

		local currentValueFrame = Instance.new("Frame")
		currentValueFrame.Name = "CurrentValueFrame"
		currentValueFrame.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
		currentValueFrame.Size = UDim2.new((Config.Default or 0) / Config.Max, 0, 0, 8)

		local currentValueFrameCorner = Instance.new("UICorner")
		currentValueFrameCorner.Name = "CurrentValueFrameCorner"
		currentValueFrameCorner.Parent = currentValueFrame

		currentValueFrame.Parent = sliderFrame

		local zip = Instance.new("Frame")
		zip.Name = "Zip"
		zip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		zip.Position = UDim2.new(0.1, -6, -0.645, 0)
		zip.Size = UDim2.fromOffset(10, 18)

		local zipCorner = Instance.new("UICorner")
		zipCorner.Name = "ZipCorner"
		zipCorner.CornerRadius = UDim.new(0, 3)
		zipCorner.Parent = zip

		zip.Parent = sliderFrame

		sliderFrame.Parent = background

		local valueDisplay = Instance.new("Frame")
		valueDisplay.Name = "ValueDisplay"
		valueDisplay.AnchorPoint = Vector2.new(0.5, 0.5)
		valueDisplay.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
		valueDisplay.Position = UDim2.fromScale(0.6, 0.5)
		valueDisplay.Size = UDim2.fromOffset(36, 21)

		local valueBubbleCorner = Instance.new("UICorner")
		valueBubbleCorner.Name = "ValueBubbleCorner"
		valueBubbleCorner.CornerRadius = UDim.new(0, 3)
		valueBubbleCorner.Parent = valueDisplay

		local valueLabel = Instance.new("TextLabel")
		valueLabel.Name = "ValueLabel"
		valueLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
		valueLabel.Text = "1"
		valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		valueLabel.TextSize = 10
		valueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		valueLabel.BackgroundTransparency = 1
		valueLabel.Size = UDim2.fromOffset(36, 21)
		valueLabel.Parent = valueDisplay

		local glowBubble = Instance.new("ImageLabel")
		glowBubble.Name = "GlowBubble"
		glowBubble.Image = "rbxassetid://4996891970"
		glowBubble.ImageColor3 = Color3.fromRGB(15, 15, 15)
		glowBubble.ScaleType = Enum.ScaleType.Slice
		glowBubble.SliceCenter = Rect.new(20, 20, 280, 280)
		glowBubble.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		glowBubble.BackgroundTransparency = 1
		glowBubble.BorderSizePixel = 0
		glowBubble.Position = UDim2.fromOffset(-15, -15)
		glowBubble.Size = UDim2.new(1, 30, 1, 30)
		glowBubble.ZIndex = 0
		glowBubble.Parent = valueDisplay

		valueDisplay.Parent = background

		background.Parent = slider

		local function move(input)
			local pos = UDim2.new(
				math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1),
				-6,
				-0.644999981,
				0
			)
			local pos1 = UDim2.new(
				math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1),
				0,
				0,
				8
			)
			currentValueFrame.Size = pos1
			zip.Position = pos
			local value = math.floor(((pos.X.Scale * Config.Max) / Config.Max) * (Config.Max - Config.Min) + Config.Min)
			valueLabel.Text = tostring(value)
			Config.Default = value
			SaveProp[Config.DisplayText] = value
			pcall(Config.Callback, value)
		end

		zip.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
			end
		end)
		zip.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		game:GetService("UserInputService").InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				move(input)
			end
		end)


		local function Changed(tochange)
			currentValueFrame.Size = UDim2.new((tochange or 0) / Config.Max, 0, 0, 8)
			zip.Position = UDim2.new((tochange or 0) / Config.Max, -6, -0.644999981, 0)
			valueLabel.Text = tostring(tochange and math.floor((tochange / Config.Max) * (Config.Max - Config.Min) + Config.Min) or 0)
		end
		Changed(Config.Default)
		return
	end,
	["Toggle"] = function(Config, Parent,SaveProp)
		local toggle = Instance.new("Frame")
		toggle.Name = "Toggle"
		toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggle.BackgroundTransparency = 1
		toggle.Size = UDim2.fromScale(1, 0.1)

		local background = Instance.new("TextButton")
		background.Name = "Background"
		background.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
		background.Text = ""
		background.TextColor3 = Color3.fromRGB(255, 255, 255)
		background.TextSize = 14
		background.AutoButtonColor = false
		background.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		background.BorderSizePixel = 0
		background.Position = UDim2.fromScale(0.05, 0)
		background.Size = UDim2.fromScale(0.923, 1)

		local toggleTitle = Instance.new("TextLabel")
		toggleTitle.Name = "ToggleTitle"
		toggleTitle.FontFace =
			Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		toggleTitle.Text = Config.DisplayText or "I DONT KNOW ANYMORE"
		toggleTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		toggleTitle.TextSize = 14
		toggleTitle.TextXAlignment = Enum.TextXAlignment.Left
		toggleTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleTitle.BackgroundTransparency = 1
		toggleTitle.Position = UDim2.fromScale(0.0228, 0)
		toggleTitle.Size = UDim2.fromScale(0.477, 1)
		toggleTitle.Parent = background

		local toggleFrame = Instance.new("Frame")
		toggleFrame.Name = "ToggleFrame"
		toggleFrame.AnchorPoint = Vector2.new(0, 0.5)
		toggleFrame.BackgroundColor3 = Color3.fromRGB(114, 118, 125)
		toggleFrame.Position = UDim2.new(0.9, -5, 0.5, 0)
		toggleFrame.Size = UDim2.fromOffset(40, 21)

		local toggleFrameCorner = Instance.new("UICorner")
		toggleFrameCorner.Name = "ToggleFrameCorner"
		toggleFrameCorner.CornerRadius = UDim.new(1, 8)
		toggleFrameCorner.Parent = toggleFrame

		local toggleFrameCircle = Instance.new("Frame")
		toggleFrameCircle.Name = "ToggleFrameCircle"
		toggleFrameCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleFrameCircle.Position = UDim2.new(0.235, -5, 0.133, 0)
		toggleFrameCircle.Size = UDim2.fromOffset(15, 15)

		local toggleFrameCircleCorner = Instance.new("UICorner")
		toggleFrameCircleCorner.Name = "ToggleFrameCircleCorner"
		toggleFrameCircleCorner.CornerRadius = UDim.new(1, 0)
		toggleFrameCircleCorner.Parent = toggleFrameCircle

		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Image = "http://www.roblox.com/asset/?id=6035047409"
		icon.ImageColor3 = Color3.fromRGB(114, 118, 125)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		icon.BackgroundTransparency = 1
		icon.BorderColor3 = Color3.fromRGB(27, 42, 53)
		icon.Position = UDim2.fromOffset(8, 8)
		icon.Size = UDim2.fromOffset(13, 13)
		icon.Parent = toggleFrameCircle

		toggleFrameCircle.Parent = toggleFrame

		toggleFrame.Parent = background

		local uICorner = Instance.new("UICorner")
		uICorner.Name = "UICorner"
		uICorner.Parent = background

		background.Parent = toggle
		toggle.Parent = Parent
		local function ModToggleChanged(NewToggle)
			if NewToggle == true then
				TweenService:Create(
					icon,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ ImageColor3 = Color3.fromRGB(67, 181, 129) }
				):Play()
				TweenService:Create(
					toggleFrame,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ BackgroundColor3 = Color3.fromRGB(67, 181, 129) }
				):Play()
				toggleFrameCircle:TweenPosition(
					UDim2.new(0.655, -5, 0.133000001, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quart,
					0.3,
					true
				)
				TweenService:Create(
					icon,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ ImageTransparency = 1 }
				):Play()
				icon.Image = "http://www.roblox.com/asset/?id=6023426926"
				wait(0.1)
				TweenService:Create(
					icon,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ ImageTransparency = 0 }
				):Play()
			else
				TweenService:Create(
					icon,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ ImageColor3 = Color3.fromRGB(114, 118, 125) }
				):Play()
				TweenService:Create(
					toggleFrame,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ BackgroundColor3 = Color3.fromRGB(114, 118, 125) }
				):Play()
				toggleFrameCircle:TweenPosition(
					UDim2.new(0.234999999, -5, 0.133000001, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quart,
					0.3,
					true
				)
				TweenService:Create(
					icon,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ ImageTransparency = 1 }
				):Play()
				icon.Image = "http://www.roblox.com/asset/?id=6035047409"
				wait(0.1)
				TweenService:Create(
					icon,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ ImageTransparency = 0 }
				):Play()
			end
		end

		ModToggleChanged(Config.Value)
		background.MouseButton1Click:Connect(function()
			Config.Value = not Config.Value
			SaveProp[Config.DisplayText] = Config.Value

			ModToggleChanged(Config.Value)
			if Config.Callback then
				Config.Callback(Config.Value)
			end
		end)

		local togglefunc = {}
		function togglefunc:ForceToggle()
			Config.Value = not Config.Value
			ModToggleChanged(Config.Value)
			if Config.Callback then
				Config.Callback(Config.Value)
			end
		end

		return togglefunc
	end,
}

function UILibrary:new()
	local TabTable = {}

	local passionFruit = Instance.new("ScreenGui")
	passionFruit.Name = "PassionFruit"
	passionFruit.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local mainGui = Instance.new("Frame")
	mainGui.Name = "MainGui"
	mainGui.AnchorPoint = Vector2.new(0.5, 0.5)
	mainGui.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	mainGui.BackgroundTransparency = 1
	mainGui.Position = UDim2.fromScale(0.5, 0.5)
	mainGui.Size = UDim2.fromScale(0.5, 0.6)

	game:GetService("UserInputService").InputBegan:Connect(function(current, pressed)
        if not pressed then
            if current.KeyCode.Name == "RightShift" then
                mainGui.Visible = not mainGui.Visible
            end
        end
    end)

	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	bar.BackgroundTransparency = 0.1
	bar.Size = UDim2.fromScale(0.1, 1)

	local tab = Instance.new("Frame")
	tab.Name = "Tab"
	tab.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	tab.BackgroundTransparency = 1
	tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
	tab.BorderSizePixel = 5
	tab.Position = UDim2.fromScale(0, 0.16)
	tab.Size = UDim2.fromScale(1, 0.84)

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = tab

	tab.Parent = bar

	local icon = Instance.new("Frame")
	icon.Name = "icon"
	icon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	icon.BackgroundTransparency = 1
	icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	icon.BorderSizePixel = 5
	icon.Size = UDim2.fromScale(1, 0.16)

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ImageLabel"
	imageLabel.Image = "rbxassetid://8276080763"
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(0.7, 0.7)
	imageLabel.Parent = icon

	icon.Parent = bar

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.CornerRadius = UDim.new(0, 10)
	uICorner.Parent = bar

	bar.Parent = mainGui

	local modMenu = Instance.new("Frame")
	modMenu.Name = "ModMenu"
	modMenu.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	modMenu.BackgroundTransparency = 0.3
	modMenu.ClipsDescendants = true
	modMenu.Position = UDim2.fromScale(0.111, 0)
	modMenu.Size = UDim2.fromScale(0.89, 1)

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	topBar.ClipsDescendants = true
	topBar.Size = UDim2.fromScale(1, 0.103)

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "TextLabel"
	textLabel.FontFace =
		Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	textLabel.Text = "PassionFruit"
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.TextSize = 14
	textLabel.TextTransparency = 0.3
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.AnchorPoint = Vector2.new(0, 0.5)
	textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.Position = UDim2.fromScale(0.0188, 0.492)
	textLabel.Size = UDim2.fromScale(0.316, 0.737)
	textLabel.Parent = topBar

	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Position = UDim2.fromScale(0, 0.98)
	frame.Size = UDim2.fromScale(1, 0.02)
	frame.Parent = topBar

	local CurrentTabPickingLabel = Instance.new("TextLabel")
	CurrentTabPickingLabel.Name = "TextLabel"
	CurrentTabPickingLabel.FontFace =
		Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	CurrentTabPickingLabel.Text = "Pick a category"
	CurrentTabPickingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	CurrentTabPickingLabel.TextScaled = true
	CurrentTabPickingLabel.TextSize = 14
	CurrentTabPickingLabel.TextTransparency = 0.3
	CurrentTabPickingLabel.TextWrapped = true
	CurrentTabPickingLabel.TextXAlignment = Enum.TextXAlignment.Left
	CurrentTabPickingLabel.AnchorPoint = Vector2.new(0, 0.5)
	CurrentTabPickingLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	CurrentTabPickingLabel.BackgroundTransparency = 1
	CurrentTabPickingLabel.BorderSizePixel = 0
	CurrentTabPickingLabel.Position = UDim2.fromScale(0.348, 0.614)
	CurrentTabPickingLabel.Size = UDim2.fromScale(0.316, 0.266)
	CurrentTabPickingLabel.Parent = topBar

	topBar.Parent = modMenu

	local modList = Instance.new("Frame")
	modList.Name = "ModList"
	modList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	modList.BackgroundTransparency = 1
	modList.Position = UDim2.fromScale(0, 0.124)
	modList.Size = UDim2.fromScale(1, 0.876)
	modList.Parent = modMenu

	local uICorner1 = Instance.new("UICorner")
	uICorner1.Name = "UICorner"
	uICorner1.Parent = modMenu

	modMenu.Parent = mainGui

	local uISizeConstraint = Instance.new("UISizeConstraint")
	uISizeConstraint.Name = "UISizeConstraint"
	uISizeConstraint.MaxSize = Vector2.new(1.22e+03, 711)
	uISizeConstraint.MinSize = Vector2.new(712, 348)
	uISizeConstraint.Parent = mainGui

	local configurationframe = Instance.new("Frame")
	configurationframe.Name = "configuration"
	configurationframe.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	configurationframe.BackgroundTransparency = 0.3
	configurationframe.ClipsDescendants = true
	configurationframe.Position = UDim2.fromScale(0.111, 0)
	configurationframe.Size = UDim2.fromScale(0.89, 1)
	configurationframe.Visible = false

	local topBar1 = Instance.new("Frame")
	topBar1.Name = "TopBar"
	topBar1.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	topBar1.ClipsDescendants = true
	topBar1.Size = UDim2.fromScale(1, 0.103)

	local modSelectName = Instance.new("TextLabel")
	modSelectName.Name = "ModSelectName"
	modSelectName.FontFace =
		Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	modSelectName.Text = "ANIMATIONS"
	modSelectName.TextColor3 = Color3.fromRGB(255, 255, 255)
	modSelectName.TextScaled = true
	modSelectName.TextSize = 14
	modSelectName.TextTransparency = 0.3
	modSelectName.TextWrapped = true
	modSelectName.TextXAlignment = Enum.TextXAlignment.Left
	modSelectName.AnchorPoint = Vector2.new(0, 0.5)
	modSelectName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	modSelectName.BackgroundTransparency = 1
	modSelectName.BorderSizePixel = 0
	modSelectName.Position = UDim2.fromScale(0.0999, 0.5)
	modSelectName.Size = UDim2.fromScale(0.362, 0.737)
	modSelectName.Parent = topBar1

	local topBarBar = Instance.new("Frame")
	topBarBar.Name = "TopBarBar"
	topBarBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	topBarBar.BackgroundTransparency = 0.3
	topBarBar.BorderSizePixel = 0
	topBarBar.Position = UDim2.fromScale(0, 0.98)
	topBarBar.Size = UDim2.fromScale(1, 0.02)
	topBarBar.Parent = topBar1

	local modDescription = Instance.new("TextLabel")
	modDescription.Name = "ModDescription"
	modDescription.FontFace =
		Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	modDescription.Text = "The best way to play animation"
	modDescription.TextColor3 = Color3.fromRGB(255, 255, 255)
	modDescription.TextScaled = true
	modDescription.TextSize = 14
	modDescription.TextTransparency = 0.3
	modDescription.TextWrapped = true
	modDescription.TextXAlignment = Enum.TextXAlignment.Left
	modDescription.AnchorPoint = Vector2.new(0, 0.5)
	modDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	modDescription.BackgroundTransparency = 1
	modDescription.BorderSizePixel = 0
	modDescription.Position = UDim2.fromScale(0.461, 0.5)
	modDescription.Size = UDim2.fromScale(0.316, 0.502)
	modDescription.Parent = topBar1

	local textButton = Instance.new("TextButton")
	textButton.Name = "TextButton"
	textButton.FontFace =
		Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	textButton.Text = "<"
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.TextScaled = true
	textButton.TextSize = 14
	textButton.TextTransparency = 0.3
	textButton.TextWrapped = true
	textButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	textButton.BackgroundTransparency = 1
	textButton.Size = UDim2.fromScale(0.1, 1)
	textButton.Parent = topBar1

	textButton.MouseButton1Click:Connect(function()
		configurationframe.Visible = false
		modMenu.Visible = true
	end)

	topBar1.Parent = configurationframe

	local configList = Instance.new("Frame")
	configList.Name = "ConfigList"
	configList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	configList.BackgroundTransparency = 1
	configList.Position = UDim2.fromScale(0, 0.124)
	configList.Size = UDim2.fromScale(1, 0.876)

	local uIListLayout1 = Instance.new("UIListLayout")
	uIListLayout1.Name = "UIListLayout"
	uIListLayout1.Padding = UDim.new(0, 10)
	uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout1.Parent = configList

	configList.Parent = configurationframe

	local uICorner2 = Instance.new("UICorner")
	uICorner2.Name = "UICorner"
	uICorner2.CornerRadius = UDim.new(0, 15)
	uICorner2.Parent = configurationframe

	configurationframe.Parent = mainGui

	mainGui.Parent = passionFruit
	passionFruit.Parent = game.Players.LocalPlayer.PlayerGui

	--// Function: TabBar
	function TabTable:findTab(TabName:string)
		return CurrentUICreated[TabName]
	end
	
	function TabTable:findMod(TabName:string, ModName:string)
		return CurrentUICreated[TabName][ModName]
	end

	function TabTable:newtab(TabName: string)
		local ModMenu = {}
		local theTab = Instance.new("Frame")
		theTab.Name = "TheTab"
		theTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		theTab.BackgroundTransparency = 1
		theTab.Size = UDim2.fromScale(0.7, 0.15)

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "TextLabel"
		textLabel.FontFace = Font.new(
			"rbxasset://fonts/families/GothamSSm.json",
			Enum.FontWeight.Bold,
			Enum.FontStyle.Normal
		)
		textLabel.Text = TabName or "Passionfruit"
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextScaled = true
		textLabel.TextSize = 14
		textLabel.TextTransparency = 0.3
		textLabel.TextWrapped = true
		textLabel.TextYAlignment = Enum.TextYAlignment.Bottom
		textLabel.AnchorPoint = Vector2.new(0, 0.5)
		textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.BackgroundTransparency = 1
		textLabel.BorderSizePixel = 0
		textLabel.Position = UDim2.fromScale(0, 0.851)
		textLabel.Size = UDim2.fromScale(1, 0.234)
		textLabel.Parent = theTab

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "ImageLabel"
		imageLabel.Image = "rbxassetid://8276080763"
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Position = UDim2.fromScale(0.5, 0.435)
		imageLabel.Size = UDim2.fromScale(0.5, 0.5)
		imageLabel.Parent = theTab

		local frame = Instance.new("Frame")
		frame.Name = "Frame"
		frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		frame.BackgroundTransparency = 0.5
		frame.Size = UDim2.fromScale(1, 1)
		frame.Parent = theTab

		local textButton = Instance.new("TextButton")
		textButton.Name = "TextButton"
		textButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
		textButton.Text = ""
		textButton.TextColor3 = Color3.fromRGB(0, 0, 0)
		textButton.TextSize = 14
		textButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textButton.BackgroundTransparency = 1
		textButton.Size = UDim2.fromScale(1, 1)
		textButton.ZIndex = 2
		textButton.Parent = theTab
		theTab.Parent = tab

		--// Create mod category
		local modCategory = Instance.new("ScrollingFrame")
		modCategory.Name = "ModCategory"
		modCategory.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		modCategory.BackgroundTransparency = 1
		modCategory.Size = UDim2.fromScale(1, 1)
		modCategory.Visible = false
		local uIGridLayout = Instance.new("UIGridLayout")
		uIGridLayout.Name = "UIGridLayout"
		uIGridLayout.CellPadding = UDim2.fromOffset(15, 15)
		uIGridLayout.CellSize = UDim2.new(0.3, 0, 0, 200)
		uIGridLayout.FillDirectionMaxCells = 3
		uIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIGridLayout.Parent = modCategory
		modCategory.Parent = modList

		UILibrary.CurrentTabSelect = nil
		UILibrary.CurrentModSelect = nil

		--// Create Listener
		textButton.MouseButton1Click:Connect(function()
			if UILibrary.CurrentTabSelect then
				TweenService:Create(
					UILibrary.CurrentTabSelect.Frame,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ BackgroundTransparency = 0.5 }
				):Play()
			end

			if UILibrary.CurrentModSelect then
				UILibrary.CurrentModSelect.Visible = false
			end

			modCategory.Visible = true
			TweenService:Create(
				theTab.Frame,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 1 }
			):Play()

			CurrentTabPickingLabel.Text = TabName
			UILibrary.CurrentTabSelect = theTab
			UILibrary.CurrentModSelect = modCategory
		end)

		--// Functions: ModMenu
		function ModMenu:newmod(modproperty: table, callback, modconfiguration: table)

			local IClientYesTarget
			if not shared.IClientToggledProperty[modproperty.ModName] then
				shared.IClientToggledProperty[modproperty.ModName] = {Toggled = false}
				for i , v in pairs(modconfiguration) do
					if not shared.IClientToggledProperty[modproperty.ModName][v.DisplayText] then
						shared.IClientToggledProperty[modproperty.ModName][v.DisplayText] = v.Default or v.Value or nil
					end
				end
			end

			IClientYesTarget = shared.IClientToggledProperty[modproperty.ModName]
			for i , v in pairs(modconfiguration) do
				if v.ConfigType == "Slider" then
					v.Default = IClientYesTarget[v.DisplayText]
				else
					if v.Value then
						v.Value = IClientYesTarget[v.DisplayText]
					end
				end
			end

			local mod = Instance.new("Frame")
			mod.Name = "Mod"
			mod.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			mod.BackgroundTransparency = 0.3
			mod.ClipsDescendants = true
			mod.Size = UDim2.fromOffset(100, 100)
			mod.Visible = true
			local uICorner = Instance.new("UICorner")
			uICorner.Name = "UICorner"
			uICorner.Parent = mod

			local modName = Instance.new("TextLabel")
			modName.Name = "ModName"
			modName.FontFace =
				Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			modName.Text = modproperty.ModName or "Animations"
			modName.TextColor3 = Color3.fromRGB(255, 255, 255)
			modName.TextScaled = true
			modName.TextSize = 14
			modName.TextStrokeTransparency = 0
			modName.TextWrapped = true
			modName.TextXAlignment = Enum.TextXAlignment.Left
			modName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			modName.BackgroundTransparency = 1
			modName.Position = UDim2.fromScale(0.0796, 0.83)
			modName.Size = UDim2.fromScale(0.619, 0.115)
			modName.Parent = mod

			local modImage = Instance.new("ImageLabel")
			modImage.Name = "ModImage"
			modImage.Image = "rbxassetid://10494150467"
			modImage.AnchorPoint = Vector2.new(0.5, 0)
			modImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			modImage.BackgroundTransparency = 1
			modImage.Position = UDim2.fromScale(0.5, 0.085)
			modImage.Size = UDim2.fromOffset(128, 128)
			modImage.Parent = mod

			local frame = Instance.new("Frame")
			frame.Name = "Frame"
			frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			frame.BackgroundTransparency = 0.3
			frame.Position = UDim2.fromScale(0, 0.785)
			frame.Size = UDim2.new(1, 0, 0, 53)
			frame.ZIndex = 0
			frame.Parent = mod

			local isBinded = Instance.new("TextLabel")
			isBinded.Name = "IsBinded"
			isBinded.FontFace =
				Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			isBinded.Text = "BINDED"
			isBinded.TextColor3 = Color3.fromRGB(255, 255, 255)
			isBinded.TextScaled = true
			isBinded.Visible =  IClientYesTarget.Keybind and  not ( IClientYesTarget.Keybind == "None") or false
			isBinded.TextSize = 14
			isBinded.TextWrapped = true
			isBinded.AnchorPoint = Vector2.new(0.5, 0.5)
			isBinded.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			isBinded.BackgroundTransparency = 1
			isBinded.Position = UDim2.fromScale(0.5, 0.725)
			isBinded.Size = UDim2.fromScale(1, 0.07)
			isBinded.Parent = mod

			local detailButton = Instance.new("TextButton")
			detailButton.Name = "DetailButton"
			detailButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
			detailButton.Text = ""
			detailButton.TextColor3 = Color3.fromRGB(0, 0, 0)
			detailButton.TextSize = 14
			detailButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			detailButton.BackgroundTransparency = 1
			detailButton.Size = UDim2.fromScale(1, 1)
			detailButton.ZIndex = 2

			local toggle = Instance.new("TextButton")
			toggle.Name = "Toggle"
			toggle.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
			toggle.Text = ""
			toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
			toggle.TextSize = 14
			toggle.AutoButtonColor = false
			toggle.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
			toggle.BackgroundTransparency = 1
			toggle.BorderSizePixel = 0
			toggle.Position = UDim2.fromScale(0.738, 0.813)
			toggle.Size = UDim2.fromScale(0.213, 0.15)
			toggle.ZIndex = 3

			local toggleFrame = Instance.new("Frame")
			toggleFrame.Name = "ToggleFrame"
			toggleFrame.BackgroundColor3 = Color3.fromRGB(114, 118, 125)
			toggleFrame.Position = UDim2.fromScale(0, 0.133)
			toggleFrame.Size = UDim2.fromScale(0.87, 0.7)

			local toggleFrameCorner = Instance.new("UICorner")
			toggleFrameCorner.Name = "ToggleFrameCorner"
			toggleFrameCorner.CornerRadius = UDim.new(1, 8)
			toggleFrameCorner.Parent = toggleFrame

			local toggleFrameCircle = Instance.new("Frame")
			toggleFrameCircle.Name = "ToggleFrameCircle"
			toggleFrameCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			toggleFrameCircle.Position = UDim2.fromScale(0.11, 0.133)
			toggleFrameCircle.Size = UDim2.fromScale(0.375, 0.714)

			local toggleFrameCircleCorner = Instance.new("UICorner")
			toggleFrameCircleCorner.Name = "ToggleFrameCircleCorner"
			toggleFrameCircleCorner.CornerRadius = UDim.new(1, 0)
			toggleFrameCircleCorner.Parent = toggleFrameCircle

			local icon = Instance.new("ImageLabel")
			icon.Name = "Icon"
			icon.Image = "http://www.roblox.com/asset/?id=6035047409"
			icon.ImageColor3 = Color3.fromRGB(114, 118, 125)
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			icon.BackgroundTransparency = 1
			icon.BorderColor3 = Color3.fromRGB(27, 42, 53)
			icon.Position = UDim2.fromScale(0.533, 0.533)
			icon.Size = UDim2.fromScale(0.867, 0.867)
			icon.Parent = toggleFrameCircle

			toggleFrameCircle.Parent = toggleFrame

			toggleFrame.Parent = toggle

			detailButton.Parent = mod
			toggle.Parent = mod
			mod.Parent = modCategory

			local IsToggled = IClientYesTarget.Toggled
			local issettingkeybind = false
			local function ModToggleChanged(NewToggle)
				if NewToggle == true then
					TweenService:Create(
						icon,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ ImageColor3 = Color3.fromRGB(67, 181, 129) }
					):Play()
					TweenService:Create(
						toggleFrame,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(67, 181, 129) }
					):Play()
					toggleFrameCircle:TweenPosition(
						UDim2.new(0.655, -5, 0.133000001, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quart,
						0.3,
						true
					)
					TweenService:Create(
						icon,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ ImageTransparency = 1 }
					):Play()
					icon.Image = "http://www.roblox.com/asset/?id=6023426926"
					wait(0.1)
					TweenService:Create(
						icon,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ ImageTransparency = 0 }
					):Play()
				else
					TweenService:Create(
						icon,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ ImageColor3 = Color3.fromRGB(114, 118, 125) }
					):Play()
					TweenService:Create(
						toggleFrame,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(114, 118, 125) }
					):Play()
					toggleFrameCircle:TweenPosition(
						UDim2.new(0.234999999, -5, 0.133000001, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quart,
						0.3,
						true
					)
					TweenService:Create(
						icon,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ ImageTransparency = 1 }
					):Play()
					icon.Image = "http://www.roblox.com/asset/?id=6035047409"
					wait(0.1)
					TweenService:Create(
						icon,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ ImageTransparency = 0 }
					):Play()
				end
				if callback then
					callback(NewToggle)
				end
			end

			ModToggleChanged(IsToggled)
			toggle.MouseButton1Click:Connect(function()
				IsToggled = not IsToggled
				IClientYesTarget.Toggled = IsToggled
				ModToggleChanged(IsToggled)
			end)

			local ToggleToggle

			detailButton.MouseButton1Click:Connect(function()
				--// Delete Past Configuration
				for i, v in pairs(configList:GetChildren()) do
					if v:IsA("UIListLayout") then
					else
						v:Destroy()
					end
				end

				local TheTable = {
					DisplayText = "Toggled",
					ConfigType = "Toggle",
					Callback = function(Value)
						IsToggled = Value
						ModToggleChanged(Value)
					end,
					Value = IsToggled,
				}

				ToggleToggle = UIConfigFrame[TheTable.ConfigType](TheTable, configList,IClientYesTarget)

				modSelectName.Text = modproperty.ModName
				modDescription.Text = modproperty.ModDescription

				local bind = Instance.new("Frame")
				bind.Name = "Bind"
				bind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				bind.BackgroundTransparency = 1
				bind.LayoutOrder = 2
				bind.Size = UDim2.fromScale(1, 0.1)

				local background = Instance.new("TextButton")
				background.Name = "Background"
				background.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
				background.Text = ""
				background.TextColor3 = Color3.fromRGB(255, 255, 255)
				background.TextSize = 14
				background.AutoButtonColor = false
				background.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
				background.BorderSizePixel = 0
				background.Position = UDim2.fromScale(0.05, 0)
				background.Size = UDim2.fromScale(0.923, 1)

				local uICorner = Instance.new("UICorner")
				uICorner.Name = "UICorner"
				uICorner.Parent = background

				local title = Instance.new("TextLabel")
				title.Name = "Title"
				title.FontFace = Font.new(
					"rbxasset://fonts/families/GothamSSm.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				)
				title.Text = "Bind"
				title.TextColor3 = Color3.fromRGB(255, 255, 255)
				title.TextSize = 14
				title.TextXAlignment = Enum.TextXAlignment.Left
				title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				title.BackgroundTransparency = 1
				title.Position = UDim2.fromScale(0.0228, 0)
				title.Size = UDim2.fromScale(0.477, 1)
				title.Parent = background

				local keybindText = Instance.new("TextLabel")
				keybindText.Name = "KeybindText"
				keybindText.FontFace = Font.new(
					"rbxasset://fonts/families/GothamSSm.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				)
				keybindText.Text = IClientYesTarget.Keybind or modproperty.Keybind
				keybindText.TextColor3 = Color3.fromRGB(236, 244, 255)
				keybindText.TextSize = 14
				keybindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				keybindText.BackgroundTransparency = 1
				keybindText.Position = UDim2.fromScale(0.937, 0)
				keybindText.Size = UDim2.fromScale(0.0554, 0.984)
				keybindText.Parent = background

				background.Parent = bind
				bind.Parent = configList

				background.MouseButton1Click:Connect(function()
					keybindText.Text = "..."
					issettingkeybind = true

					local inputwait = game:GetService("UserInputService").InputBegan:Wait()
					local inputwait = game:GetService("UserInputService").InputEnded:Wait()

					if inputwait.KeyCode.Name ~= "Unknown" then
						isBinded.Visible = true
						modproperty.Keybind = inputwait.KeyCode.Name
					else
						isBinded.Visible = false
						modproperty.Keybind = "None"
					end
					IClientYesTarget.Keybind = modproperty.Keybind
					keybindText.Text = modproperty.Keybind
					issettingkeybind = false
				end)

				for i, v in pairs(modconfiguration) do
					local Createnewconfigtype = UIConfigFrame[v.ConfigType](v, configList,IClientYesTarget)
				end

				modMenu.Visible = false
				configurationframe.Visible = true
			end)

			game:GetService("UserInputService").InputBegan:Connect(function(current, pressed)
				if not pressed and not issettingkeybind then
					if current.KeyCode.Name == modproperty.Keybind or current.KeyCode.Name == IClientYesTarget.Keybind then
						IsToggled = not IsToggled
						IClientYesTarget.Toggled = IsToggled
						ModToggleChanged(IsToggled)
						ToggleToggle:ForceToggle()
					end
				end
			end
			)

			modCategory.CanvasSize = UDim2.new(0,0,0,uIGridLayout.AbsoluteContentSize.Y)
			CurrentUICreated[TabName][modproperty.ModName] = {Frame = mod, callback = callback}
		end

		function ModMenu:RemoveTab()
			if UILibrary.CurrentTabSelect == theTab then
				UILibrary.CurrentTabSelect = nil
			end
			if UILibrary.CurrentModSelect == modCategory then
				UILibrary.CurrentModSelect = nil
			end
			theTab:Destroy()
			modCategory:Destroy()
			CurrentUICreated[TabName] = nil
		end

		function ModMenu:RemoveMod(ModName)
			CurrentUICreated[TabName][ModName].Frame:Destroy()
			CurrentUICreated[TabName][ModName].callback(false)
			CurrentUICreated[TabName][ModName].callback = nil
		end

		CurrentUICreated[TabName] = ModMenu
		return ModMenu
	end


	return TabTable
end



return UILibrary
