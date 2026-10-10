-- Run after Ghp_rivals.lua has loaded and published GhpWtf.UI.
local environment = (getgenv and getgenv()) or _G
local host = assert(environment.GhpWtf, "Load Ghp_rivals.lua before this example")
local ui = assert(host.UI, "The GHP UI library has not been initialized")

local previous = environment.GhpUiLibraryExample
if previous ~= nil then
	previous:Destroy()
end

local menu = ui.CreateMenu({
	Title = "GHP UI Library Example",
	Icon = "rbxassetid://118838006164746",
	Directory = "kiciarebuild/rivals/ui-library-example",
})
environment.GhpUiLibraryExample = menu

local mainTab = menu:AddTab({
	Label = "Controls",
	Description = "Demonstration of the available control types.",
	Icon = "rbxassetid://106205298246017",
})
local grid = mainTab:Grid({ Columns = 2 })
local left = grid:AddSection({ Title = "Basic controls", Side = "left" })
local right = grid:AddSection({ Title = "Selection and display", Side = "right" })

local enabledToggle = left:AddToggle({
	Label = "Example toggle",
	Tooltip = "Toggle changes are reported in the output.",
	Default = false,
	OnChanged = function(value)
		print("Example toggle:", value)
	end,
})

left:AddSlider({
	Label = "Example slider",
	Min = 0,
	Max = 100,
	Step = 5,
	Default = 35,
	Suffix = "%",
	OnChanged = function(value)
		print("Example slider:", value)
	end,
})

left:AddRangeSlider({
	Label = "Example range",
	Min = 0,
	Max = 100,
	Step = 1,
	Default = { Min = 20, Max = 75 },
	OnChanged = function(value)
		print("Example range:", value.Min, value.Max)
	end,
})

left:AddTextBox({
	Label = "Example text box",
	Placeholder = "Type here",
	Default = "",
	MaxLength = 80,
	FocusLostOnly = true,
	OnChanged = function(value)
		print("Example text:", value)
	end,
})

left:AddButton({
	Label = "Open example dialog",
	OnClick = function()
		menu:Dialog({
			Title = "Example dialog",
			Description = "Dialogs can host pages and actions.",
		})
	end,
})

left:AddButton({
	Label = "Show notification",
	OnClick = function()
		ui.GetNotifications():Notify("This is a GHP UI Library notification.", {
			Lifetime = 4,
			Intent = "success",
		})
	end,
})

left:AddLabel({
	Label = "Example label",
	TextColor = Color3.fromRGB(190, 200, 220),
	TextSize = 14,
})
left:AddDivider({ Label = "Divider example" })

right:AddDropdown({
	Label = "Single selection",
	Options = { "Alpha", "Bravo", "Charlie" },
	Default = "Bravo",
	Search = true,
	OnChanged = function(value)
		print("Selected:", value)
	end,
})

right:AddMultiDropdown({
	Label = "Multiple selection",
	Options = { "Red", "Green", "Blue" },
	Default = { "Red", "Blue" },
	OnChanged = function(values)
		print("Selected colors:", values)
	end,
})

right:AddList({
	Label = "Single-select list",
	Options = { "One", "Two", "Three" },
	Height = 100,
	Search = true,
	SelectFirst = true,
	OnChanged = function(value)
		print("List selection:", value)
	end,
})

right:AddMultiList({
	Label = "Multi-select list",
	Options = { "North", "South", "East", "West" },
	Height = 110,
	OnChanged = function(values)
		print("List selections:", values)
	end,
})

left:AddColor({
	Label = "Color picker",
	Default = { Rgb = Color3.fromRGB(70, 160, 255), Alpha = 1 },
	Alpha = true,
	Gradient = "on",
	Animatable = true,
	OnChanged = function(value)
		print("Color changed:", value.Rgb, value.Alpha)
	end,
})

left:AddKeybind({
	Label = "Example keybind",
})

right:AddIconStrip({
	Label = "Icon choices",
	Options = {
		{ Name = "One", Icon = "rbxassetid://106205298246017" },
		{ Name = "Two", Icon = "rbxassetid://118838006164746" },
	},
	Default = "One",
	OnChanged = function(value)
		print("Icon choice:", value)
	end,
})

right:AddOrderedList({
	Label = "Reorder these items",
	Items = { "First", "Second", "Third" },
	Default = { "Second", "First", "Third" },
	OnChanged = function(order)
		print("New order:", order)
	end,
})

local model = Instance.new("Model")
local part = Instance.new("Part")
part.Name = "PreviewPart"
part.Anchored = true
part.CanCollide = false
part.Size = Vector3.new(2, 2, 2)
part.Color = Color3.fromRGB(70, 160, 255)
part.Parent = model
model.PrimaryPart = part

local viewport = right:AddViewport({
	Label = "3D model preview",
	Height = 170,
	AutoRotate = true,
})
viewport:SetModel(model)
model:Destroy()

right:AddSkinChanger({
	Label = "Skin browser example",
	Items = {},
	Height = 160,
	HeightMode = "Fixed",
	State = "Ready",
})

local conditionalGroup = left:AddGroup({
	Title = "Shown while the toggle is on",
	Source = enabledToggle,
})
conditionalGroup:AddToggle({
	Label = "Grouped toggle",
	Default = true,
})

local paneA, paneB = grid:AddMultiSection({
	Titles = { "Pane A", "Pane B" },
	Side = "full",
})
paneA:AddLabel({ Label = "First multi-section pane" })
paneB:AddLabel({ Label = "Second multi-section pane" })

local pageTab = menu:AddTab({
	Label = "Nested pages",
	Description = "Tabs can also contain sub-pages instead of a grid.",
})
local subpage = pageTab:AddTab({
	Label = "Subpage",
	Description = "A page nested below the top-level tab.",
})
subpage:Header({ Title = "Nested page header" }):AddLabel({
	Label = "Header sections can hold controls.",
})
subpage:Grid({ Columns = 1 }):AddSection({
	Title = "Nested-page section",
	Side = "full",
}):AddLabel({
	Label = "Content in a nested tab page",
})

local gear = left:AddGear({
	Row = enabledToggle.Row,
	Tooltip = "Open the gear details page",
})
gear:AddPage({
	Title = "Advanced details",
	Description = "Gear overlays can contain their own pages.",
}, function(container)
	container:AddLabel({ Label = "Content inside the gear page" })
end)

local settingsTab = menu:AddSettingsTab()
assert(settingsTab ~= nil)

menu:RegisterMobileButton("ui-example-action", "Example action", "Toggle", function(active)
	print("Mobile action active:", active)
end)

menu:SetTitle("GHP UI Library Example")
menu:SetAccent(Color3.fromRGB(70, 160, 255))
menu:SetWatermarkUsername("UI Example")
menu:SetWatermarkEnabled(true)
menu:SetKeybindListEnabled(true)
menu:SetVisible(true)

left:AddButton({
	Label = "Destroy demo menu",
	Confirm = true,
	OnClick = function()
		menu:Destroy()
		if environment.GhpUiLibraryExample == menu then
			environment.GhpUiLibraryExample = nil
		end
	end,
})
