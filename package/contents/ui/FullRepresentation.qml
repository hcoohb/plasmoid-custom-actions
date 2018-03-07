/*
 * Copyright 2016  Daniel Faust <hessijames@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.5
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    property real mediumSpacing: 1.5*units.smallSpacing
    property real itemHeight: Math.max(units.iconSizes.smallMedium, theme.defaultFont.pixelSize)

    Layout.minimumWidth: widgetWidth
    Layout.minimumHeight: (itemHeight + 2*mediumSpacing) * listView.count

    Layout.maximumWidth: Layout.minimumWidth
    Layout.maximumHeight: Layout.minimumHeight

    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight
    
    property string actionsJsonStr: plasmoid.configuration.actions
    
    
    onActionsJsonStrChanged: {
        menuModel.clear()
        getActionsArray().forEach(function (actionObj) {
            menuModel.append({
                menuitem_name: actionObj.menuitem_name,
                menuitem_icon: actionObj.menuitem_icon,
                menuitem_path: actionObj.menuitem_path
            })
        })
    }
    
    Component.onCompleted: {

    }
    
    
    PlasmaCore.DataSource {
        id: executeSource
        engine: "executable"
        connectedSources: []
        onNewData: {
            disconnectSource(sourceName)
        }
    }
    
    function exec(cmd) {
        executeSource.connectSource(cmd)
    }
    
    
    ListModel {
        id: menuModel

        /*ListElement {
            menuitem_name: "Keyboard on"
            menuitem_path: "/home/hcooh/Documents/linux/scripts/keyboard.sh on"
            menuitem_icon: "input-keyboard-virtual-on"
        }
        ListElement {
            menuitem_name: "Keyboard off"
            menuitem_path: "/home/hcooh/Documents/linux/scripts/keyboard.sh off"
            menuitem_icon: "input-keyboard-virtual-off"
        }
        ListElement {
            menuitem_name: "Rotate Normal"
            menuitem_path: "/home/hcooh/Documents/linux/scripts/rotate.sh normal"
            menuitem_icon: "computer-symbolic"
        }
        ListElement {
            menuitem_name: "Rotate Inverted"
            menuitem_path: "/home/hcooh/Documents/linux/scripts/rotate.sh inverted"
            menuitem_icon: "circular-arrow-shape"
        }
        ListElement {
            menuitem_name: "Rotate Right"
            menuitem_path: "/home/hcooh/Documents/linux/scripts/rotate.sh right"
            menuitem_icon: "edit-redo-symbolic"
        }
        ListElement {
            menuitem_name: "Rotate Left"
            menuitem_path: "/home/hcooh/Documents/linux/scripts/rotate.sh left"
            menuitem_icon: "edit-undo-symbolic"
        }
        ListElement {
            menuitem_name: "Resolution Max"
            menuitem_path: "xrandr --output eDP1 --mode 1920x1080"
            menuitem_icon: "computer"
        }
        ListElement {
            menuitem_name: "Resolution Med"
            menuitem_path: "xrandr --output eDP1 --mode 1600x900"
            menuitem_icon: "computer"
        }
        ListElement {
            menuitem_name: "Resolution Min"
            menuitem_path: "xrandr --output eDP1 --mode 1368x768"
            menuitem_icon: "computer"
        }*/
    }

    PlasmaExtras.ScrollArea {
        anchors.fill: parent
        
        ListView {
            id: listView
            anchors.fill: parent

            model: menuModel

            highlight: PlasmaComponents.Highlight {}
            highlightMoveDuration: 0
            highlightResizeDuration: 0

            delegate: Item {
                width: parent.width
                height: itemHeight + 2*mediumSpacing

                property bool isHovered: false

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        listView.currentIndex = index
                        isHovered = true
                    }
                    onExited: {
                        isHovered = false
                    }
                    onClicked: {
                        plasmoid.expanded = false
                        exec(menuitem_path)
                    }

                    Row {
                        x: mediumSpacing
                        y: mediumSpacing
                        width: parent.width - 2*mediumSpacing
                        height: itemHeight
                        spacing: mediumSpacing

                        Item { // Hack - since setting the dimensions of PlasmaCore.IconItem won't work
                            height: units.iconSizes.smallMedium
                            width: height
                            anchors.verticalCenter: parent.verticalCenter

                            PlasmaCore.IconItem {
                                anchors.fill: parent
                                source: menuitem_icon
                                active: isHovered
                            }
                        }

                        PlasmaComponents.Label {
                            text: menuitem_name
                            width: parent.width - units.iconSizes.smallMedium - mediumSpacing
                            height: parent.height
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
    
    function getActionsArray() {
        var cfgActions = plasmoid.configuration.actions
        //console.log('Reading places from configuration: ' + cfgActions)
        return JSON.parse(cfgActions)
    }
}
