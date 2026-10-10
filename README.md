# GHP UI Library

**Credits: GHP (ypkayla).**
**(LICENSED UNDER [LICENSE.md](LICENSE.md))**

This guide describes the standalone Roblox Luau UI library. It initializes
its own services, signals, cleanup manager, and UI helpers; it does not require
another script or framework. It is not a standard-Lua package or a regular
in-experience `ModuleScript`.

The published source is available at
<https://raw.githubusercontent.com/ypkayla/Kicia_UI_remake/refs/heads/main/UI_Library.lua>.

## Loading and lifetime

In a compatible Roblox client environment, load and initialize the published
source:

```lua
local sourceUrl = "https://raw.githubusercontent.com/ypkayla/Kicia_UI_remake/refs/heads/main/UI_Library.lua"
local source = game:HttpGet(sourceUrl)
local compile = assert(loadstring, "This environment must provide loadstring")
local uiFactory = assert(compile(source), "Failed to compile the UI library")
local ui = uiFactory()

local menu = ui.CreateMenu({
    Title = "My menu",
    Icon = ui.DefaultLogo,
    Directory = "GHP_scripts/my-menu",
})
```

Calling the compiled chunk returns the library factory; calling that factory
without arguments initializes its standalone API with built-in defaults.

`CreateMenu(options)` and `Menu.new(options)` create the same menu object.
Important menu options:

| Option | Meaning |
| --- | --- |
| `Title` | Initial window and watermark title. |
| `Icon` | Main window's top-left logo; also used by the watermark unless `WatermarkIcon` is set. Defaults to `ui.DefaultLogo`; accepts a `lucide:<name>` icon or a custom image asset URI. |
| `IconSize` | Optional `Vector2` pixel size for the main window logo. Defaults to the responsive layout size. |
| `WatermarkIcon` | Optional independent watermark logo; defaults to `Icon`. Accepts a Lucide icon or custom image asset URI. |
| `WatermarkIconSize` | Optional `Vector2` pixel size for the watermark logo; defaults to `20x20`. |
| `Directory` | Required path used for menu state and config-related files. |
| `Config` | Optional reactive config adapter. Control `Config` paths only bind when this is supplied. |
| `State`, `StateData` | Optional state manager and loaded state data. |
| `ConfigVersion` | Version metadata used by config handling. |
| `ResolveFont` | Optional function converting a saved font name to a `FontFace`. |
| `OnUnload` | Optional callback invoked by the menu unload path. |
| `ThemePath`, `NotificationPath`, `AutoExecuteEnabledPath` | Override paths used by the built-in settings page when a config adapter is supplied. |

The menu starts hidden. Add its tabs and controls, then call `menu:SetVisible(true)`.
The default visibility hotkey is Right Shift. Menu state is cleaned up with
`menu:Destroy()` or `menu:Unload()`. The returned UI table also includes
`Menu` (the menu class), `CreateMenu`, `GetNotifications`, and `Modules`.
`Modules` exposes the internal module registry; it is not a stable extension
API.

## Basic structure

A menu contains top-level tabs. A tab can contain either a grid or nested pages,
not both. A grid contains sections; a section contains controls.

```lua
local tab = menu:AddTab({
    Label = "General",
    Description = "General options",
    Icon = "lucide:house",
})

local grid = tab:Grid({ Columns = 2 })
local section = grid:AddSection({
    Title = "Options",
    Side = "left", -- "left", "right", or "full"
})
```

Grid columns are responsive and collapse as needed for narrow/mobile layouts.
`AddMultiSection({ Titles = { "First", "Second" }, Side = "right" })` creates
switchable panes and returns one section object per title.

For nested pages, use `tab:AddTab({ Label = "Subpage", Description = "..." })`.
The returned page supports `:Grid({ Columns = 1 })`, `:Header(options)`, and
`:OnFirstOpen(callback)`. `Header` adds a section-style page header and returns
its section, so it can contain controls. Do not call `Grid` on the parent tab
after adding nested pages.

## Controls

Unless stated otherwise, controls accept `Label` and `Tooltip`. Most accept a
`Config` path, such as `{"Visuals", "Enabled"}`, for binding to the menu's
optional reactive config adapter. `Default` initializes an unbound control.
Change callbacks are `OnChanged(value)` and buttons use `OnClick()`.

