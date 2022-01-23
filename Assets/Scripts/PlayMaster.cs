using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;

namespace SplineTest
{
    public class PlayMaster : MonoBehaviour
    {
        public GameMaster gm;
        public GameObject playUIRoot;
        public SoundQueuer playerSounds;
        public SoundQueuer playerQuickSounds;
        TouchScreenKeyboard tsKeyboard;

        public TrackDefinition currentTrack;
        public SplineRenderer spline;
        public PalettisedMaterialHandler paletteMat;
        public PalettisedMaterialHandler skyPal;
        public Animator playerAnimator;
        public GameObject skyObj;
        public GameObject spritePrefab;
        public GameObject background1;
        public GameObject background2;
        public GameObject playerCollider;
        public GameObject HUDObject;
        public GameObject countdownObject;
        public GameObject startText;
        public GameObject checkPointIndicator;
        public GameObject offTrackIndicator;
        public GameObject pauseScreen;
        public GameObject backToGameButton;
        public GameObject quitToMenuButton;
        public GameObject gameOverText;
        public GameObject winText;
        public GameObject scoreEntryTop;
        public GameObject failHSTextObject;
        public GameObject scoreEntryObject;
        public GameObject nameEntryCursor;
        public GameObject characterMap;
        public GameObject switchExplanText;
        public GameObject directInputText;
        public GameObject gridInputText;
        public GameObject saveStatusText;
        public GameObject textCharacterPrefab;
        public GameObject imageCharacterPrefab;
        public Sprite[] specialChars;
        public HighScoreEntry newHSEntry;
        public Sprite[] dynamicSprites;
        public SpriteRenderer bg1sprrend;
        public SpriteRenderer bg2sprrend;
        public Text speedText;
        public Text grazeText;
        public Text scoreText;
        public Text progBarCurrentStageText;
        public Text progBarNextStageText;
        public Text checkPointTimeBonusText;
        public Image offTrackPointerImage;
        public Sprite leftPointer;
        public Sprite rightPointer;
        public RectTransform progBar;
        public RectTransform progBarGirl;
        public Text timeText;
        public Text stageText;
        public Text countdownText;
        public Text timeLeftText;
        public Text bonusMultiplierText;
        public PlayerInput pInput;
        public TouchButton accelTButton;
        public TouchButton brakeTButton;
        public TouchButton pauseTButton;
        public TouchSlider steerTSlider;
        public TouchButton acceptTButton;
        public TouchButton declineTButton;
        public TouchButton dpadUpTButton;
        public TouchButton dpadDownTButton;
        public TouchButton dpadLeftTButton;
        public TouchButton dpadRightTButton;
        public int roadParamsLookAhead;
        public int roadParamsKeepBehind;
        public float spriteDrawDistance;
        public float spriteUnloadBehindDistance;
        public float dynamicSpriteBaseSeparation;
        public float dynamicSpriteSeparationDecreaseFactor;
        public bool runTimer;
        
        public float time;
        public float distance;
        public uint displayScore;
        float score;
        float edgeGrazeMultiplier;
        float xoffs;
        float fspeed;
        float xspeed;
        float accelAmount;
        float brakeAmount;
        float turnxspeed;
        float centrifugalForce;
        float horizonHeight;
        float bg1TravelDist;
        float bg2TravelDist;
        public float accelPower;
        public float brakePower;
        public float turnPower;
        public float dragFactor;
        public float offRoadDragFactor;
        float currentDragFactor;
        float currentSplit;
        public float centrifugalFactor;
        public float bg1TravelFactor;
        public float bg2TravelFactor;
        float winScoreBonusPerSecondLeft;
        float stageStartDistance;
        float stageEndDistance;
        
        float[] mTurnStrList;
        float[] mTurnStrPoints;
        int mTurnStrLen;
        float[] mSplitAmtList;
        float[] mSplitAmtPoints;
        int mSplitAmtLen;
        float[] mPitchStrList;
        float[] mPitchStrPoints;
        int mPitchStrLen;
        Color32[][] mColourList;
        float[] mColourPoints;
        int mColourLen;
        MultiSprite[] mSpriteList;
        float[] mSpritePoints;
        int mSpriteLen;
        BackgroundSpriteDefinition[] mBGList;
        float[] mBGPoints;
        int mBGLen;
		int currentTurnStrPoint;
		int currentSplitAmtPoint;
		int currentPitchStrPoint;
		int currentColourPoint;
		int currentSpritePoint;
		int currentBGPoint;
        int startind;
        int currentind;
        int finind;
        int indlen;
        Color32[] colourInterp = new Color32[256];
        GameObject[] staticSpriteObjects = new GameObject[1024];
        SpriteManager[] staticSpriteManagers = new SpriteManager[1024];
        GameObject[] dynamicSpriteObjects = new GameObject[128];
        bool[] staticMultiSpriteIsLoaded = new bool[1024];
        bool[] staticMultiSpriteIsUnloaded = new bool[1024];
        int[] staticMultiSpriteStartRegion = new int[1024];
        MultiSpriteSpawnInfo[] staticMSSpawnInfos = new MultiSpriteSpawnInfo[64];
        bool[] dynamicSpriteIsLoaded = new bool[128];
        float[] dynamicSpriteDistance = new float[128];
        float[] dynamicSpriteXOff = new float[128];
        MultiSprite.SpawnSide[] dynamicSpriteSide = new MultiSprite.SpawnSide[128];
        int staticSpriteLoadNum;
        int staticSpriteUnloadNum;
        int staticSpriteCounter;
        int staticSpriteFirstLoaded;
        int staticSpriteNumberLoaded;
        int dynamicSpriteCounter;
        float nextDynamicSpriteSpawnDist;
        uint stageNum;
        int playUIState;
        float countdownTime;
        float timeToReturnToMenu;
        float timeLeftToAdd;
        HighScore newHighScoreEntry;
        int currentStringPosition;
        int currentNextDeletionPoint;
        bool isDirectInput;
        float ctrlSwitchDelayTimer;
        GameObject firstCharInCharGrid;
        bool hasTriggeredReturnToMenu;

        void LoadFromCurrentTrackDef()
        {
            dynamicSpriteBaseSeparation = currentTrack.spriteSeparation;
            dynamicSpriteSeparationDecreaseFactor = currentTrack.separationFactor;
            winScoreBonusPerSecondLeft = currentTrack.endScoreBonusFactor;
            mTurnStrList = new float[1024];
            mTurnStrPoints = new float[1024];
            mSplitAmtList = new float[1024];
            mSplitAmtPoints = new float[1024];
            mPitchStrList = new float[1024];
            mPitchStrPoints = new float[1024];
            mColourList = new Color32[128][];
            mColourPoints = new float[128];
            mSpriteList = new MultiSprite[1024];
            mSpritePoints = new float[1024];
            mBGList = new BackgroundSpriteDefinition[128];
            mBGPoints = new float[128];
            mTurnStrLen = currentTrack.tTurnStrList.Length;
            mSplitAmtLen = currentTrack.tSplitAmtList.Length;
            mPitchStrLen = currentTrack.tPitchStrList.Length;
            mColourLen = currentTrack.tColourList.Length;
            mSpriteLen = currentTrack.tSpriteList.Length;
            mBGLen = currentTrack.tBGList.Length;
            for(int i = 0; i < currentTrack.tTurnStrList.Length; i++)
            {
                mTurnStrList[i] = currentTrack.tTurnStrList[i].val;
                mTurnStrPoints[i] = currentTrack.tTurnStrList[i].distance;
            }
            for(int i = 0; i < currentTrack.tSplitAmtList.Length; i++)
            {
                mSplitAmtList[i] = currentTrack.tSplitAmtList[i].val;
                mSplitAmtPoints[i] = currentTrack.tSplitAmtList[i].distance;
            }
            for(int i = 0; i < currentTrack.tPitchStrList.Length; i++)
            {
                mPitchStrList[i] = currentTrack.tPitchStrList[i].val;
                mPitchStrPoints[i] = currentTrack.tPitchStrList[i].distance;
            }
            for(int i = 0; i < currentTrack.tColourList.Length; i++)
            {
                mColourList[i] = currentTrack.tColourList[i].val;
                mColourPoints[i] = currentTrack.tColourList[i].distance;
            }
            for(int i = 0; i < currentTrack.tSpriteList.Length; i++)
            {
                mSpriteList[i] = currentTrack.tSpriteList[i].val;
                mSpritePoints[i] = currentTrack.tSpriteList[i].distance;
            }
            for(int i = 0; i < currentTrack.tBGList.Length; i++)
            {
                mBGList[i] = currentTrack.tBGList[i].val;
                mBGPoints[i] = currentTrack.tBGList[i].distance;
            }
        }

