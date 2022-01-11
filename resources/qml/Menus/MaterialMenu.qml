// Copyright (c) 2022 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.4

import UM 1.5 as UM
import Cura 1.0 as Cura

UM.Menu
{
    id: menu
    title: catalog.i18nc("@label:category menu label", "Material")

    property int extruderIndex: 0
    property string currentRootMaterialId:
    {
        var value = Cura.MachineManager.currentRootMaterialId[extruderIndex]
        return (value === undefined) ? "" : value
    }
    property var activeExtruder:
    {
        var activeMachine = Cura.MachineManager.activeMachine
        return (activeMachine === null) ? null : activeMachine.extruderList[extruderIndex]
    }
    property bool isActiveExtruderEnabled: (activeExtruder === null || activeExtruder === undefined) ? false : activeExtruder.isEnabled

    property string activeMaterialId: (activeExtruder === null || activeExtruder === undefined) ? false : activeExtruder.material.id

    property bool updateModels: true
    Cura.FavoriteMaterialsModel
    {
        id: favoriteMaterialsModel
        extruderPosition: menu.extruderIndex
        enabled: updateModels
    }

    Cura.GenericMaterialsModel
    {
        id: genericMaterialsModel
        extruderPosition: menu.extruderIndex
        enabled: updateModels
    }

    Cura.MaterialBrandsModel
    {
        id: brandModel
        extruderPosition: menu.extruderIndex
        enabled: updateModels
    }

    UM.MenuItem
    {
        text: catalog.i18nc("@label:category menu label", "Favorites")
        enabled: false
        visible: favoriteMaterialsModel.items.length > 0
        height: visible ? implicitHeight: 0
    }

    Instantiator
    {
        model: favoriteMaterialsModel
        delegate: UM.MenuItem
        {
            text: model.brand + " " + model.name
            checkable: true
            enabled: isActiveExtruderEnabled
            checked: model.root_material_id === menu.currentRootMaterialId
            onTriggered: Cura.MachineManager.setMaterial(extruderIndex, model.container_node)
        }
        onObjectAdded: menu.insertItem(index, object)
        onObjectRemoved: menu.removeItem(index)
    }

    MenuSeparator {}

    Menu
    {
        id: genericMenu
        title: catalog.i18nc("@label:category menu label", "Generic")

        Instantiator
        {
            model: genericMaterialsModel
            delegate: UM.MenuItem
            {
                text: model.name
                checkable: true
                enabled: isActiveExtruderEnabled
                checked: model.root_material_id === menu.currentRootMaterialId
                onTriggered: Cura.MachineManager.setMaterial(extruderIndex, model.container_node)
            }
            onObjectAdded: genericMenu.insertItem(index, object)
            onObjectRemoved: genericMenu.removeItem(index)
        }
    }

    MenuSeparator {}

    Instantiator
    {
        model: brandModel
        UM.Menu
        {
            id: brandMenu
            title: brandName
            property string brandName: model.name
            property var brandMaterials: model.material_types

            Instantiator
            {
                model: brandMaterials
                delegate: Menu
                {
                    id: brandMaterialsMenu
                    title: materialName
                    property string materialName: model.name
                    property var brandMaterialColors: model.colors

                    Instantiator
                    {
                        model: brandMaterialColors
                        delegate: UM.MenuItem
                        {
                            text: model.name
                            checkable: true
                            enabled: isActiveExtruderEnabled
                            checked: model.id === menu.activeMaterialId

                            onTriggered: Cura.MachineManager.setMaterial(extruderIndex, model.container_node)
                        }
                        onObjectAdded: brandMaterialsMenu.insertItem(index, object)
                        onObjectRemoved: brandMaterialsMenu.removeItem(object)
                    }
                }
                onObjectAdded: brandMenu.insertMenu(index, object)
                onObjectRemoved: brandMenu.removeMenu(object)
            }
        }
        onObjectAdded: menu.insertMenu(index, object)
        onObjectRemoved: menu.removeMenu(object)
    }

    MenuSeparator {}

    UM.MenuItem
    {
        action: Cura.Actions.manageMaterials
    }

    MenuSeparator {}

    UM.MenuItem
    {
        action: Cura.Actions.marketplaceMaterials
    }
}