| Method | Useful options and behavior |
| --- | --- |
| `AddToggle(options)` | `Default` boolean, `OnChanged(boolean)`. Returned object has `Value`, `ValueChanged`, `:Set(boolean)`, `:OnChanged(callback)`, and `:SetVisible(boolean)`. |
| `AddSlider(options)` | `Min`, `Max`, `Step`, `Default`, `Suffix`, `OnChanged(number)`. Returned object has `:Set(number)` and `:OnChanged(callback)`. |
| `AddRangeSlider(options)` | `Min`, `Max`, `Step`, `Default = { Min = number, Max = number }`, `OnChanged(range)`. The range object uses `Min` and `Max`. |
| `AddButton(options)` | `OnClick`, optional `Confirm`, and optional `Row` to attach to an existing row. |
| `AddLabel(options)` | Adds a text label; `TextColor` and `TextSize` customize it. |
| `AddDivider(options)` | Adds a visual divider; an optional `Label` can title it. |
| `AddTextBox(options)` | `Placeholder`, `Default`, `MaxLength` (maximum sizing width), `InputWidth` (optional fixed pixel width, capped by `MaxLength`), `FocusLostOnly`, `OnChanged(text)`, `Config`. |
| `AddDropdown(options)` | Single selection. `Options`, `Default`, optional `Labels`, `GetOptions`, `Search`, `Inline`, `CloseOnSelect`, `MaxWidth`, `OnChanged(value)`. `:SetOptions(options)` updates choices. |
| `AddMultiDropdown(options)` | Multiple selection; `Default` is a list of selected option strings. Shares the dropdown options and `:SetOptions`. |
| `AddList(options)` | List-style single selection. `Options`, `Default`, `Height`, `Search`, `SelectFirst`, `OnChanged(value)`. |
| `AddMultiList(options)` | List-style multiple selection. `Options`, `Default`, `Height`, `Search`, `OnChanged(values)`. |
| `AddKeybind(options)` | Key capture and mode control. `Modes` supplies available modes; `ConfigMap` maps key/mode/active/list fields to config paths. `InKeybindList`, `ListLabel`, `ShowInList`, and `Invisible` control HUD listing; `OnChanged(value)` receives key/mode changes. |
| `AddColor(options)` | Color picker. `Default = { Rgb = Color3, Alpha = number, Stops = stops }`; `Alpha = true` enables alpha, `Gradient = "editable"` enables Solid/Gradient selection, and `Gradient = "only"` forces gradient mode. Omit/disable gradients with `"off"`. `Animatable = true` enables color animations; `OnChanged(value)` receives `{ Rgb, Alpha, Stops }`. |
| `AddSkinChanger(options)` | Skin/item browser. Each `Items` entry needs a `Name`; optional fields include `Title`, `Image`, `ImageSize`, `PreviewColor`, `SelectedPreviewColor`, `TitleColor`, `AccentColor`, `LayoutOrder`, `Selected`, and `Render(item, context)`. Also supports `Height`, `HeightMode`, `State`, `StateMessage`, `OnChanged`, `:SetItems`, `:SetState`, `:SetFilter`, and `:SetClearFilterAction`. |
| `AddIconStrip(options)` | Choice strip with `Options = { { Name = "...", Icon = "lucide:house" }, ... }`, `Default`, `Height`, and `OnChanged`. |
| `AddViewport(options)` | 3D preview with `Height`, `FieldOfView`, `AutoRotate`, `RotateSpeed`, and `DistanceMul`. `:SetModel(model)` clones a `Model` or `BasePart`; also supports `:SetDistance` and `:SetRotation`. |
| `AddOrderedList(options)` | Reorderable string list with `Items`, optional `Default` order, and `OnChanged(order)`. |
| `AddGear(options)` | Adds a gear/details popup associated with an existing row. Pass the row object as `Row`; add controls directly to the returned container (for example, `gear:AddToggle(...)`). |
| `AddGroup(options)` | Adds a conditional group. `Source` must be a control-like object with `Value` and `ValueChanged`; optional `Option` selects a value/table entry and `Visible` sets initial visibility. Add controls to the returned group. |
| `AddMultiSection(options)` | Adds selectable section panes. Requires `Titles`; returns one section for each title. |

