using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BambooTrackerModule : ScriptableObject
{
    public byte[] data; //Just stores the data in the module in memory
    
    public void LoadBTMDataFromFile(string path)
    {
        FileStream btmFileStream = File.Open(path, FileMode.Open);
        byte[] byteArray = new byte[btmFileStream.Length];
        BinaryReader reader = new BinaryReader(btmFileStream);
        for(long b = 0; b < byteArray.Length; b++)
        {
            byteArray[b] = reader.ReadByte();
        }
        data = byteArray;
    }
}