        void SetUpSky()
        {
            MeshRenderer rendererS = skyObj.GetComponent<MeshRenderer>();
            MeshFilter filterS = skyObj.GetComponent<MeshFilter>();
            Texture textureS = rendererS.material.mainTexture;
            Mesh meshS = new Mesh();
            filterS.mesh = meshS;
            Vector3[] vertexS = new Vector3[]{new Vector3(0.0f, -256.0f, 0.0f), new Vector3(320.0f, -256.0f, 0.0f), new Vector3(320.0f, 512.0f, 0.0f), new Vector3(0.0f, 512.0f, 0.0f)};
            Vector2[] uvS = new Vector2[]{new Vector2(0.0f, -2.0f), new Vector2(320f/((float)textureS.width), -2.0f), new Vector2(320f/((float)textureS.width), 4.0f), new Vector2(0.0f, 4.0f)};
            int[] triS = new int[]{0,3,1,2,1,3};
            meshS.vertices = vertexS;
            meshS.uv = uvS;
            meshS.triangles = triS;
        }

        void Reset()
        {
            LoadFromCurrentTrackDef();
            playUIState = 0;
            distance = 0f;
            xoffs = 0f;
            fspeed = 0f;
            xspeed = 0f;
            time = currentTrack.tTimeList[0].val;
            countdownTime = 3.99f;
            score = 0f;
            edgeGrazeMultiplier = 1.00f;
            stageNum = 1;
            paletteMat.SetPalette(mColourList[0]);
            skyPal.SetPalette(mColourList[0]);
            startind  = 0;
            currentind = 0;
            finind = roadParamsLookAhead + currentind;
            countdownObject.SetActive(true);
            checkPointIndicator.SetActive(false);
            offTrackIndicator.SetActive(false);
            pauseScreen.SetActive(false);
            startText.SetActive(false);
            gameOverText.SetActive(false);
            winText.SetActive(false);
            if(finind >= mTurnStrLen)
            {
                finind = mTurnStrLen - 1;
            }
            indlen = finind - startind + 1;
            spline.turnStrList = new float[indlen+2];
            spline.turnStrPoints = new float[indlen+2];
            spline.turnStrList[0] = mTurnStrList[startind];
            spline.turnStrPoints[0] = mTurnStrPoints[startind];
            for(int i = 0; i <= indlen; i++)
            {
                if(i == indlen)
                {
                    spline.turnStrList[i+1] = mTurnStrList[i+startind-1];
                    spline.turnStrPoints[i+1] = 999999999f;
                }
                else
                {
                    spline.turnStrList[i+1] = mTurnStrList[i+startind];
                    spline.turnStrPoints[i+1] = mTurnStrPoints[i+startind];
                }
            }
            finind = roadParamsLookAhead + currentind;
            if(finind >= mSplitAmtLen)
            {
                finind = mSplitAmtLen - 1;
            }
            indlen = finind - startind + 1;
            spline.splitAmtList = new float[indlen+2];
            spline.splitAmtPoints = new float[indlen+2];
            spline.splitAmtList[0] = mSplitAmtList[startind];
            spline.splitAmtPoints[0] = mSplitAmtPoints[startind];
            for(int i = 0; i <= indlen; i++)
            {
                if(i == indlen)
                {
                    spline.splitAmtList[i+1] = mSplitAmtList[i+startind-1];
                    spline.splitAmtPoints[i+1] = 999999999f;
                }
                else
                {
                    spline.splitAmtList[i+1] = mSplitAmtList[i+startind];
                    spline.splitAmtPoints[i+1] = mSplitAmtPoints[i+startind];
                }
            }
            finind = roadParamsLookAhead + currentind;
            if(finind >= mPitchStrLen)
            {
                finind = mPitchStrLen - 1;
            }
            indlen = finind - startind + 1;
            spline.pitchStrList = new float[indlen+2];
            spline.pitchStrPoints = new float[indlen+2];
            spline.pitchStrList[0] = mPitchStrList[startind];
            spline.pitchStrPoints[0] = mPitchStrPoints[startind];
            for(int i = 0; i <= indlen; i++)
            {
                if(i == indlen)
                {
                    spline.pitchStrList[i+1] = mPitchStrList[i+startind-1];
                    spline.pitchStrPoints[i+1] = 999999999f;
                }
                else
                {
                    spline.pitchStrList[i+1] = mPitchStrList[i+startind];
                    spline.pitchStrPoints[i+1] = mPitchStrPoints[i+startind];
                }
            }
            bg1sprrend.sprite = mBGList[0].bg1Sprite;
            bg2sprrend.sprite = mBGList[0].bg2Sprite;
            bg1sprrend.color = mBGList[0].spriteColour;
            bg2sprrend.color = mBGList[0].spriteColour;
            bg1TravelDist = 0f;
            bg2TravelDist = 0f;
            foreach(GameObject gs in staticSpriteObjects)
            {
                if(gs != null)
                {
                    GameObject.Destroy(gs);
                }
            }
            foreach(GameObject gs in dynamicSpriteObjects)
            {
                if(gs != null)
                {
                    GameObject.Destroy(gs);
                }
            }
            staticSpriteObjects = new GameObject[1024];
            staticSpriteManagers = new SpriteManager[1024];
            dynamicSpriteObjects = new GameObject[128];
            dynamicSpriteIsLoaded = new bool[128];
            staticMultiSpriteIsLoaded = new bool[1024];
            staticMultiSpriteIsUnloaded = new bool[1024];
            staticMultiSpriteStartRegion = new int[1024];
            staticMSSpawnInfos = new MultiSpriteSpawnInfo[64];
            dynamicSpriteDistance = new float[128];
            dynamicSpriteXOff = new float[128];
            dynamicSpriteSide = new MultiSprite.SpawnSide[128];
            staticSpriteLoadNum = 0;
            staticSpriteUnloadNum = 0;
            staticSpriteCounter = 0;
            staticSpriteFirstLoaded = 0;
            staticSpriteNumberLoaded = 0;
            dynamicSpriteCounter = 0;
			currentTurnStrPoint = 0;
			currentSplitAmtPoint = 0;
			currentPitchStrPoint = 0;
			currentColourPoint = 0;
			currentSpritePoint = 0;
			currentBGPoint = 0;
            nextDynamicSpriteSpawnDist = 1500f;
			for(int i = 0; i < staticSpriteObjects.Length; i++)
			{
				staticSpriteObjects[i] = Instantiate<GameObject>(spritePrefab, new Vector3(0f, 0f, 0f), Quaternion.identity, this.gameObject.transform);
				staticSpriteManagers[i] = staticSpriteObjects[i].GetComponent<SpriteManager>();
				staticSpriteManagers[i].enabled = false;
			}
            for(int i = 0; i < mSpriteLen; i++)
            {
                if((distance + spriteDrawDistance) >= mSpritePoints[i])
                {
					LoadNewStaticSpriteGroup(i);
					currentSpritePoint++;
                }
            }
            playerSounds.Play(0, true);
            stageStartDistance = 0f;
            stageEndDistance = (currentTrack.tTimeList.Length == 1)?currentTrack.endDistance:currentTrack.tTimeList[1].distance;
        }

