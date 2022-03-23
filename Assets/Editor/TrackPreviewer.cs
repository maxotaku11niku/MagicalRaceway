using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using SplineTest;

public class TrackPreviewer : EditorWindow
{
    public TrackDefinition track;
    public PlayMaster playMaster;
    public float distance;
    public float xoffs;
    List<GameObject> spawnedSprites = new List<GameObject>(); //Even though a list is slower, it can expand dynamically, and speed is not important here
    List<GameObject> spawnedStrips = new List<GameObject>();
    int spriteCounter;

    [MenuItem("Window/Utilities/Preview Track")]
    static void StartPreview()
    {
        TrackPreviewer tp = EditorWindow.GetWindow<TrackPreviewer>();
        tp.Show();
    }

    void OnGUI()
    {
        track = (TrackDefinition)EditorGUILayout.ObjectField("Track", track, typeof(TrackDefinition), false);
        playMaster = (PlayMaster)EditorGUILayout.ObjectField("Play Master", playMaster, typeof(PlayMaster), true);
        distance = EditorGUILayout.FloatField("Distance", distance);
        xoffs = EditorGUILayout.FloatField("X Offset", xoffs);
        if (GUILayout.Button("Preview")) ShowPreview();
        if (GUILayout.Button("Reset")) DeletePreview();
    }

