import QtQuick
import qs.Commons
import "Icons.js" as Icons

// Renders a widget's glyph label as line icons plus any plain text around
// them ("85% <battery>"). Used two ways:
//   - as a BarIconButton.iconComponent, where the button is three parents up
//     (Loader -> optical canvas -> button);
//   - as an overlay child of a plain WidgetButton, with `btn` set explicitly.
Item {
  id: root

  property var btn: null
  property var tones: ({})
  property real stroke: 1.5
  readonly property var target: btn ? btn : (parent && parent.parent ? parent.parent.parent : null)
  readonly property string label: target ? String(target.text || "") : ""
  readonly property var runs: Icons.segments(label)
  readonly property bool alerting: !!target && target.active === true && target.useActiveColor !== false
  readonly property color baseColor: target ? target.foreground : Color.foreground
  readonly property real fontPx: target && target.fontSize ? target.fontSize : Style.bar.iconFont
  readonly property real iconPx: Math.max(13, Math.round(fontPx / Style.bar.iconFont * Style.bar.iconCanvas))

  function toneColor(tone) {
    if (alerting) return target.activeColor
    var c = tones ? tones[tone] : undefined
    return c ? c : baseColor
  }

  anchors.centerIn: btn ? parent : undefined
  anchors.fill: btn ? undefined : parent
  implicitWidth: row.implicitWidth
  implicitHeight: row.implicitHeight

  Row {
    id: row
    anchors.centerIn: parent
    spacing: Style.space(4)

    Repeater {
      model: root.runs

      Item {
        required property var modelData
        readonly property bool isIcon: modelData.kind === "icon"
        width: isIcon ? icon.implicitWidth : text.implicitWidth
        height: Math.max(root.iconPx, text.implicitHeight)

        LineIcon {
          id: icon
          visible: parent.isIcon
          anchors.centerIn: parent
          name: parent.isIcon ? modelData.name : ""
          size: root.iconPx
          stroke: root.stroke
          color: root.toneColor(parent.isIcon ? modelData.tone : "")
        }

        Text {
          id: text
          visible: !parent.isIcon
          anchors.centerIn: parent
          textFormat: Text.PlainText
          text: parent.isIcon ? "" : modelData.value
          color: root.alerting ? root.target.activeColor : root.baseColor
          font.family: root.target ? root.target.fontFamily : Style.font.family
          font.pixelSize: root.fontPx
        }
      }
    }
  }
}