        void Start()
        {
            playerCollider.GetComponent<PlayerColliderControl>().master = this;
        }

        public void SetUp(int songNum)
        {
            pInput.SwitchCurrentActionMap("Playtime");
            playerCollider.GetComponent<PlayerColliderControl>().master = this;
            playUIRoot.SetActive(true);
            HUDObject.SetActive(true);
            steerTSlider.ForceBoundsUpdate();
            gm.BTMSource.PlaySong(songNum);
            Reset();
            SetUpSky();
        }

        public void ExitPlayTime()
        {
            failHSTextObject.SetActive(false);
            scoreEntryObject.SetActive(false);
            scoreEntryTop.SetActive(false);
            playUIRoot.SetActive(false);
            gm.BTMSource.StopSong();
            gm.BTMSource.SetSongVolume(1.0f);
			for(int i = 0; i < staticSpriteObjects.Length; i++)
			{
				staticSpriteManagers[i] = null;
				GameObject.Destroy(staticSpriteObjects[i]);
			}
            gm.ReturnToMainMenu();
        }

        public void StaticSpriteCollision()
        {
            playerQuickSounds.PlayOneShot(0);
            fspeed = 0f;
            xspeed = 0f;
            distance -= 2f;
            bg1TravelDist += turnxspeed*2f*bg1TravelFactor;
            bg2TravelDist += turnxspeed*2f*bg2TravelFactor;
            bg1TravelDist %= 512f;
            bg2TravelDist %= 512f;
        }

        public void DynamicSpriteCollision()
        {
            playerQuickSounds.PlayOneShot(0);
            fspeed = 540f;
        }

        void LoadNewStaticSpriteGroup(int sprNumber)
        {
            MultiSprite thisSpr = mSpriteList[sprNumber];
            float d = mSpritePoints[sprNumber];
            staticMSSpawnInfos[staticSpriteLoadNum%staticMSSpawnInfos.Length] = new MultiSpriteSpawnInfo(thisSpr, d);
            SpriteManager sprmanage;
            GameObject sprobj;
            int sidefactor = (thisSpr.side == MultiSprite.SpawnSide.BOTH) ? 2 : 1;
            MultiSprite.SpawnSide currentSpawnSide = (sidefactor == 2) ? MultiSprite.SpawnSide.RIGHT : thisSpr.side;
            float realDist = -1000f;
            float realXOff = 1000f;
            for(int i = 0; i < sidefactor; i++)
            {
                if (sidefactor == 2) currentSpawnSide = (MultiSprite.SpawnSide)((i+1) % 2);
                realDist = d;
                realXOff = spline.GetRealXOff(thisSpr.xOffset, realDist, currentSpawnSide);
				sprobj = staticSpriteObjects[(staticSpriteCounter + i) % staticSpriteObjects.Length];
				sprmanage = staticSpriteManagers[(staticSpriteCounter + i) % staticSpriteObjects.Length];
				sprmanage.enabled = true;
                sprmanage.physPos = new Vector3(realXOff, thisSpr.collisionBounds.y / 2f, realDist - distance);
                sprmanage.spriteRenderer.sprite = thisSpr.sprite;
                sprmanage.spriteRenderer.flipX = (sidefactor == 2) ? (thisSpr.flip ^ (thisSpr.flipOnOtherSide && ((i % 2) == 1))) : thisSpr.flip;
                sprmanage.screenPos = spline.GetScreenPos(realDist, realXOff, thisSpr.yOffset);
                sprmanage.spriteScale = Vector3.one * spline.GetScale(realDist) / thisSpr.baseScale;
                sprmanage.collisionBox.size = thisSpr.collisionBounds;
                sprmanage.spriteType = SpriteManager.SpriteType.STATIC;
                sprmanage.canCollide = thisSpr.canCollide;
                sprmanage.trueDistance = d;
                sprmanage.xOffset = thisSpr.xOffset;
                sprmanage.yOffset = thisSpr.yOffset;
                sprmanage.anchorSide = currentSpawnSide;
                sprmanage.baseScale = thisSpr.baseScale;
                staticSpriteObjects[(staticSpriteCounter + i) % staticSpriteObjects.Length] = sprobj;
                staticSpriteManagers[(staticSpriteCounter + i) % staticSpriteObjects.Length] = sprmanage;
            }
            staticMultiSpriteIsLoaded[sprNumber] = true;
            staticSpriteCounter += sidefactor;
            staticSpriteNumberLoaded += sidefactor;
            staticSpriteLoadNum++;
        }

        void LoadNextStaticSpriteInGroup(int grpNumber)
        {
            MultiSpriteSpawnInfo msSpawnInfo = staticMSSpawnInfos[grpNumber];
            if (!msSpawnInfo.AdvanceSprite()) return;
            MultiSprite thisSpr = msSpawnInfo.refMultiSprite;
            float d = msSpawnInfo.nextSpriteSpawnDistance;
            SpriteManager sprmanage;
            GameObject sprobj;
            int sidefactor = (thisSpr.side == MultiSprite.SpawnSide.BOTH) ? 2 : 1;
            MultiSprite.SpawnSide currentSpawnSide = (sidefactor == 2) ? MultiSprite.SpawnSide.RIGHT : thisSpr.side;
            float realDist = -1000f;
            float realXOff = 1000f;
            for (int i = 0; i < sidefactor; i++)
            {
                if (sidefactor == 2) currentSpawnSide = (MultiSprite.SpawnSide)((i+1) % 2);
                realDist = d;
                realXOff = spline.GetRealXOff(thisSpr.xOffset, realDist, currentSpawnSide);
				sprobj = staticSpriteObjects[(staticSpriteCounter + i) % staticSpriteObjects.Length];
				sprmanage = staticSpriteManagers[(staticSpriteCounter + i) % staticSpriteObjects.Length];
				sprmanage.enabled = true;
                sprmanage.physPos = new Vector3(realXOff, thisSpr.collisionBounds.y / 2f, realDist - distance);
                sprmanage.spriteRenderer.sprite = thisSpr.sprite;
                sprmanage.spriteRenderer.flipX = (sidefactor == 2) ? (thisSpr.flip ^ (thisSpr.flipOnOtherSide && ((i % 2) == 1))) : thisSpr.flip;
                sprmanage.screenPos = spline.GetScreenPos(realDist, realXOff, thisSpr.yOffset);
                sprmanage.spriteScale = Vector3.one * spline.GetScale(realDist) / thisSpr.baseScale;
                sprmanage.collisionBox.size = thisSpr.collisionBounds;
                sprmanage.spriteType = SpriteManager.SpriteType.STATIC;
                sprmanage.canCollide = thisSpr.canCollide;
                sprmanage.trueDistance = d;
                sprmanage.xOffset = thisSpr.xOffset;
                sprmanage.yOffset = thisSpr.yOffset;
                sprmanage.anchorSide = currentSpawnSide;
                sprmanage.baseScale = thisSpr.baseScale;
                staticSpriteObjects[(staticSpriteCounter + i) % staticSpriteObjects.Length] = sprobj;
                staticSpriteManagers[(staticSpriteCounter + i) % staticSpriteObjects.Length] = sprmanage;
            }
            staticSpriteCounter += sidefactor;
            staticSpriteNumberLoaded += sidefactor;
        }

