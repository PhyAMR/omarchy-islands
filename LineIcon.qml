import QtQuick
import QtQuick.Shapes
import "Icons.js" as Icons

// One icon from Icons.js, stroked on a 24px grid and scaled to `size`.
// `faint` sub-paths (unlit wifi arcs, empty battery ticks) draw at low alpha.
Item {
  id: root

  property string name: ""
  property color color: "white"
  property real size: 16
  property real stroke: 1.5
  property real faintAlpha: 0.3

  readonly property string strongPath: Icons.path(name, "d")
  readonly property string faintPath: Icons.path(name, "faint")

  implicitWidth: size
  implicitHeight: size

  Shape {
    width: 24
    height: 24
    scale: root.size / 24
    transformOrigin: Item.TopLeft
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      strokeColor: root.faintPath !== "" ? Qt.rgba(root.color.r, root.color.g, root.color.b, root.faintAlpha) : "transparent"
      strokeWidth: root.stroke
      fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      joinStyle: ShapePath.RoundJoin
      PathSvg { path: root.faintPath !== "" ? root.faintPath : "M0 0" }
    }

    ShapePath {
      strokeColor: root.color
      strokeWidth: root.stroke
      fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      joinStyle: ShapePath.RoundJoin
      PathSvg { path: root.strongPath !== "" ? root.strongPath : "M0 0" }
    }
  }
}
