using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.AssetImporters;

[ScriptedImporter(1, "btm")]
public class BTMImporter : ScriptedImporter
{
    public override void OnImportAsset(AssetImportContext ctx)
    {
        BambooTrackerModule btmModule = ScriptableObject.CreateInstance<BambooTrackerModule>();
        btmModule.LoadBTMDataFromFile(ctx.assetPath);
        ctx.AddObjectToAsset("Module", btmModule);
        ctx.SetMainObject(btmModule);
    }
}