Returned controls generally expose `Value` (or control-specific state),
`ValueChanged`, `:Set(...)`, `:SetLabel(...)`, `:SetTooltip(...)`,
`:SetVisible(boolean)`, and `:OnChanged(callback)` where applicable. Use the
specific control method listed above; not every method applies to every control.
`Destroy()` on a control releases its connections and UI.

### Dynamic choices and dependent groups

Dropdowns and lists can update their choices at runtime with `:SetOptions(...)`
or, for lists, `:SetItems(...)`. `GetOptions` can supply dropdown choices
dynamically. Groups listen to their source control, so their contents become
available when the source's value matches the group's condition.

## Menu features

| Method | Behavior |
| --- | --- |
| `AddSettingsTab()` | Adds built-in menu, theme, notification, config-profile, background-image/blur, and startup settings. Includes a Show Watermark toggle. Returns the settings page and its helper results. |
| `Dialog(options, buildCallback)` | Opens a modal dialog; options include page title/description and action/confirmation settings. The optional callback receives the dialog object for constructing pages/actions. |
| `SetTitle(string)`, `SetFont(FontFace)` | Update the window title or menu font. |
| `SetVisible(boolean, immediate?)` | Show or hide the menu; the optional second argument skips the visibility transition. |
| `SetAccent(Color3)` | Changes the UI accent color. |
| `SetWatermarkEnabled(boolean)`, `IsWatermarkEnabled()` | Control the watermark. `SetWatermarkUsername(string)` changes its username text. |
| `SetKeybindListEnabled(boolean)`, `IsKeybindListEnabled()` | Control the keybind HUD (not created on every device/layout). `AddKeybindHudEntry()` creates a manual entry when available. |
| `RegisterMobileButton(id, label, mode, callback)` | Registers a mobile HUD button when the current layout supports mobile buttons; returns `nil` on unsupported layouts. |
| `SetMenuPillHidden(boolean)`, `EnterMobileButtonDragMode(callback)` | Control the mobile menu pill and on-screen button layout editor. |
| `SearchQuery(string)`, `ShowSearchResults(...)`, `HideSearchResults()` | Search registered UI controls; normal users can also use the menu's built-in search UI. |
| `GetConfig()`, `GetStateData()`, `SaveState()` | Access optional configuration/state and persist menu state. |
| `GetColorAnimation()`, `GetPersistence()`, `GetOverlayLayer()` | Access optional integrations and UI layers. |
| `CaptureKey(input)`, `ShouldBlockKeybindCapture(input)` | Menu-level key-capture helpers. |
| `OnPreRender(callback)` | Register per-render work; returns a cleanup handle. |
| `Destroy()`, `Unload()` | Release menu UI and owned resources; `Unload()` invokes the optional `OnUnload` callback. |

Top-level tabs and nested pages support `:OnFirstOpen(callback)` to defer work
until first opened. Sections support `:SetTitle(...)` and `:SetVisible(boolean)`.
A grid supports `:AddSection(...)` and `:AddMultiSection(...)`. Gear popups
are containers: add controls directly to the object returned by `AddGear`.
Nested pages have their own `AddTab`, `Header`, and `Grid` methods.
Nested-page navigation options include `Title`, `Description`, `Glyph`,
`ActionText`, `ActionEnabled`, `Variant`, `Confirmation`, and `OnOpen`.

There are no separate `AddParagraph`, `AddSubLabel`, or `AddSpacer` methods in
this API. Use a nested page's `:Header(options)` or a section's `Title`,
`AddLabel`, and `AddDivider` for those presentation needs.

## Notifications

`ui.GetNotifications()` returns the library notification manager.

```lua
ui.GetNotifications():Notify("Settings saved", {
    Lifetime = 4,
    Intent = "success", -- "success", "warning", or "error"
})
```

The full call is `Notify(text, options?)`. `Lifetime` defaults to six seconds.
`Color` overrides the accent color; `Intent` selects a semantic success,
warning, or error color. Global notification settings include enabled state,
placement (`TopLeft`, `TopRight`, `BottomLeft`, `BottomRight`, `Center`, or
`Crosshair`), text size, font, and crosshair offset. `:Clear()` dismisses active
notifications.

