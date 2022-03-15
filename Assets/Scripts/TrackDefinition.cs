using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SplineTest
{
    [Serializable]
    public class ParameterChanger //Totally redundant
    {
        public enum ParameterType { TURNSTR, SPLITAMT, PITCHSTR, ROADPAL, SPRITE }
        public ParameterType type;
        public float distance;
        public float param;
        public Color32[] colours;
        public Sprite sprite;
    }
    
    [Serializable]
    public class ValueWithDistance<T> //Don't use this
    {
        public T val;
        public float distance;
    }
    //Only defined because Unity does not support serialising generic classes
    [Serializable]
    public class FloatWithDistance
    {
        public float val;
        public float distance;
    }

    [Serializable]
    public class ColourListWithDistance
    {
        public Color32[] val;
        public float distance;
    }

    [Serializable]
    public class MultiSpriteWithDistance
    {
        public MultiSprite val;
        public float distance;
    }

    [Serializable]
    public class BGSpriteDefWithDistance
    {
        public BackgroundSpriteDefinition val;
        public float distance;
    }
    
    [Serializable]
    public class MultiSprite
    {
        public enum SpawnSide { RIGHT, LEFT, BOTH }
        public StaticSpriteDef spriteDef;
        public SpawnSide side;
        public int numSpr;
        public float separation;
        public float xOffset;
        public float yOffset;
        public float baseScale;
        public bool flip;
        public bool flipOnOtherSide;
        public bool canCollide;
    }

    [Serializable]
    public class BackgroundSpriteDefinition
    {
        public Sprite bg1Sprite;
        public Sprite bg2Sprite;
        public Color32 spriteColour;
    }

    [CreateAssetMenu(fileName = "track", menuName = "Custom Assets/Track Definition", order = 1)]
    [PreferBinarySerialization] //yeah, what you gonna do about it?
    public class TrackDefinition : ScriptableObject
    {
        public string trackName;
        public string scoreFileName;
        public float endDistance;
        public float spriteSeparation;
        public float separationFactor;
        public float endScoreBonusFactor;
        public FloatWithDistance[] tTurnStrList;
        public FloatWithDistance[] tSplitAmtList;
        public FloatWithDistance[] tPitchStrList;
        public ColourListWithDistance[] tColourList;
        public MultiSpriteWithDistance[] tSpriteList;
        public BGSpriteDefWithDistance[] tBGList;
        public FloatWithDistance[] tTimeList;
    }
}