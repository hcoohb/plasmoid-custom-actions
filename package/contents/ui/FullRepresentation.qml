/*
 * Copyright 2018  Fabien Valthier <hcoohb@gmail.com>
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
