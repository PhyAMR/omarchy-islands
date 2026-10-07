import QtQuick

// The rounded pill behind one island. `bounds` is {start, end} along the bar
// axis in the section Row's coordinates; null hides it.
Rectangle {
  id: pill

  property var island: null
  property var bounds: null

  readonly property Item container: island ? island.container : null
  readonly property bool vertical: island ? island.vertical : false
  readonly property real cross: island ? island.barSize - island.inset * 2 : 0

  z: -1
  visible: bounds !== null && container !== null
  x: !container || !bounds ? 0 : container.x + (vertical ? island.inset : bounds.start)
  y: !container || !bounds ? 0 : container.y + (vertical ? bounds.start : island.inset)
  width: !bounds ? 0 : (vertical ? cross : bounds.end - bounds.start)
  height: !bounds ? 0 : (vertical ? bounds.end - bounds.start : cross)
  radius: island ? Math.min(island.islandRadius, cross / 2) : 0
  color: island ? island.islandColor : "transparent"
  border.width: 1
  border.color: island ? island.islandBorder : "transparent"

  Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
  Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
  Behavior on color { ColorAnimation { duration: 420; easing.type: Easing.InOutCubic } }
}