## Icons and logo

Icon options use the bundled Lucide icon atlas rather than Roblox image asset
IDs. Set `Icon` to a `lucide:<name>` value, for example `"lucide:house"` or
`"lucide:settings"`. Icon images are tinted by the current UI theme. The
bundled atlas currently supports:

`activity`, `arrow-down`, `arrow-left`, `arrow-right`, `arrow-up`,
`badge-check`, `badge-info`, `bell`, `bookmark`, `bot`, `bug`, `chart-no-axes-column-increasing`,
`check`, `chevron-down`, `chevron-left`, `chevron-right`, `chevron-up`,
`circle-check`, `circle-dot`, `circle-x`, `clock`, `component`, `copy`,
`crosshair`, `download`, `external-link`, `eye`, `eye-off`, `flame`, `folder`,
`gamepad-2`, `gauge`, `heart`, `house`, `info`, `keyboard`, `layout-grid`,
`list`, `list-check`, `lock-keyhole`, `map`, `maximize`, `minimize`, `monitor`,
`mouse-pointer-2`, `move`, `navigation`, `network`, `package`, `paintbrush`,
`palette`, `pause`, `play`, `refresh-cw`, `rotate-cw`, `save`, `scan-eye`,
`search`, `settings`, `shield`, `shield-alert`, `shirt`, `sliders-horizontal`,
`smartphone`, `sparkles`, `star`, `swords`, `target`, `trophy`, `upload`,
`user-cog`, `user-round`, `volume-2`, `wand-sparkles`, `wrench`, `x`, and `zap`.
The `Icon` option controls the main window's top-left logo and is reused by the
watermark by default. Set `WatermarkIcon` for a different watermark image.
Increase `IconSize` or `WatermarkIconSize` with a `Vector2` to make a compact
logo more visible; for example, `IconSize = Vector2.new(56, 48)`. Both logos
preserve their aspect ratio. The watermark can be shown or hidden from the
built-in Settings tab or with `menu:SetWatermarkEnabled(boolean)`.
The embedded sprite atlas is generated from [Lucide](https://lucide.dev) SVGs
and carries their ISC license notice in `UI_Library.lua`. It is cached on first
icon use in `GHP_scripts/ui-library-cache`.

`ui.DefaultLogo` is the embedded 1024x1024 GHP PNG. It is cached as
`GHP_scripts/ui-library-cache/ghp-logo-v1.png` and keeps its original colors.
To replace it, replace the Base64 payload in `GHP_LOGO_BASE64` in
`UI_Library.lua`, omitting the `data:image/png;base64,` prefix. Bundled image
caching requires `isfile`, `writefile`, and `getcustomasset` or `getsynasset`;
`makefolder` is also needed if the cache directory does not exist. To override
the logo for one menu, write a PNG to a file, resolve it with one of the
custom-asset functions, and pass the returned URI as `Icon`.

## Example

See [UI_Library_Example.lua](./UI_Library_Example.lua) for a single script that
creates a demonstration menu and exercises the controls and features above.
Run it in a compatible Roblox client environment.
Destroy the demo menu with its
"Destroy demo menu" button or by calling `menu:Destroy()`.

## References

- Published GHP UI library source:
  <https://raw.githubusercontent.com/ypkayla/Kicia_UI_remake/refs/heads/main/UI_Library.lua>
- MacLib feature documentation (used as a feature-category checklist):
  <https://brady-xyz.gitbook.io/maclib-ui-library>

This library does not implement MacLib's `Window:Notify({...})` or
`Section:Input({...})` syntax. Use the method names and call shapes in this
guide instead.

### Runtime requirements

Run this library in a Roblox client environment that permits UI creation under
`CoreGui` or exposes `gethui`. Standalone menu setup requires the file APIs
`isfile`, `isfolder`, and `makefolder` for its state directory. Config
profile save/load/delete/list features additionally require `writefile`,
`readfile`, `delfile`, and `listfiles`. The GitHub-loading example also
requires `loadstring` and `game:HttpGet`. Custom fonts, downloaded/local
images, and clipboard support require their respective runtime APIs; they are
not needed when using built-in fonts and Lucide icons without clipboard
features. `gethui` is optional; the library falls back to `CoreGui`.
