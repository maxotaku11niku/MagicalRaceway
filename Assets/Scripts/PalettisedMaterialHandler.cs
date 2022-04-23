using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SplineTest
{
    public class PalettisedMaterialHandler : MonoBehaviour
    {
        public Color32[] initPalette = new Color32[256];
        MeshRenderer meshrender;
        Texture2D paletteTex;
        void Awake()
        {
            meshrender = GetComponent<MeshRenderer>();
            paletteTex = new Texture2D(256, 1, TextureFormat.RGBA32, false, true);
            paletteTex.filterMode = FilterMode.Point;
            for(int i = 0; i < 256; i++)
            {
                paletteTex.SetPixel(i, 0, initPalette[i]);
            }
            paletteTex.Apply();
            meshrender.sharedMaterial.SetTexture("_Palette", paletteTex);
        }

        public void EditorPreviewInit() //EDITOR ONLY
        {
            Awake();
        }

        public void EditorPreviewDestroy() //EDITOR ONLY
        {
            
        }

        public void SetPalette(Color32[] pal)
        {
            for(int i = 0; i < pal.Length; i++)
            {
                paletteTex.SetPixel(i,0,pal[i]);
            }
            paletteTex.Apply();
        }
    }
}