        void UpdateStaticSprites()
        {
            SpriteManager sprmanage;
            float realDist = -1000f;
            float realXOff = 1000f;
            for(int i = staticSpriteFirstLoaded; i < (staticSpriteNumberLoaded+staticSpriteFirstLoaded); i++)
            {
                sprmanage = staticSpriteManagers[i % staticSpriteObjects.Length];
                realDist = sprmanage.trueDistance;
                realXOff = spline.GetRealXOff(sprmanage.xOffset, realDist, sprmanage.anchorSide);
                sprmanage.physPos = new Vector3(realXOff, sprmanage.collisionBox.bounds.size.y / 2f + sprmanage.yOffset, realDist - distance);
                sprmanage.screenPos = spline.GetScreenPos(realDist, realXOff, sprmanage.yOffset);
                sprmanage.spriteScale = Vector3.one * spline.GetScale(realDist) / sprmanage.baseScale;
            }
        }

        void UnloadNextStaticSprites()
        {
            while(staticSpriteManagers[staticSpriteFirstLoaded].trueDistance < distance - spriteUnloadBehindDistance)
            {

				staticSpriteManagers[staticSpriteFirstLoaded].physPos = new Vector3(0f,0f,-2000f);
				staticSpriteManagers[staticSpriteFirstLoaded].enabled = false;
                staticSpriteFirstLoaded++;
                staticSpriteNumberLoaded--;
                staticSpriteFirstLoaded %= staticSpriteObjects.Length;
                if (staticSpriteNumberLoaded <= 0) return;
            }
        }

        void UnloadStaticSpriteGroup(int grpNumber)
        {
            staticMSSpawnInfos[grpNumber] = null;
        }

        void LoadDynamicSprite()
        {
            SpriteManager sprmanage;
            GameObject sprobj;
            MultiSprite.SpawnSide anchorSide = (UnityEngine.Random.value > 0.5)?MultiSprite.SpawnSide.LEFT:MultiSprite.SpawnSide.RIGHT;
            float laneOffset = (float)UnityEngine.Random.Range((int)0, (int)3);
            float realDist = distance + spriteDrawDistance;
            float realXOff = spline.GetRealXOff(-32f - 32*laneOffset, realDist, anchorSide);
            float realScale = spline.GetScale(realDist)/4f;
            dynamicSpriteDistance[dynamicSpriteCounter%dynamicSpriteObjects.Length] = realDist;
            dynamicSpriteXOff[dynamicSpriteCounter%dynamicSpriteObjects.Length] = -32f - 32*laneOffset;
            dynamicSpriteSide[dynamicSpriteCounter%dynamicSpriteObjects.Length] = anchorSide;
            sprobj = Instantiate<GameObject>(spritePrefab, new Vector3(0f,0f,0f), Quaternion.identity, this.gameObject.transform);
            sprmanage = sprobj.GetComponent<SpriteManager>();
            sprmanage.physPos = new Vector3(realXOff, 8f, realDist - distance);
            sprmanage.spriteRenderer.sprite = dynamicSprites[UnityEngine.Random.Range((int)0, dynamicSprites.Length)];
            sprmanage.screenPos = spline.GetScreenPos(realDist, realXOff, 0f) + new Vector3(0f, 8f, 0f)*realScale;
            sprmanage.spriteScale = Vector3.one*realScale;
            sprmanage.collisionBox.size = new Vector3(8f, 16f, 8f);
            sprmanage.spriteType = SpriteManager.SpriteType.DYNAMIC;
            sprmanage.canCollide = true;
            sprmanage.isBehindPlayer = false;
            sprmanage.hasBeenGrazed = false;
            dynamicSpriteObjects[dynamicSpriteCounter%dynamicSpriteObjects.Length] = sprobj;
            dynamicSpriteIsLoaded[dynamicSpriteCounter%dynamicSpriteObjects.Length] = true;
            dynamicSpriteCounter++;
        }

        void UpdateDynamicSprites()
        {
            SpriteManager sprmanage;
            GameObject sprobj;
            float realDist = -1000f;
            float realXOff = 1000f;
            float realScale = 1f;
            float flybyVolume = 0f;
            for(int i = 0; i < dynamicSpriteObjects.Length; i++)
            {
                if(!dynamicSpriteIsLoaded[i])
                {
                    continue;
                }
                realDist = dynamicSpriteDistance[i];
                realXOff = spline.GetRealXOff(dynamicSpriteXOff[i], realDist, dynamicSpriteSide[i]);
                realScale = spline.GetScale(realDist)/4f;
                sprobj = dynamicSpriteObjects[i%dynamicSpriteObjects.Length];
                sprmanage = sprobj.GetComponent<SpriteManager>();
                sprmanage.physPos = new Vector3(realXOff, 8f, realDist - distance);
                sprmanage.screenPos = spline.GetScreenPos(realDist, realXOff, 0f) + new Vector3(0f, 8f, 0f)*realScale;
                sprmanage.spriteScale = Vector3.one*realScale;
                if(sprmanage.physPos.z <= 0f && !sprmanage.isBehindPlayer)
                {
                    sprmanage.isBehindPlayer = true;
                    if (Mathf.Abs(realXOff - xoffs) <= 24f && !sprmanage.hasBeenGrazed && playUIState == 1)
                    {
                        score += (fspeed - 600f)*Mathf.Exp(-Mathf.Abs(realXOff - xoffs)*0.25f)*(Mathf.Abs(turnxspeed)*Mathf.Abs(turnxspeed)*2000000f + 0.1f)*1500f;
                        sprmanage.hasBeenGrazed = true;
                    }
                    flybyVolume = Mathf.Exp(-Mathf.Abs(realXOff - xoffs)*0.06f)*2f;
                    playerQuickSounds.PlayOneShotVariableVolume(1, flybyVolume);
                }
                else if(sprmanage.physPos.z > 0f && sprmanage.isBehindPlayer)
                {
                    sprmanage.isBehindPlayer = false;
                }
                if(playUIState != 2) dynamicSpriteDistance[i] += 600f*Time.deltaTime;
            }
        }

        void UnloadDynamicSprite(int sprNumber)
        {
            GameObject.Destroy(dynamicSpriteObjects[sprNumber]);
            dynamicSpriteIsLoaded[sprNumber] = false;
        }

        public void EnterChar(int charnum)
        {
            StringBuilder compString = new StringBuilder(newHSEntry.nameText.text);
            compString[currentStringPosition] = Char.ConvertFromUtf32(charnum + 0xA0)[0];
            newHSEntry.nameText.text = compString.ToString();
            if(currentStringPosition < 13) currentStringPosition++;
            if(currentNextDeletionPoint < 13) currentNextDeletionPoint++;
            nameEntryCursor.GetComponent<RectTransform>().anchoredPosition = new Vector2(8f + 8f*(currentStringPosition), -64f);
        }

