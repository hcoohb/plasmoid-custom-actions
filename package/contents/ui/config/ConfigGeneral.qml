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
import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    property alias cfg_title: title.text
    property alias cfg_icon: icon.text
    property string cfg_actions
    property alias cfg_widgetWidth: widgetWidth.value
    
    Dialog {
        id: editActionDialog
        title: i18n('Edit a custom action')
        standardButtons: StandardButton.Cancel | StandardButton.Ok 
        
        property int tableIndex: 0
        width: 400
        //height: 200
        
        GridLayout {
            columns: 2
            anchors.fill: parent

            Label {
                text: i18n('Name:')
            }

            TextField {
                id: editActionDlgName
                Layout.fillWidth: true
            }

            Label {
                text: i18n('Icon:')
            }
            
            TextField {
                id: editActionDlgIcon
                Layout.fillWidth: true
            }
            
            Label {
                text: i18n('Command:')
            }
            
            TextField {
                id: editActionDlgPath
                Layout.fillWidth: true
            }
        }
        onAccepted: {
            console.log("Edit Action Dlg accepted")
            console.log(tableIndex)
            if (tableIndex==-1) { //we create a new one
                actionsModel.append({
                    menuitem_name: editActionDlgName.text,
                    menuitem_icon: editActionDlgIcon.text,
                    menuitem_path: editActionDlgPath.text
                })
            }
            else { //we update selected
                actionsModel.set(tableIndex,{'menuitem_name': editActionDlgName.text})
                actionsModel.set(tableIndex,{'menuitem_icon': editActionDlgIcon.text})
                actionsModel.set(tableIndex,{'menuitem_path': editActionDlgPath.text})
            }
            actionsModelChanged()
            close()
        }
    }
    
    ListModel {
        id: actionsModel
    }
    
    Component.onCompleted: {
        var actions = getActionsArray() //usefull ????
        getActionsArray().forEach(function (actionObj) {
            actionsModel.append({
                menuitem_name: actionObj.menuitem_name,
                menuitem_icon: actionObj.menuitem_icon,
                menuitem_path: actionObj.menuitem_path
            })
        })
    }
    
    function actionsModelChanged() {
        var newActionsArray = []
        for (var i = 0; i < actionsModel.count; i++) {
            var actionObj = actionsModel.get(i)
            newActionsArray.push({
                menuitem_name: actionObj.menuitem_name,
                menuitem_icon: actionObj.menuitem_icon,
                menuitem_path: actionObj.menuitem_path
            })
        }
        cfg_actions = JSON.stringify(newActionsArray)
        console.log('[custom-actions] actions: ' + cfg_actions)
    }
    
    GridLayout {
        columns: 2
        anchors.left: parent.left
        anchors.right: parent.right

        Label {
            text: i18n('Title:')
        }

        TextField {
            id: title
        }

        Label {
            text: i18n('Icon:')
        }

        RowLayout {
            TextField {
                id: icon
            }

            Button {
                iconName: 'folder'
                onClicked: {
                    iconDialog.open()
                }
            }
        }


        Label {
            text: i18n('Widget width:')
        }

        SpinBox {
            id: widgetWidth
            minimumValue: units.iconSizes.medium + 2*units.smallSpacing
            maximumValue: 1000
            decimals: 0
            stepSize: 10
            suffix: ' px'
        }
    
    
    
        Label {
            text: i18n('Actions:')
        }
        
        Item{
            width:2
            height:2
        }
        
        TableView {
            id: placesTable
            width: parent.width
            model: actionsModel
            Layout.preferredHeight: 150
            Layout.preferredWidth: parent.width
            Layout.columnSpan: 2
            
            TableViewColumn {
                id: menuitem_iconCol
                role: 'menuitem_icon'
                title: i18n('Icon')
                width: parent.width * 0.1
                
                delegate: PlasmaCore.IconItem {
                                            anchors.fill: parent
                                            source: styleData.value
                                            //active: isHovered
                                        }
                    /*Label {
                    text: styleData.value
                    elide: Text.ElideRight
                    anchors.left: parent ? parent.left : undefined
                    anchors.leftMargin: 5
                    anchors.right: parent ? parent.right : undefined
                    anchors.rightMargin: 5
                }*/
            }
            
            TableViewColumn {
                id: menuitem_name
                role: 'menuitem_name'
                title: i18n('Action name')
                width: parent.width * 0.2
                
                delegate: Label {
                    text: styleData.value
                    elide: Text.ElideRight
                    anchors.left: parent ? parent.left : undefined
                    anchors.leftMargin: 5
                    anchors.right: parent ? parent.right : undefined
                    anchors.rightMargin: 5
                }
            }
            
            TableViewColumn {
                role: 'menuitem_path'
                title: i18n('Action Command')
                width: parent.width * 0.4
                
                delegate: Label {
                    id: placeAliasText
                    text: styleData.value
                    anchors.left: parent ? parent.left : undefined
                    anchors.leftMargin: 5
                    anchors.right: parent ? parent.right : undefined
                    anchors.rightMargin: 5
                }
            }
            
            TableViewColumn {
                title: i18n('Edit')
                width: parent.width * 0.2
                
                delegate: Item {
                    
                    GridLayout {
                        height: parent.height
                        columns: 4
                        rowSpacing: 0
                        
                        Button {
                            iconName: 'document-edit'
                            Layout.fillHeight: true
                            onClicked: {
                                editActionDialog.open()
                                editActionDialog.tableIndex = styleData.row
                                editActionDlgName.text = actionsModel.get(styleData.row).menuitem_name
                                editActionDlgIcon.text = actionsModel.get(styleData.row).menuitem_icon
                                editActionDlgPath.text = actionsModel.get(styleData.row).menuitem_path
                                editActionDlgName.focus = true
                            }
                        }
                        
                        Button {
                            iconName: 'go-up'
                            Layout.fillHeight: true
                            onClicked: {
                                actionsModel.move(styleData.row, styleData.row - 1, 1)
                                actionsModelChanged()
                            }
                            enabled: styleData.row > 0
                        }
                        
                        Button {
                            iconName: 'go-down'
                            Layout.fillHeight: true
                            onClicked: {
                                actionsModel.move(styleData.row, styleData.row + 1, 1)
                                actionsModelChanged()
                            }
                            enabled: styleData.row < actionsModel.count - 1
                        }
                        
                        Button {
                            iconName: 'list-remove'
                            Layout.fillHeight: true
                            onClicked: {
                                actionsModel.remove(styleData.row)
                                actionsModelChanged()
                            }
                        }
                    }
                }
                
            }
        }
        
        Button {
                id: addAppButton
                anchors.right: parent.right
                text: i18n('Add action')
                iconName: 'list-add'
                onClicked: {
                    editActionDialog.open()
                    editActionDialog.tableIndex = -1
                    editActionDlgName.text = ''
                    editActionDlgIcon.text = ''
                    editActionDlgPath.text = ''
                    editActionDlgName.focus = true
                }
            }  
        
         Item{
            width:2
            height:2
        }

       /* ColumnLayout {
            Layout.columnSpan: 2
            Rectangle {
                width: 300
                height: 200
                border {
                    width: 1
                    color: "lightgrey"
                }
                radius: 2
                color: "#20FFFFFF"

                ScrollView {
                    anchors.fill: parent

                    ListView {
                        id: apps
                        anchors.fill: parent
                        clip: true
                        model: actionsModel

                        delegate: Item {
                            id: appItem
                            width: parent.width
                            height: units.iconSizes.smallMedium + 2*units.smallSpacing

                            property bool isHovered: false
                            property bool isUpHovered: false
                            property bool isDownHovered: false
                            property bool isRemoveHovered: false

                            MouseArea {
                                id: container
                                anchors.fill: parent

                                hoverEnabled: true
                                onEntered: {
                                    apps.currentIndex = index
                                    isHovered = true
                                }
                                onExited: {
                                    isHovered = false
                                }

                                RowLayout {
                                    x: units.smallSpacing
                                    y: units.smallSpacing

                                    Item { // Hack - since setting the dimensions of PlasmaCore.IconItem won't work
                                        height: units.iconSizes.smallMedium
                                        width: height

                                        PlasmaCore.IconItem {
                                            anchors.fill: parent
                                            source: menuitem_icon
                                            active: isHovered
                                        }
                                    }

                                    Label {
                                        text: menuitem_name
                                        height: parent.height
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Rectangle {
                                    height: units.iconSizes.smallMedium
                                    width: 3*units.iconSizes.smallMedium + 4*units.smallSpacing
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: isHovered

                                    radius: units.iconSizes.smallMedium / 4
                                    color: theme.viewBackgroundColor
                                    opacity: 0.8

                                    Behavior on opacity { NumberAnimation { duration: units.shortDuration * 3 } }

                                    RowLayout {
                                        x: units.smallSpacing
                                        spacing: units.smallSpacing

                                        Item {
                                            id: upIcon
                                            height: units.iconSizes.smallMedium
                                            width: height
                                            opacity: 1.0

                                            PlasmaCore.IconItem {
                                                anchors.fill: parent
                                                source: 'arrow-up'
                                                active: isUpHovered

                                                MouseArea {
                                                    anchors.fill: parent

                                                    hoverEnabled: true
                                                    onEntered: {
                                                        isUpHovered = true
                                                    }
                                                    onExited: {
                                                        isUpHovered = false
                                                    }

                                                    onClicked: {
                                                        var m = moveUp(apps.model, modelData)
                                                        cfg_apps = m
                                                        apps.model = m
                                                    }
                                                }
                                            }
                                        }

                                        Item {
                                            id: downIcon
                                            height: units.iconSizes.smallMedium
                                            width: height
                                            opacity: 1.0

                                            PlasmaCore.IconItem {
                                                anchors.fill: parent
                                                source: 'arrow-down'
                                                active: isDownHovered

                                                MouseArea {
                                                    anchors.fill: parent

                                                    hoverEnabled: true
                                                    onEntered: {
                                                        isDownHovered = true
                                                    }
                                                    onExited: {
                                                        isDownHovered = false
                                                    }

                                                    onClicked: {
                                                        var m = moveDown(apps.model, modelData)
                                                        cfg_apps = m
                                                        apps.model = m
                                                    }
                                                }
                                            }
                                        }

                                        Item {
                                            id: removeIcon
                                            height: units.iconSizes.smallMedium
                                            width: height
                                            opacity: 1.0

                                            PlasmaCore.IconItem {
                                                anchors.fill: parent
                                                source: 'remove'
                                                active: isRemoveHovered

                                                MouseArea {
                                                    anchors.fill: parent

                                                    hoverEnabled: true
                                                    onEntered: {
                                                        isRemoveHovered = true
                                                    }
                                                    onExited: {
                                                        isRemoveHovered = false
                                                    }

                                                    onClicked: {
                                                        var m = apps.model
                                                        var i = null
                                                        while ((i = m.indexOf(modelData)) !== -1) {
                                                            m.splice(i, 1)
                                                        }
                                                        cfg_apps = m
                                                        apps.model = m
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        /*Component.onCompleted: {
                            model = plasmoid.configuration.apps
                        }
                    }
                }
            }
        
                 
        }
    */
    }
    
    
    
    
    //End of UI
    
    FileDialog {
        id: iconDialog
        title: 'Please choose an image file'
        folder: '/usr/share/icons/breeze/'
        nameFilters: ['Image files (*.png *.jpg *.xpm *.svg *.svgz)', 'All files (*)']
        onAccepted: {
            icon.text = iconDialog.fileUrl
        }
    }
    

   function moveUp(m, value) {
        var index = m.indexOf(value)
        var newPos = index - 1

        if (newPos < 0)
            newPos = 0

        m.splice(index, 1)
        m.splice(newPos, 0, value)

        return m
    }

    function moveDown(m, value) {
        var index = m.indexOf(value)
        var newPos = index + 1

        if (newPos >= m.length)
            newPos = m.length

        m.splice(index, 1)
        m.splice(newPos, 0, value)

        return m
    }
    function getActionsArray() {
        var cfgActions = plasmoid.configuration.actions
        console.log('Reading places from configuration: ' + cfgActions)
        return JSON.parse(cfgActions)
    }
}

