using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SplineTest
{
    public class MultiSpriteSpawnInfo
    {
        public MultiSprite refMultiSprite;
        public float nextSpriteSpawnDistance;
        public float lastSpriteSpawnDistance;
        public bool areSpritesLeftToSpawn;
        int nextSpriteNumber;
        int totalSprites;
        public MultiSpriteSpawnInfo(){}
        public MultiSpriteSpawnInfo(MultiSprite rMS, float dist)
        {
            refMultiSprite = rMS;
            nextSpriteSpawnDistance = dist;
            lastSpriteSpawnDistance = dist + (rMS.separation * (rMS.numSpr - 1));
            nextSpriteNumber = 0;
            totalSprites = rMS.numSpr;
            areSpritesLeftToSpawn = true;
        }

        public bool AdvanceSprite()
        {
            nextSpriteNumber++;
            if (nextSpriteNumber >= totalSprites)
            {
                areSpritesLeftToSpawn = false;
                return false;
            }
            nextSpriteSpawnDistance += refMultiSprite.separation;
            return true;
        }
    }

    public class SpriteManager : MonoBehaviour
    {
        public enum SpriteType { STATIC, DYNAMIC }
        public GameObject spriteObject;
        public GameObject colliderObject;
        public SpriteRenderer spriteRenderer;
        public BoxCollider collisionBox;
        public Vector3 screenPos; //Corresponds to the actual position according to Unity
        public Vector3 spriteScale;
        public Vector3 physPos; //Corresponds to the position according to game logic
        public float trueDistance;
        public float xOffset;
        public float yOffset;
        public float baseScale;
        public MultiSprite.SpawnSide anchorSide;
        public bool canCollide;
        public bool isBehindPlayer;
        public bool hasBeenGrazed; //no farming graze!!
        public SpriteType spriteType;

        void Awake()
        {
            spriteRenderer = spriteObject.GetComponent<SpriteRenderer>();
            collisionBox = colliderObject.GetComponent<BoxCollider>();
            screenPos = new Vector3(-1000f, -1000f, -1000f);
            spriteScale = new Vector3(0.1f, 0.1f, 0.1f);
            physPos = new Vector3(-1000f, -1000f, -1000f);
            spriteObject.transform.position = screenPos;
            spriteObject.transform.localScale = spriteScale;
            colliderObject.transform.position = physPos;
        }

        public void EditorPreviewInit() //EDITOR ONLY
        {
            Awake();
        }

        void Update() //These positions are controlled from above
        {
            spriteObject.transform.position = screenPos;
            spriteObject.transform.localScale = spriteScale;
            colliderObject.transform.position = physPos;
        }
    }
}