        void DidGetOnLeaderBoard()
        {
            float realTime = -time;
            for(uint i = 0; i < stageNum; i++)
            {
                realTime += currentTrack.tTimeList[i].val;
            }
            newHighScoreEntry = new HighScore("              ", displayScore, stageNum, realTime);
            gameOverText.SetActive(false);
            winText.SetActive(false);
            HUDObject.SetActive(false);
            scoreEntryTop.SetActive(true);
            if(gm.scoreGroups[gm.currentTrackNum].CanAddEntry(newHighScoreEntry))
            {
                gm.BTMSource.PlaySong(7);
                scoreEntryObject.SetActive(true);
                characterMap.SetActive(true);
                switchExplanText.SetActive(true);
                directInputText.SetActive(true);
                gridInputText.SetActive(false);
                saveStatusText.SetActive(false);
                playUIState = 6;
                newHSEntry.SetUpEntry(newHighScoreEntry);
                currentStringPosition = 0;
                currentNextDeletionPoint = -1;
                nameEntryCursor.GetComponent<RectTransform>().anchoredPosition = new Vector2(8f, -64f);
                ConstructCharacterEntry();
                isDirectInput = true;
#if UNITY_ANDROID
                tsKeyboard = TouchScreenKeyboard.Open("", TouchScreenKeyboardType.Default, false);
#elif UNITY_IOS
                tsKeyboard = TouchScreenKeyboard.Open("", TouchScreenKeyboardType.Default, false);
#endif
                Keyboard.current.onTextInput += OnTextInput;
            }
            else
            {
                failHSTextObject.SetActive(true);
                playUIState = 5;
                timeToReturnToMenu = 7.0f;
            }
        }

        void ConstructCharacterEntry()
        {
            GameObject currentCharObject;
            Button[] charButtons;
            Button currentCharButton;
            Navigation charNav;
            SendCharacterInfo charInfo;
            for(int i = 0; i < 96; i++)
            {
                switch(i)
                {
                    case 0:
                        currentCharObject = GameObject.Instantiate(imageCharacterPrefab, new Vector3(96f, 96f, -100f), Quaternion.identity, characterMap.transform);
                        currentCharObject.GetComponent<Image>().sprite = specialChars[2];
                        break;
                    default:
                        currentCharObject = GameObject.Instantiate(textCharacterPrefab, new Vector3(96f + (i%16)*8f, 96f - (i/16)*8f, -100f), Quaternion.identity, characterMap.transform);
                        currentCharObject.GetComponent<Text>().text = Char.ConvertFromUtf32(i + 0xA0);
                        break;
                }
            }
            charButtons = characterMap.GetComponentsInChildren<Button>();
            for(int i = 0; i < 96; i++)
            {
                currentCharButton = charButtons[i];
                charNav = new Navigation();
                charNav.mode = Navigation.Mode.Explicit;
                charNav.selectOnRight = charButtons[(i == 95)?0:i+1];
                charNav.selectOnLeft = charButtons[(i == 0)?95:i-1];
                charNav.selectOnDown = charButtons[((i/16) >= 5)?i%16:i+16];
                charNav.selectOnUp = charButtons[((i/16) == 0)?i+80:i-16];
                currentCharButton.navigation = charNav;
                charInfo = currentCharButton.gameObject.GetComponent<SendCharacterInfo>();
                charInfo.pm = this;
                charInfo.charNum = i;
            }
            firstCharInCharGrid = charButtons[0].gameObject;
        }

        void DestroyCharacterEntry()
        {
            Button[] charButtons = characterMap.GetComponentsInChildren<Button>();
            for(int i = 0; i < 96; i++)
            {
                GameObject.Destroy(charButtons[i].gameObject);
            }
        }

        void OnTextInput(char Ch)
        {
            StringBuilder compString = new StringBuilder(newHSEntry.nameText.text);
            if ((int)Ch == 8)
            {
                compString[currentNextDeletionPoint < 0 ? 0 : currentNextDeletionPoint] = Char.ConvertFromUtf32(0x20)[0];
                newHSEntry.nameText.text = compString.ToString();
                if (currentStringPosition > 0 && currentNextDeletionPoint < 13) currentStringPosition--;
                if (currentNextDeletionPoint > -1) currentNextDeletionPoint--;
            }
            else if ((int)Ch == 13)
            {
                OnTextInputDone();
            }
            else
            {
                compString[currentStringPosition] = Ch;
                newHSEntry.nameText.text = compString.ToString();
                if (currentStringPosition < 13) currentStringPosition++;
                if (currentNextDeletionPoint < 13) currentNextDeletionPoint++;
            }
            nameEntryCursor.GetComponent<RectTransform>().anchoredPosition = new Vector2(8f + 8f * (currentStringPosition), -64f);
        }

        void OnTextInputDone()
        {
            newHighScoreEntry.UpdateName(newHSEntry.nameText.text);
            gm.scoreGroups[gm.currentTrackNum].AddEntry(newHighScoreEntry);
            gm.scoreGroups[gm.currentTrackNum].WriteScoreDataToFile(gm.appBaseDirectory + HighScoreGroup.scorefileDirectory + currentTrack.scoreFileName + HighScoreGroup.scorefileExtension);
            gm.WriteConfig();
            playUIState = 5;
            DestroyCharacterEntry();
            switchExplanText.SetActive(false);
            directInputText.SetActive(false);
            gridInputText.SetActive(false);
            saveStatusText.SetActive(true);
            timeToReturnToMenu = 3.0f;
            Keyboard.current.onTextInput -= OnTextInput;
        }

        public void ReturnFromPaused()
        {
            playUIState = 1;
            pauseScreen.SetActive(false);
#if UNITY_ANDROID
            gm.menuTouchControls.SetActive(false);
            gm.playTouchControls.SetActive(true);
#elif UNITY_IOS
            gm.menuTouchControls.SetActive(false);
            gm.playTouchControls.SetActive(true);
#endif
            pInput.SwitchCurrentActionMap("Playtime");
        }

        public void QuitToMenuFromPaused()
        {
            StartCoroutine(gm.BTMSource.SongFade(1.5f));
            StartCoroutine(gm.DoFadeAndFunction(ExitPlayTime, gm.menuMaster.GetComponent<MenuMaster>().startButton, 0.25f, 1f, 1f));
        }

        IEnumerator CheckpointIndicatorSpawnAndRemoval()
        {
            checkPointIndicator.SetActive(true);
            checkPointTimeBonusText.text = ((int)(currentTrack.tTimeList[stageNum - 1].val)).ToString();
            playerQuickSounds.PlayOneShot(2);
            yield return new WaitForSecondsRealtime(3f);
            checkPointIndicator.SetActive(false);
            yield break;
        }
        
        IEnumerator WinAnimation()
        {
            float timeLeftForPhase = 4f;
            float endXoffs = xoffs;
            timeToReturnToMenu = 11f;
            int phase = 0;
            while(true)
            {
                timeLeftForPhase -= Time.deltaTime;
                if(playUIState != 3) timeToReturnToMenu -= Time.deltaTime;
                switch(phase)
                {
                    case 0:
                        fspeed = 450f;
                        distance += fspeed * Time.deltaTime;
                        xoffs = Mathf.Lerp(endXoffs, -currentSplit, 1f - timeLeftForPhase*0.25f);
                        if(timeLeftForPhase <= 0f)
                        {
                            phase++;
                            timeLeftForPhase += 2f;
                        }
                        break;
                    case 1:
                        fspeed = 225f*timeLeftForPhase;
                        distance += fspeed * Time.deltaTime;
                        xoffs = -currentSplit;
                        if(timeLeftForPhase <= 0f)
                        {
                            phase++;
                            timeLeftForPhase += 5f;
                        }
                        break;
                    case 2:
                        fspeed = 0f;
                        distance = currentTrack.endDistance + 2250f;
                        xoffs = -currentSplit;
                        if(timeLeftForPhase <= 0f)
                        {
                            yield break;
                        }
                        break;
                }
                bg1TravelDist -= turnxspeed * fspeed * bg1TravelFactor * Time.deltaTime;
                bg2TravelDist -= turnxspeed * fspeed * bg2TravelFactor * Time.deltaTime;
                bg1TravelDist %= 512f;
                bg2TravelDist %= 512f;
                playerAnimator.SetFloat("speed", fspeed*0.002f);
                playerAnimator.SetFloat("turnStrength", 0f);
                yield return null;
            }
        }

