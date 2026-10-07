import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Icons.js" as Icons

// An island marker. Place one before each group of widgets in a bar section;
// the widgets up to the next marker share one rounded pill. A marker with no
// widgets after it closes the section (it only reserves the edge padding).
//
// The pill is drawn behind the section's Row, so the bar itself can be fully
// transparent (theme shell.toml: [bar] background-alpha = 0) and the
// wallpaper shows between islands.
//
// Each island also redraws the Nerd Font glyphs of the widgets it holds as
// thin line icons (Icons.js), tinted per category from the theme's
// islands.json.
BarWidget {
  id: root

  readonly property real pad: Style.space(Number(setting("padding", 6)))
  readonly property real gap: Style.space(Number(setting("gap", 8)))
  readonly property real edge: Style.space(Number(setting("edge", 2)))
  readonly property real inset: Style.space(Number(setting("inset", 3)))
  readonly property bool lineIcons: setting("lineIcons", true) !== false

  // Theme tones: ~/.local/state/omarchy/current/theme/islands.json
  property var tones: ({})
  readonly property color islandColor: tones.island ? tones.island : Color.background
  readonly property color islandBorder: tones["island-border"] ? tones["island-border"] : Util.alpha(Color.foreground, 0.12)
  readonly property real islandRadius: tones.radius !== undefined ? Number(tones.radius) : Style.cornerRadius
  readonly property real iconStroke: tones.stroke !== undefined ? Number(tones.stroke) : 1.5

  // ModuleSlot (Bar.qml) -> Row/Column of slots -> ModuleList loader.
  property Item slot: null
  readonly property Item container: slot ? slot.parent : null
  readonly property Item host: container ? container.parent : null

  function findSlot() {
    var p = root.parent
    while (p && !("registryComponent" in p && "entry" in p && "region" in p)) p = p.parent
    return p
  }

  function isMarker(s) {
    return !!s && s.moduleName === root.moduleName
  }

  // Visual order: the Row places children by index, but a live layout edit
  // can leave reused slots out of config order, so sort by position. Hidden
  // widgets keep stale coordinates and are left out; markers always count.
  function slotList() {
    if (!container) return []
    var out = []
    var kids = container.children
    for (var i = 0; i < kids.length; i++) {
      var s = kids[i]
      if (!("registryComponent" in s && "entry" in s)) continue
      if (isMarker(s) || (s.visible && extent(s) > 0)) out.push({ slot: s, index: i, pos: vertical ? s.y : s.x })
    }
    out.sort(function(a, b) { return a.pos !== b.pos ? a.pos - b.pos : a.index - b.index })
    return out.map(function(o) { return o.slot })
  }

  function extent(s) {
    return root.vertical ? s.height : s.width
  }

  // Role depends only on sibling order and content sizes, never on positions,
  // so a marker's own size cannot feed back into it.
  readonly property var layout: {
    var list = slotList()
    var idx = list.indexOf(slot)
    if (idx < 0) return { role: "none", first: false, members: [], before: [] }
    var first = true
    for (var i = 0; i < idx; i++) if (isMarker(list[i])) { first = false; break }
    // Widgets the bar pins ahead of every marker (the tray sits at the inner
    // edge of its section) get their own island from the first marker.
    var before = first ? list.slice(0, idx) : []
    var members = []
    var hasContent = false
    for (var j = idx + 1; j < list.length && !isMarker(list[j]); j++) {
      members.push(list[j])
      hasContent = true
    }
    var last = true
    for (var k = idx + 1; k < list.length; k++) if (isMarker(list[k])) { last = false; break }
    var role = hasContent ? "start" : (last && (!first || before.length > 0) ? "end" : "none")
    return { role: role, first: first, members: members.concat(before), before: before }
  }

  readonly property real span: {
    if (layout.role === "end") return pad + edge
    if (layout.role !== "start") return 0
    return layout.first && layout.before.length === 0 ? edge + pad : pad + gap + pad
  }

  // Stay visible at zero size so the Row keeps positioning this marker.
  implicitWidth: vertical ? barSize : span
  implicitHeight: vertical ? span : barSize

  // Pill geometry along the bar axis, in container coordinates.
  readonly property var bounds: {
    if (layout.role !== "start" || !slot) return null
    var startAt = (vertical ? slot.y + slot.height : slot.x + slot.width) - pad
    var list = slotList()
    var idx = list.indexOf(slot)
    var endAt = -1
    for (var j = idx + 1; j < list.length; j++) {
      var s = list[j]
      if (isMarker(s)) { endAt = (vertical ? s.y : s.x) + pad; break }
      endAt = (vertical ? s.y + s.height : s.x + s.width) + pad
    }
    if (endAt <= startAt) return null
    return { start: startAt, end: endAt }
  }

  readonly property var leadBounds: {
    var before = layout.before
    if (!slot || !before || before.length === 0) return null
    return {
      start: (vertical ? before[0].y : before[0].x) - pad,
      end: (vertical ? slot.y : slot.x) + pad
    }
  }

  IslandPill {
    parent: root.host
    island: root
    bounds: root.leadBounds
  }

  IslandPill {
    parent: root.host
    island: root
    bounds: root.bounds
  }

  // ---- palette -------------------------------------------------------------

  FileView {
    id: tonesFile
    path: Color.currentThemePath + "/islands.json"
    watchChanges: true
    printErrors: false
    onLoaded: {
      try { root.tones = JSON.parse(text()) } catch (e) { root.tones = ({}) }
    }
    onLoadFailed: root.tones = ({})
    onFileChanged: reload()
  }

  // Theme switches arrive over IPC after the theme directory is staged, so a
  // color change is the cue to re-read the tones.
  Timer { id: tonesReload; interval: 250; onTriggered: tonesFile.reload() }
  Connections {
    target: Color
    function onBackgroundChanged() { tonesReload.restart() }
    function onForegroundChanged() { tonesReload.restart() }
  }

  // ---- line icons ------------------------------------------------------------

  Component {
    id: iconComponent
    IconText { tones: root.tones; stroke: root.iconStroke }
  }

  property var adoptedButtons: []
  property var overlays: []

  function adopt(item) {
    if (!item) return
    if ("iconComponent" in item && "opticalSize" in item) {
      if (item.iconComponent === null && Icons.hasIcon(item.text)) {
        var btn = item
        btn.hasVisualContent = Qt.binding(function() { return btn.text !== "" })
        btn.iconComponent = iconComponent
        adoptedButtons.push(btn)
      }
      return
    }
    if ("labelVisible" in item && "hasVisualContent" in item && "useActiveColor" in item) {
      if (item.labelVisible === true && Icons.hasIcon(item.text)) {
        var overlay = iconComponent.createObject(item, { btn: item })
        if (overlay) {
          item.labelVisible = false
          overlays.push(overlay)
        }
      }
      return
    }
    var kids = item.children
    for (var i = 0; i < kids.length; i++) adopt(kids[i])
  }

  function scan() {
    if (!slot) slot = findSlot()
    if (!lineIcons || layout.role !== "start") return
    var members = layout.members
    for (var i = 0; i < members.length; i++) adopt(members[i].activeItem)
  }

  function release() {
    for (var i = 0; i < overlays.length; i++) {
      var o = overlays[i]
      if (o && o.btn) o.btn.labelVisible = true
      if (o) o.destroy()
    }
    for (var j = 0; j < adoptedButtons.length; j++) {
      var b = adoptedButtons[j]
      if (b && b.iconComponent === iconComponent) b.iconComponent = null
    }
    overlays = []
    adoptedButtons = []
  }

  // Widgets load lazily and some rebuild their buttons, so keep sweeping.
  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.scan()
  }

  onParentChanged: Qt.callLater(function() { if (!root.slot) root.slot = root.findSlot() })
  onLineIconsChanged: if (!lineIcons) release()
  Component.onDestruction: release()
}