    private void ShowPreview() //Pretty much just copied from PlayMaster
    {
        int startind = 0;
        int currentind = 0;
        int finind = 0;
        int indlen = 0;
        spriteCounter = 0;
        Color32[] colourInterp = new Color32[256];
		playMaster.gameObject.SetActive(true);
        playMaster.spline.yOffset = distance;
        playMaster.spline.xOffset = xoffs;
        playMaster.paletteMat.EditorPreviewInit();
        playMaster.skyPal.EditorPreviewInit();
        foreach (GameObject s in spawnedSprites)
        {
            GameObject.DestroyImmediate(s);
        }
        foreach(GameObject s in spawnedStrips)
        {
            GameObject.DestroyImmediate(s);
        }
        spawnedSprites = new List<GameObject>();
        for (int i = 1; i < track.tTurnStrList.Length; i++)
        {
            if (distance >= track.tTurnStrList[i - 1].distance && distance < track.tTurnStrList[i].distance)
            {
                currentind = i - 1;
            }
            else if (distance >= track.tTurnStrList[track.tTurnStrList.Length - 1].distance)
            {
                currentind = i - 1;
            }
        }
        startind = currentind - playMaster.roadParamsKeepBehind;
        if (startind <= 0)
        {
            startind = 0;
        }
        finind = currentind + playMaster.roadParamsLookAhead;
        if (finind >= track.tTurnStrList.Length)
        {
            finind = track.tTurnStrList.Length - 1;
        }
        indlen = finind - startind + 1;
        playMaster.spline.turnStrList = new float[indlen + 2];
        playMaster.spline.turnStrPoints = new float[indlen + 2];
        playMaster.spline.turnStrList[0] = track.tTurnStrList[startind].val;
        playMaster.spline.turnStrPoints[0] = track.tTurnStrList[startind].distance;
        for (int i = 0; i <= indlen; i++)
        {
            if (i == indlen)
            {
                playMaster.spline.turnStrList[i + 1] = track.tTurnStrList[i + startind - 1].val;
                playMaster.spline.turnStrPoints[i + 1] = 999999999f;
            }
            else
            {
                playMaster.spline.turnStrList[i + 1] = track.tTurnStrList[i + startind].val;
                playMaster.spline.turnStrPoints[i + 1] = track.tTurnStrList[i + startind].distance;
            }
        }
        for (int i = 1; i < track.tSplitAmtList.Length; i++)
        {
            if (distance >= track.tSplitAmtList[i - 1].distance && distance < track.tSplitAmtList[i].distance)
            {
                currentind = i - 1;
            }
            else if (distance >= track.tSplitAmtList[track.tSplitAmtList.Length - 1].distance)
            {
                currentind = i - 1;
            }
        }
        startind = currentind - playMaster.roadParamsKeepBehind;
        if (startind <= 0)
        {
            startind = 0;
        }
        finind = currentind + playMaster.roadParamsLookAhead;
        if (finind >= track.tSplitAmtList.Length)
        {
            finind = track.tSplitAmtList.Length - 1;
        }
        indlen = finind - startind + 1;
        playMaster.spline.splitAmtList = new float[indlen + 2];
        playMaster.spline.splitAmtPoints = new float[indlen + 2];
        playMaster.spline.splitAmtList[0] = track.tSplitAmtList[startind].val;
        playMaster.spline.splitAmtPoints[0] = track.tSplitAmtList[startind].distance;
        for (int i = 0; i <= indlen; i++)
        {
            if (i == indlen)
            {
                playMaster.spline.splitAmtList[i + 1] = track.tSplitAmtList[i + startind - 1].val;
                playMaster.spline.splitAmtPoints[i + 1] = 999999999f;
            }
            else
            {
                playMaster.spline.splitAmtList[i + 1] = track.tSplitAmtList[i + startind].val;
                playMaster.spline.splitAmtPoints[i + 1] = track.tSplitAmtList[i + startind].distance;
            }
        }
        for (int i = 1; i < track.tPitchStrList.Length; i++)
        {
            if (distance >= track.tPitchStrList[i - 1].distance && distance < track.tPitchStrList[i].distance)
            {
                currentind = i - 1;
            }
            else if (distance >= track.tPitchStrList[track.tPitchStrList.Length - 1].distance)
            {
                currentind = i - 1;
            }
        }
        startind = currentind - playMaster.roadParamsKeepBehind;
        if (startind <= 0)
        {
            startind = 0;
        }
        finind = currentind + playMaster.roadParamsLookAhead;
        if (finind >= track.tPitchStrList.Length)
        {
            finind = track.tPitchStrList.Length - 1;
        }
        indlen = finind - startind + 1;
        playMaster.spline.pitchStrList = new float[indlen + 2];
        playMaster.spline.pitchStrPoints = new float[indlen + 2];
        playMaster.spline.pitchStrList[0] = track.tPitchStrList[startind].val;
        playMaster.spline.pitchStrPoints[0] = track.tPitchStrList[startind].distance;
        for (int i = 0; i <= indlen; i++)
        {
            if (i == indlen)
            {
                playMaster.spline.pitchStrList[i + 1] = track.tPitchStrList[i + startind - 1].val;
                playMaster.spline.pitchStrPoints[i + 1] = 999999999f;
            }
            else
            {
                playMaster.spline.pitchStrList[i + 1] = track.tPitchStrList[i + startind].val;
                playMaster.spline.pitchStrPoints[i + 1] = track.tPitchStrList[i + startind].distance;
            }
        }
        float distanceFactor;
        for (int i = 1; i < track.tBGList.Length; i++)
        {
            if (distance >= track.tBGList[i - 1].distance && distance < track.tBGList[i].distance)
            {
                distanceFactor = (distance - track.tBGList[i - 1].distance) / (track.tBGList[i].distance - track.tBGList[i - 1].distance);
                colourInterp[0] = Color32.Lerp(track.tBGList[i - 1].val.spriteColour, track.tBGList[i].val.spriteColour, distanceFactor);
                playMaster.bg1sprrend.sprite = track.tBGList[i - 1].val.bg1Sprite;
                playMaster.bg2sprrend.sprite = track.tBGList[i - 1].val.bg2Sprite;
                playMaster.bg1sprrend.color = colourInterp[0];
                playMaster.bg2sprrend.color = colourInterp[0];
            }
        }
        for (int i = 1; i < track.tColourList.Length; i++)
        {
            if (distance >= track.tColourList[i - 1].distance && distance < track.tColourList[i].distance)
            {
                distanceFactor = (distance - track.tColourList[i - 1].distance) / (track.tColourList[i].distance - track.tColourList[i - 1].distance);
                for (int j = 0; j < 256; j++)
                {
                    if (j >= track.tColourList[i - 1].val.Length || j >= track.tColourList[i].val.Length)
                    {
                        continue;
                    }
                    colourInterp[j] = Color32.Lerp(track.tColourList[i - 1].val[j], track.tColourList[i].val[j], distanceFactor);
                }
            }
            else if (distance >= track.tColourList[i].distance)
            {
                for (int j = 0; j < 256; j++)
                {
                    if (j >= track.tColourList[i].val.Length)
                    {
                        continue;
                    }
                    colourInterp[j] = track.tColourList[i].val[j];
                }
            }
        }
        playMaster.paletteMat.SetPalette(colourInterp);
        playMaster.skyPal.SetPalette(colourInterp);
        MeshRenderer rendererS = playMaster.skyObj.GetComponent<MeshRenderer>();
        MeshFilter filterS = playMaster.skyObj.GetComponent<MeshFilter>();
        Texture textureS = rendererS.material.mainTexture;
        Mesh meshS = new Mesh();
        filterS.mesh = meshS;
        Vector3[] vertexS = new Vector3[] { new Vector3(0.0f, -256.0f, 0.0f), new Vector3(320.0f, -256.0f, 0.0f), new Vector3(320.0f, 512.0f, 0.0f), new Vector3(0.0f, 512.0f, 0.0f) };
        Vector2[] uvS = new Vector2[] { new Vector2(0.0f, -2.0f), new Vector2(320f / ((float)textureS.width), -2.0f), new Vector2(320f / ((float)textureS.width), 4.0f), new Vector2(0.0f, 4.0f) };
        int[] triS = new int[] { 0, 3, 1, 2, 1, 3 };
        meshS.vertices = vertexS;
        meshS.uv = uvS;
        meshS.triangles = triS;
        playMaster.spline.EditorPreviewInit();
        float horizonHeight = playMaster.spline.GetHorizonHeight();
        playMaster.skyObj.transform.position = new Vector3(0f, horizonHeight, playMaster.spline.baseSplineHeight + 0.02f);
        playMaster.background1.transform.position = new Vector3(0f, horizonHeight, playMaster.spline.baseSplineHeight);
        playMaster.background2.transform.position = new Vector3(0f, horizonHeight, playMaster.spline.baseSplineHeight + 0.01f);
        SpriteManager sprmanage;
        GameObject sprobj;
        int sidefactor;
        MultiSprite.SpawnSide currentSpawnSide;
        float realDist;
        float realXOff;
        MultiSprite thisSpr;
        float d;
        Vector3 collisionBounds;
        for (int i = 0; i < track.tSpriteList.Length; i++)
        {
            if (!((track.tSpriteList[i].distance + track.tSpriteList[i].val.separation * track.tSpriteList[i].val.numSpr) < (distance - playMaster.spriteUnloadBehindDistance)) && (distance + playMaster.spriteDrawDistance) >= track.tSpriteList[i].distance)
            {
                thisSpr = track.tSpriteList[i].val;
                sidefactor = (thisSpr.side == MultiSprite.SpawnSide.BOTH) ? 2 : 1;
                currentSpawnSide = (sidefactor == 2) ? MultiSprite.SpawnSide.RIGHT : thisSpr.side;
                realDist = -1000f;
                realXOff = 1000f;
                for (int j = 0; j < track.tSpriteList[i].val.numSpr * sidefactor; j++)
                {
                    if (sidefactor == 2) currentSpawnSide = (MultiSprite.SpawnSide)((j + 1) % 2);
                    d = track.tSpriteList[i].distance + track.tSpriteList[i].val.separation * (j / sidefactor);
                    realDist = d;
                    realXOff = playMaster.spline.GetRealXOff(thisSpr.xOffset, realDist, currentSpawnSide);
                    sprobj = Instantiate<GameObject>(playMaster.spritePrefab, new Vector3(0f, 0f, 0f), Quaternion.identity, playMaster.gameObject.transform);
                    sprmanage = sprobj.GetComponent<SpriteManager>();
                    sprmanage.EditorPreviewInit();
                    collisionBounds = thisSpr.spriteDef.GetRealCollisionBounds(thisSpr.baseScale);
                    sprmanage.physPos = new Vector3(realXOff, collisionBounds.y / 2f, realDist - distance);
                    sprmanage.spriteRenderer.sprite = thisSpr.spriteDef.sprite;
                    sprmanage.spriteRenderer.flipX = (sidefactor == 2) ? (thisSpr.flip ^ (thisSpr.flipOnOtherSide && ((j % 2) == 1))) : thisSpr.flip;
                    sprmanage.screenPos = playMaster.spline.GetScreenPos(realDist, realXOff, thisSpr.yOffset);
                    sprmanage.spriteScale = Vector3.one * playMaster.spline.GetScale(realDist) / thisSpr.baseScale;
                    sprmanage.collisionBox.size = collisionBounds;
                    sprmanage.spriteType = SpriteManager.SpriteType.STATIC;
                    sprmanage.canCollide = thisSpr.canCollide;
                    sprmanage.trueDistance = d;
                    sprmanage.xOffset = thisSpr.xOffset;
                    sprmanage.yOffset = thisSpr.yOffset;
                    sprmanage.anchorSide = currentSpawnSide;
                    sprmanage.baseScale = thisSpr.baseScale;
                    sprmanage.spriteObject.transform.position = sprmanage.screenPos;
                    sprmanage.spriteObject.transform.localScale = sprmanage.spriteScale;
                    sprmanage.colliderObject.transform.position = sprmanage.physPos;
                    spawnedSprites.Add(sprobj);
                    spriteCounter++;
                }
            }
        }
        for(int i = 0; i < track.tStripList.Length; i++)
        {
            if(((distance + playMaster.spriteDrawDistance) >= track.tStripList[i].distance) && (distance < (track.tStripList[i].distance + track.tStripList[i].val.size.y + playMaster.spriteUnloadBehindDistance)))
            {
                TexturedStrip strip = track.tStripList[i].val;
                d = track.tStripList[i].distance;
                sidefactor = (strip.side == TexturedStrip.SpawnSide.BOTH) ? 2 : 1;
                TexturedStrip.SpawnSide currentTSpawnSide = (sidefactor == 2) ? TexturedStrip.SpawnSide.RIGHT : strip.side;
                for (int j = 0; j < sidefactor; j++)
                {
                    if (sidefactor == 2) currentTSpawnSide = (TexturedStrip.SpawnSide)((j+1) % 2);
                    GameObject stripObj = Instantiate<GameObject>(playMaster.stripPrefab, new Vector3(0f, 0f, 0f), Quaternion.identity, playMaster.gameObject.transform);
                    TexturedStripManager stripManager = stripObj.GetComponent<TexturedStripManager>();
                    stripManager.enabled = true;
                    stripManager.spline = playMaster.spline;
                    stripManager.InitStrip();
                    stripManager.tex = strip.texture;
                    stripManager.anchorSide = currentTSpawnSide;
                    stripManager.size = strip.size;
                    stripManager.baseDistance = d;
                    stripManager.xoffsList = strip.xOffsetList;
                    stripManager.ReassignTexture();
                    stripManager.PositionStrip(distance, xoffs);
                    spawnedStrips.Add(stripObj);
                }
            }
        }
    }

    private void DeletePreview() //Clean up is immensely important since previewing spawns a lot of new GameObjects in *project* space, so if they *aren't* cleaned up then you would have to manually delete them. Fun.
    {
        playMaster.spline.EditorPreviewDestroy();
        playMaster.paletteMat.EditorPreviewDestroy();
        playMaster.skyPal.EditorPreviewDestroy();
        playMaster.skyObj.GetComponent<MeshFilter>().mesh = null;
        playMaster.background1.transform.position = new Vector3(0f, 0f, 100f);
        playMaster.background2.transform.position = new Vector3(0f, 0f, 100.01f);
		playMaster.gameObject.SetActive(false);
        foreach(GameObject s in spawnedSprites)
        {
            GameObject.DestroyImmediate(s);
        }
        foreach(GameObject s in spawnedStrips)
        {
            GameObject.DestroyImmediate(s);
        }
    }

    void OnDestroy()
    {
        DeletePreview();
    }
}