        void Update()
        {
            if(stageNum >= (uint)currentTrack.tTimeList.Length)
            {

            }
            else if(distance >= currentTrack.tTimeList[stageNum].distance)
            {
                time += currentTrack.tTimeList[stageNum].val;
                score += 200000f;
                stageNum++;
                dynamicSpriteBaseSeparation *= dynamicSpriteSeparationDecreaseFactor;
                stageStartDistance = currentTrack.tTimeList[stageNum-1].distance;
                stageEndDistance = (stageNum >= (uint)currentTrack.tTimeList.Length)?currentTrack.endDistance:currentTrack.tTimeList[stageNum].distance;
                StartCoroutine(CheckpointIndicatorSpawnAndRemoval());
            }
			if(currentTurnStrPoint <= 0)
			{
				turnxspeed = Mathf.Lerp(mTurnStrList[0], mTurnStrList[1], (distance-mTurnStrPoints[0])/(mTurnStrPoints[1]-mTurnStrPoints[0]));
			}
			else
			{
				turnxspeed = Mathf.Lerp(mTurnStrList[currentTurnStrPoint-1], mTurnStrList[currentTurnStrPoint], (distance-mTurnStrPoints[currentTurnStrPoint-1])/(mTurnStrPoints[currentTurnStrPoint]-mTurnStrPoints[currentTurnStrPoint-1]));
			}
			if(currentSplitAmtPoint <= 0)
			{
				currentSplit = Mathf.Lerp(mSplitAmtList[0], mSplitAmtList[1], (distance-mSplitAmtPoints[0])/(mSplitAmtPoints[1]-mSplitAmtPoints[0]));
			}
			else
			{
				currentSplit = Mathf.Lerp(mSplitAmtList[currentSplitAmtPoint-1], mSplitAmtList[currentSplitAmtPoint], (distance-mSplitAmtPoints[currentSplitAmtPoint-1])/(mSplitAmtPoints[currentSplitAmtPoint]-mSplitAmtPoints[currentSplitAmtPoint-1]));
			}
            if(xoffs <= -32f - currentSplit)
            {
                edgeGrazeMultiplier = 1.00f + (Mathf.Exp((-xoffs - 56f - currentSplit) * 0.125f) * Mathf.Abs(centrifugalForce) * 0.05f);
            }
            else if(xoffs >= 32f + currentSplit)
            {
                edgeGrazeMultiplier = 1.00f + (Mathf.Exp((xoffs - 56f - currentSplit) * 0.125f) * Mathf.Abs(centrifugalForce) * 0.05f);
            }
            else if(currentSplit >= 56f)
            {
                if(xoffs <= -32f + currentSplit && xoffs > 0f)
                {
                    edgeGrazeMultiplier = 1.00f + (Mathf.Exp((-xoffs - 56f + currentSplit) * 0.125f) * Mathf.Abs(centrifugalForce) * 0.05f);
                }
                else if (xoffs >= 32f - currentSplit && xoffs < 0f)
                {
                    edgeGrazeMultiplier = 1.00f + (Mathf.Exp((xoffs - 56f + currentSplit) * 0.125f) * Mathf.Abs(centrifugalForce) * 0.05f);
                }
                else
                {
                    edgeGrazeMultiplier = 1.00f;
                }
            }
            else
            {
                edgeGrazeMultiplier = 1.00f;
            }
            if(xoffs >= -56f - currentSplit && xoffs <= 56f + currentSplit)
            {
                if(xoffs <= 56f - currentSplit || xoffs >= -56f + currentSplit)
                {
                    currentDragFactor = dragFactor;
                }
                else
                {
                    currentDragFactor = offRoadDragFactor;
                    edgeGrazeMultiplier = 1.00f;
                }
            }
            else
            {
                currentDragFactor = offRoadDragFactor;
                edgeGrazeMultiplier = 1.00f;
            }
            if(xoffs <= -128f - currentSplit)
            {
                offTrackIndicator.SetActive(true);
                offTrackPointerImage.sprite = rightPointer;
            }
            else if (xoffs >= 128f + currentSplit)
            {
                offTrackIndicator.SetActive(true);
                offTrackPointerImage.sprite = leftPointer;
            }
            else
            {
                offTrackIndicator.SetActive(false);
            }
            switch (playUIState)
            {
                case 0: //Counting down to start
                    countdownTime -= Time.deltaTime;
                    if (countdownTime <= 1f)
                    {
                        countdownObject.SetActive(false);
                        startText.SetActive(true);
                    }
                    if (countdownTime <= 0f)
                    {
                        startText.SetActive(false);
                        playUIState = 1;
                    }
                    countdownText.text = ((int)countdownTime).ToString();
                    break;
                case 1: //During play
                    time -= Time.deltaTime;
                    if (((time >= 0f) || !runTimer))
                    {
#if UNITY_EDITOR
                        accelAmount = pInput.currentActionMap.FindAction("Accelerate").ReadValue<float>();
                        brakeAmount = pInput.currentActionMap.FindAction("Brake").ReadValue<float>();
#elif UNITY_STANDALONE
                        accelAmount = pInput.currentActionMap.FindAction("Accelerate").ReadValue<float>();
                        brakeAmount = pInput.currentActionMap.FindAction("Brake").ReadValue<float>();
#elif UNITY_ANDROID
                        accelAmount = accelTButton.isTouching ? 1f : 0f;
                        brakeAmount = brakeTButton.isTouching ? 1f : 0f;
#elif UNITY_IOS
                        accelAmount = accelTButton.isTouching ? 1f : 0f;
                        brakeAmount = brakeTButton.isTouching ? 1f : 0f;
#endif
                    }
                    else if (((time < 0f) && runTimer))
                    {
                        accelAmount = 0f;
                        brakeAmount = 1f;
                    }
                    fspeed += (accelAmount * accelPower - brakeAmount * brakePower) * Time.deltaTime;
                    if (fspeed <= 0.0f) fspeed = 0.0f;
#if UNITY_EDITOR
                    xspeed = pInput.currentActionMap.FindAction("Steer").ReadValue<float>() * turnPower;
#elif UNITY_STANDALONE
                    xspeed = pInput.currentActionMap.FindAction("Steer").ReadValue<float>() * turnPower;
#elif UNITY_ANDROID
                    xspeed = steerTSlider.value * turnPower;
#elif UNITY_IOS
                    xspeed = steerTSlider.value * turnPower;
#endif
                    centrifugalForce = -centrifugalFactor * fspeed * fspeed * turnxspeed;
                    xoffs += xspeed * Time.deltaTime + centrifugalForce * Time.deltaTime;
                    score += Mathf.Pow(fspeed, 1.4f) * edgeGrazeMultiplier * Time.deltaTime;
                    distance += fspeed * Time.deltaTime;
                    fspeed -= Time.deltaTime * currentDragFactor * fspeed * fspeed * (fspeed > 0 ? 1 : -1);
                    bg1TravelDist -= turnxspeed * fspeed * bg1TravelFactor * Time.deltaTime;
                    bg2TravelDist -= turnxspeed * fspeed * bg2TravelFactor * Time.deltaTime;
                    bg1TravelDist %= 512f;
                    bg2TravelDist %= 512f;
                    if (pInput.currentActionMap.FindAction("Pause").triggered || pauseTButton.isDown)
                    {
                        playUIState = 2;
                        pauseScreen.SetActive(true);
#if UNITY_ANDROID
                        gm.playTouchControls.SetActive(false);
                        gm.menuTouchControls.SetActive(true);
#elif UNITY_IOS
                        gm.playTouchControls.SetActive(false);
                        gm.menuTouchControls.SetActive(true);
#endif
                        gm.menuMaster.GetComponent<MenuMaster>().eventSystem.SetSelectedGameObject(backToGameButton);
                        pInput.SwitchCurrentActionMap("Menu");
                    }
                    playerAnimator.SetFloat("speed", fspeed*0.002f);
                    playerAnimator.SetFloat("turnStrength", xspeed/turnPower);
                    break;
                case 2: //Paused
                    if(pInput.currentActionMap.FindAction("Decline").triggered || declineTButton.isDown)
                    {
                        playUIState = 1;
                        pauseScreen.SetActive(false);
#if UNITY_ANDROID
                        gm.menuTouchControls.SetActive(false);
                        gm.playTouchControls.SetActive(true);
#elif UNITY_IOS
                        gm.menuTouchControls.SetActive(false);
                        gm.playTouchControls.SetActive(true);
#endif
                        pInput.SwitchCurrentActionMap("Playtime");
                    }
#if UNITY_ANDROID
                    else if(acceptTButton.isDown)
                    {
                        gm.menuMaster.GetComponent<MenuMaster>().eventSystem.currentSelectedGameObject.GetComponent<Button>().OnSubmit(null);
                    }
                    else if(dpadUpTButton.isDown)
                    {
                        gm.menuMaster.GetComponent<MenuMaster>().eventSystem.SetSelectedGameObject(gm.menuMaster.GetComponent<MenuMaster>().eventSystem.currentSelectedGameObject.GetComponent<Selectable>().FindSelectableOnUp().gameObject);
                    }
                    else if(dpadDownTButton.isDown)
                    {
                        gm.menuMaster.GetComponent<MenuMaster>().eventSystem.SetSelectedGameObject(gm.menuMaster.GetComponent<MenuMaster>().eventSystem.currentSelectedGameObject.GetComponent<Selectable>().FindSelectableOnDown().gameObject);
                    }
#elif UNITY_IOS
                    else if(acceptTButton.isDown)
                    {
                        gm.menuMaster.GetComponent<MenuMaster>().eventSystem.currentSelectedGameObject.GetComponent<Button>().OnSubmit(null);
                    }
                    else if(dpadUpTButton.isDown)
                    {
                        gm.menuMaster.GetComponent<MenuMaster>().eventSystem.SetSelectedGameObject(gm.menuMaster.GetComponent<MenuMaster>().eventSystem.currentSelectedGameObject.GetComponent<Selectable>().FindSelectableOnUp().gameObject);
                    }
                    else if(dpadDownTButton.isDown)
                    {
                        gm.menuMaster.GetComponent<MenuMaster>().eventSystem.SetSelectedGameObject(gm.menuMaster.GetComponent<MenuMaster>().eventSystem.currentSelectedGameObject.GetComponent<Selectable>().FindSelectableOnDown().gameObject);
                    }
#endif
                    break;
                case 3: //Transitioning to the score entry screen
                    timeToReturnToMenu -= Time.deltaTime;
                    if (timeToReturnToMenu <= 0.0f)
                    {
                        pInput.SwitchCurrentActionMap("Menu");
                        hasTriggeredReturnToMenu = false;
                        DidGetOnLeaderBoard();
                    }
                    break;
                case 4: //Win
                    if (timeLeftToAdd <= 0.0f)
                    {
                        score += timeLeftToAdd * winScoreBonusPerSecondLeft;
                        timeLeftText.text = "0";
                        playUIState = 3;
                    }
                    else
                    {
                        timeLeftToAdd -= Time.deltaTime * 10f;
                        score += winScoreBonusPerSecondLeft * Time.deltaTime * 10f;
                        timeLeftText.text = ((int)timeLeftToAdd).ToString();
                    }
                    break;
                case 5: //Returning to menu
                    timeToReturnToMenu -= Time.deltaTime;
                    if (timeToReturnToMenu <= 0.0f && !hasTriggeredReturnToMenu)
                    {
                        StartCoroutine(gm.BTMSource.SongFade(1.5f));
                        StartCoroutine(gm.DoFadeAndFunction(ExitPlayTime, gm.menuMaster.GetComponentInChildren<MenuMaster>().startButton, 0.25f, 1f, 1f));
                        hasTriggeredReturnToMenu = true;
                    }
                    break;
                case 6: //Did get on leaderboard
                    if (ctrlSwitchDelayTimer >= 0f) ctrlSwitchDelayTimer -= Time.deltaTime;
                    if(Keyboard.current.ctrlKey.isPressed && ctrlSwitchDelayTimer <= 0f)
                    {
                        isDirectInput = !isDirectInput;
                        if (isDirectInput)
                        {
                            Keyboard.current.onTextInput += OnTextInput;
                            directInputText.SetActive(true);
                            gridInputText.SetActive(false);
                            gm.menuMaster.GetComponent<MenuMaster>().eventSystem.SetSelectedGameObject(null);
                        }
                        if (!isDirectInput)
                        {
                            Keyboard.current.onTextInput -= OnTextInput;
                            directInputText.SetActive(false);
                            gridInputText.SetActive(true);
                            gm.menuMaster.GetComponent<MenuMaster>().eventSystem.SetSelectedGameObject(firstCharInCharGrid);
                        }
                        ctrlSwitchDelayTimer = 0.2f;
                    }
#if UNITY_ANDROID
                    if(tsKeyboard.status == TouchScreenKeyboard.Status.Done)
                    {
                        OnTextInputDone();
                    }
                    else if(!TouchScreenKeyboard.visible)
                    {
                        tsKeyboard = TouchScreenKeyboard.Open("", TouchScreenKeyboardType.Default, false);
                    }
#elif UNITY_IOS
                    if(tsKeyboard.status == TouchScreenKeyboard.Status.Done)
                    {
                        OnTextInputDone();
                    }
                    else if(!TouchScreenKeyboard.visible)
                    {
                        tsKeyboard = TouchScreenKeyboard.Open("", TouchScreenKeyboardType.Default, false);
                    }
#endif
                    break;
            }
            if(time < 0f && runTimer && fspeed == 0.0f && playUIState == 1)
            {
                gameOverText.SetActive(true);
#if UNITY_ANDROID
                gm.playTouchControls.SetActive(false);
#elif UNITY_IOS
                gm.playTouchControls.SetActive(false);
#endif
                gm.BTMSource.PlaySong(5);
                timeToReturnToMenu = 9f;
                playUIState = 3;
            }
            else if(distance >= currentTrack.endDistance && playUIState == 1)
            {
                winText.SetActive(true);
#if UNITY_ANDROID
                gm.playTouchControls.SetActive(false);
#elif UNITY_IOS
                gm.playTouchControls.SetActive(false);
#endif
                gm.BTMSource.PlaySong(6);
                timeLeftToAdd = time;
                bonusMultiplierText.text = "×" + ((int)winScoreBonusPerSecondLeft).ToString() + "0";
                StartCoroutine(WinAnimation());
                playUIState = 4;
            }
            playerSounds.SetPitch(fspeed*0.0035f);
            spline.yOffset = distance;
            spline.xOffset = xoffs;
            playerCollider.transform.position = new Vector3(xoffs, 8f, 0f);
            displayScore = (uint)score;
            speedText.text = ((int)(fspeed/3f)).ToString();
            grazeText.text = edgeGrazeMultiplier.ToString();
            scoreText.text = (displayScore == 0)?"0":(displayScore.ToString() + "0");
            timeText.text = (time >= 0f)?((int)time).ToString():"0";
            stageText.text = stageNum.ToString();
            progBarCurrentStageText.text = stageNum.ToString();
            progBarNextStageText.text = (stageNum >= (uint)currentTrack.tTimeList.Length)?"G":(stageNum+1).ToString();
            progBar.sizeDelta = new Vector2(Mathf.Lerp(8f, 80f, (distance-stageStartDistance)/(stageEndDistance-stageStartDistance)), 8f);
            progBarGirl.anchoredPosition = new Vector2(Mathf.Lerp(4f, 76f, (distance-stageStartDistance)/(stageEndDistance-stageStartDistance)),-2f);
            horizonHeight = spline.GetHorizonHeight();
            skyObj.transform.position = new Vector3(0f, horizonHeight, spline.baseSplineHeight + 0.02f);
            background1.transform.position = new Vector3(bg1TravelDist, horizonHeight, spline.baseSplineHeight);
            background2.transform.position = new Vector3(bg2TravelDist, horizonHeight, spline.baseSplineHeight + 0.01f);
			if(currentTurnStrPoint >= mTurnStrLen - 1)
			{
				
			}
			else if(distance >= mTurnStrPoints[currentTurnStrPoint])
			{
				currentind = currentTurnStrPoint;
				startind = currentind - roadParamsKeepBehind;
				if(startind <= 0)
				{
					startind = 0;
				}
				finind = currentind + roadParamsLookAhead;
				if(finind >= mTurnStrLen)
				{
					finind = mTurnStrLen - 1;
				}
				indlen = finind - startind + 1;
				spline.turnStrList = new float[indlen+2];
				spline.turnStrPoints = new float[indlen+2];
				spline.turnStrList[0] = mTurnStrList[startind];
				spline.turnStrPoints[0] = mTurnStrPoints[startind];
				for(int i = 0; i <= indlen; i++)
				{
					if(i == indlen)
					{
						spline.turnStrList[i+1] = mTurnStrList[i+startind-1];
						spline.turnStrPoints[i+1] = 999999999f;
					}
					else
					{
						spline.turnStrList[i+1] = mTurnStrList[i+startind];
						spline.turnStrPoints[i+1] = mTurnStrPoints[i+startind];
					}
				}
				currentTurnStrPoint++;
			}
			if(currentSplitAmtPoint >= mSplitAmtLen - 1)
			{
				
			}
			else if(distance >= mSplitAmtPoints[currentSplitAmtPoint])
			{
				currentind = currentSplitAmtPoint;
				startind = currentind - roadParamsKeepBehind;
				if(startind <= 0)
				{
					startind = 0;
				}
				finind = currentind + roadParamsLookAhead;
				if(finind >= mSplitAmtLen)
				{
					finind = mSplitAmtLen - 1;
				}
				indlen = finind - startind + 1;
				spline.splitAmtList = new float[indlen+2];
				spline.splitAmtPoints = new float[indlen+2];
				spline.splitAmtList[0] = mSplitAmtList[startind];
				spline.splitAmtPoints[0] = mSplitAmtPoints[startind];
				for(int i = 0; i <= indlen; i++)
				{
					if(i == indlen)
					{
						spline.splitAmtList[i+1] = mSplitAmtList[i+startind-1];
						spline.splitAmtPoints[i+1] = 999999999f;
					}
					else
					{
						spline.splitAmtList[i+1] = mSplitAmtList[i+startind];
						spline.splitAmtPoints[i+1] = mSplitAmtPoints[i+startind];
					}
				}
				currentSplitAmtPoint++;
			}
			if(currentPitchStrPoint >= mPitchStrLen - 1)
			{
				
			}
			else if(distance >= mPitchStrPoints[currentPitchStrPoint])
			{
				currentind = currentPitchStrPoint;
				startind = currentind - roadParamsKeepBehind;
				if(startind <= 0)
				{
					startind = 0;
				}
				finind = currentind + roadParamsLookAhead;
				if(finind >= mPitchStrLen)
				{
					finind = mPitchStrLen - 1;
				}
				indlen = finind - startind + 1;
				spline.pitchStrList = new float[indlen+2];
				spline.pitchStrPoints = new float[indlen+2];
				spline.pitchStrList[0] = mPitchStrList[startind];
				spline.pitchStrPoints[0] = mPitchStrPoints[startind];
				for(int i = 0; i <= indlen; i++)
				{
					if(i == indlen)
					{
						spline.pitchStrList[i+1] = mPitchStrList[i+startind-1];
						spline.pitchStrPoints[i+1] = 999999999f;
					}
					else
					{
						spline.pitchStrList[i+1] = mPitchStrList[i+startind];
						spline.pitchStrPoints[i+1] = mPitchStrPoints[i+startind];
					}
				}
				currentPitchStrPoint++;
			}
			if(!staticMultiSpriteIsLoaded[currentSpritePoint] && (distance + spriteDrawDistance) >= mSpritePoints[currentSpritePoint] && currentSpritePoint < mSpriteLen)
			{
				LoadNewStaticSpriteGroup(currentSpritePoint);
				currentSpritePoint++;
			}
            for(int i = 0; i < staticMSSpawnInfos.Length; i++)
            {
                if(staticMSSpawnInfos[i] == null)
                {
                    continue;
                }
                else if(staticMSSpawnInfos[i].lastSpriteSpawnDistance < (distance - spriteUnloadBehindDistance))
                {
                    UnloadStaticSpriteGroup(i);
                    continue;
                }
                while (staticMSSpawnInfos[i].areSpritesLeftToSpawn && (staticMSSpawnInfos[i].nextSpriteSpawnDistance < (distance + spriteDrawDistance)))
                {
                    LoadNextStaticSpriteInGroup(i);
                }
            }
            if(staticSpriteNumberLoaded > 0)
            {
                UnloadNextStaticSprites();
                UpdateStaticSprites();
            }
            if((distance + spriteDrawDistance - 100f) >= nextDynamicSpriteSpawnDist)
            {
                LoadDynamicSprite();
                nextDynamicSpriteSpawnDist += dynamicSpriteBaseSeparation;
            }
            for(int i = 0; i < dynamicSpriteObjects.Length; i++)
            {
                if(dynamicSpriteIsLoaded[i] && (dynamicSpriteDistance[i] < (distance - spriteUnloadBehindDistance) || dynamicSpriteDistance[i] > (distance + spriteDrawDistance)))
                {
                    UnloadDynamicSprite(i);
                }
            }
            UpdateDynamicSprites();
            if(fspeed > 600f && playUIState != 2)
            {
                nextDynamicSpriteSpawnDist += 600f*Time.deltaTime;
            }
            else
            {
                nextDynamicSpriteSpawnDist = distance + spriteDrawDistance;
            }
            float distanceFactor;
            for(int i = 1; i < mBGLen; i++)
            {
                if(distance >= mBGPoints[i-1] && distance < mBGPoints[i])
                {
                    distanceFactor = (distance-mBGPoints[i-1])/(mBGPoints[i]-mBGPoints[i-1]);
                    colourInterp[0] = Color32.Lerp(mBGList[i-1].spriteColour, mBGList[i].spriteColour, distanceFactor);
                    bg1sprrend.sprite = mBGList[i-1].bg1Sprite;
                    bg2sprrend.sprite = mBGList[i-1].bg2Sprite;
                    bg1sprrend.color = colourInterp[0];
                    bg2sprrend.color = colourInterp[0];
                }
            }
            for(int i = 1; i < mColourLen; i++)
            {
                if(distance >= mColourPoints[i-1] && distance < mColourPoints[i])
                {
                    distanceFactor = (distance-mColourPoints[i-1])/(mColourPoints[i]-mColourPoints[i-1]);
                    for(int j = 0; j < 256; j++)
                    {
                        if(j >= mColourList[i-1].Length || j >= mColourList[i].Length)
                        {
                            continue;
                        }
                        colourInterp[j] = Color32.Lerp(mColourList[i-1][j], mColourList[i][j], distanceFactor);
                    }
                }
            }
            paletteMat.SetPalette(colourInterp);
            skyPal.SetPalette(colourInterp);
        }
    }
}