# AscensionProgressDataBars — ConfigPanel Overview

## Architecture

The config menu is a **custom tabbed interface** built entirely from scratch (no AceGUI). It consists of:

- **`Config.lua`** — Entry point. Creates the main `configFrame`, wires up 7 tabs, and exposes `refreshConfigUI()`.
- **`ConfigPanel/UIFactory.lua`** — Core widget library (`layoutFactory`) + fluent layout DSL (`layoutModel`).
- **`ConfigPanel/ConfigUtils.lua`** — Shared utilities: `cleanupContent`, `cleanOrders`, `getCount`, `setTooltip`.
- **`ConfigPanel/BlizzardIntegration.lua`** — Registers the addon in the Blizzard Interface Options panel with a redirect button.

## Tab Files

| Tab Index | Locale Key | File | Module |
|---|---|---|---|
| 1 | `TAB_BARS_LAYOUT` | `BarsLayout.lua` | `addonTable.barsLayoutTab` |
| 2 | `TAB_CUSTOM_GRID` | `CustomGrid.lua` | `addonTable.customGridTab` |
| 3 | `TAB_TEXT_LAYOUT` | `TextLayout.lua` | `addonTable.textLayoutTab` |
| 4 | `TAB_BEHAVIOR` | `Behavior.lua` | `addonTable.behaviorTab` |
| 5 | `TAB_COLORS` | `Colors.lua` | `addonTable.colorsTab` |
| 6 | `TAB_PARAGON_ALERTS` | `ParagonAlerts.lua` | `addonTable.paragonAlertsTab` |
| 7 | `TAB_PROFILES` | `Profiles.lua` | `addonTable.profilesTab` |

Each tab exposes a single `:build(panel)` method that is called lazily when the tab is first selected and on every layout refresh.

---

## UIFactory — Widget Library

Defined in `UIFactory.lua`. All widgets return `(widget, nextY)`.

| Method | Description |
|---|---|
| `createHeader` | Section title (gold, large font) |
| `createLabel` | Small text label |
| `createCheckbox` | `UICheckButtonTemplate` with styled text |
| `createSlider` | `OptionsSliderTemplate` + edit box + `–`/`+` buttons |
| `createStepper` | Label + edit box + `–`/`+` buttons (no slider rail) |
| `createColorPicker` | Color swatch + `ColorPickerFrame` integration |
| `createDropdown` | Custom dropdown with backdrop + scrollable list |
| `createScrollPanel` | `UIPanelScrollFrameTemplate` with mouse-wheel support |
| `createInput` | Labeled `EditBox` with `OnEnterPressed` |
| `createButton` | `BackdropTemplate` button with hover/click effects |
| `createTabbedInterface` | Sidebar tab buttons + per-tab scroll panels |

### layoutModel (Fluent DSL)

`addonTable.layoutModel:new(parent, startY)` creates a cursor-based layout helper. Methods mirror each factory widget (`:header`, `:label`, `:checkbox`, `:slider`, `:stepper`, `:colorPicker`, `:dropdown`, `:input`, `:button`).

Card-style sections use `:beginSection(xOffset, width)` / `:endSection()` which auto-size a `BackdropTemplate` box around their contents.

---

## Tab-by-Tab Summary

### Tab 1 — Bars Layout (`BarsLayout.lua`)
- **Global Settings**: `GlobalBarHeight` slider, `usePerBlockOffsets` & `usePerBlockGaps` toggles, then per-block or global offset/gap sliders.
- **Bar Management**: 2-column layout (TOP block / BOTTOM block). For each bar: Enable/Delete, Anchor dropdown, Order dropdown, optional custom height slider, optional per-bar text X/Y offset sliders.
- **Free Mode section**: At bottom, same per-bar controls for bars assigned to `block = "FREE"`.

### Tab 2 — Custom Grid (`CustomGrid.lua`)
- Master toggle: `customGridMasterEnabled`.
- Per block (TOP & BOTTOM): Enable grid, preset picker (2x1 / 2x2 / 3x2 / Custom), row stepper, per-row column stepper, visual cell grid with right-click context menu for bar assignment.
- Bar visibility toggles per block (3-column toggle layout).
- **Reputation Management** section: Faction search input + dropdown + Add button to create `Rep_<factionID>` dynamic bars.

### Tab 3 — Text Layout (`TextLayout.lua`)
- **Base Typography**: Font size slider, font outline dropdown, global Y offset slider, global text color picker.
- **Block Text Mode**: `blockTextMode` dropdown (Focus / Grid / None), context-sensitive Dim Alpha or Dynamic Grid Gap slider.
- **Events & Visibility**: Carousel enable toggle, Legend enable toggle.
- **Carousel Options** (conditional): X/Y offset sliders, background alpha slider.
- **Legend Options** (conditional): Text size slider, font outline dropdown, background alpha slider.

### Tab 4 — Behavior (`Behavior.lua`)
- **Auto Hide Logic**: `showOnMouseover`, `hideInCombat`, `hideAtMaxLevel` checkboxes.
- **Data Display**: `showRestedBar`, `showPercentage`, `showAbsoluteValues`, `useCompactFormat`, `sparkEnabled` checkboxes.

### Tab 5 — Colors (`Colors.lua`)
- 2-column card layout.
- **Column 1**: XP card (class color toggle + custom picker + rested bar toggle + rested color picker), House Favor card, Honor card, Azerite card.
- **Column 2**: Reputation card (reaction colors toggle OR 11 standing color pickers for Hated → Maxed/Renown).

### Tab 6 — Paragon Alerts (`ParagonAlerts.lua`)
- 2-column card layout.
- **Column 1 (Paragon)**: Split lines toggle, text size slider, X/Y position sliders, alert color picker.
- **Column 2 (House Rewards)**: Text size slider, X/Y position sliders, alert color picker.

### Tab 7 — Profiles (`Profiles.lua`)
- New profile input box.
- Switch profile dropdown.
- Copy from profile dropdown.
- Delete profile dropdown (with confirm dialog).
- Export / Import buttons (AceSerializer + LibDeflate popup with multiline EditBox).

---

## Known Patterns & Gotchas

- **Cleanup**: `configUtils:cleanupContent()` hides (not destroys) children/regions on rebuild. Frames accumulate over repeated builds.
- **Lazy scroll size**: Each tab's `build()` must call `content:SetHeight(math.abs(layout.y) + N)` at the end.
- **Parallel columns**: Use two separate `layoutModel` instances with the same `startY`, then `math.min(col1.y, col2.y)` to sync the cursor before the next section.
- **Timer-deferred redraws**: `C_Timer.After(0.01, panel:updateLayout)` is used after changes that affect the layout itself (e.g., enabling/disabling conditional sections).
- **No Trading Post / Endeavours tabs yet**: These bars exist in the `Bars/` folder but have no dedicated config sections in the ConfigPanel.
