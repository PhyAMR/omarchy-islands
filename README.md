# Islands

A bar widget for the [Omarchy](https://omarchy.org) shell that groups the other
bar widgets into floating rounded "islands" and redraws their Nerd Font glyphs
as thin line icons.

- **Markers, not containers.** Add an *Island* widget before each group of
  widgets in a bar section: everything up to the next Island shares one pill.
  An Island with nothing after it closes the section (it only reserves the edge
  padding).
- **Transparent bar.** The pills are drawn behind the section, so the bar itself
  can be fully transparent and the wallpaper shows between islands. Set this in
  your theme's `shell.toml`:

  ```toml
  [bar]
  background-alpha = 0
  ```

- **Line icons.** Each island swaps the glyphs of the widgets it holds (audio,
  network, bluetooth, battery, weather, …) for thin line icons from `Icons.js`,
  tinted per category. Turn it off with the *Line icons* setting.

## Install

```bash
omarchy plugin add https://github.com/PhyAMR/omarchy-islands --enable
```

Then open the bar's widget settings and place an *Island* before each group.

## Settings

| Setting | Default | Range |
|---|---|---|
| Inner padding | 6 | 0–24 |
| Gap between islands | 8 | 0–40 |
| Line icons | on | |

## Theme colours (optional)

A theme can ship an `islands.json` next to its other files (Omarchy exposes it as
`~/.local/state/omarchy/current/theme/islands.json`). Every key is optional;
without the file the islands use the theme's background and foreground.

```json
{
  "island": "#14181a",
  "island-border": "#2a3034",
  "radius": 6,
  "stroke": 1.5,
  "audio": "#a3b5c4",
  "network": "#9fbfa8",
  "bluetooth": "#8fa6d8",
  "battery": "#b8c49a",
  "battery-low": "#de6145",
  "display": "#c9c2b4",
  "update": "#d6a26c",
  "agents": "#c2a6d4",
  "indicator": "#a5aeb4",
  "alert": "#de6145",
  "muted": "#5d6367",
  "chat": "#9fc4a3",
  "sun": "#e0b46c",
  "moon": "#b9b2d6",
  "cloud": "#a5aeb4",
  "rain": "#8fb3c9",
  "snow": "#d9dbdc",
  "storm": "#d6a26c"
}
```

## Using the icons from another plugin

Other plugins can reuse the line icons:

```qml
import "../phuniverse.islands" as Islands

Islands.LineIcon { name: "timer" }
```

## Develop

```bash
git clone git@github.com:PhyAMR/omarchy-islands.git ~/code/omarchy-islands
ln -sfn ~/code/omarchy-islands ~/.config/omarchy/plugins/phuniverse.islands
omarchy-shell shell rescanPlugins   # after each edit
```

## License

MIT, see [LICENSE](LICENSE).
