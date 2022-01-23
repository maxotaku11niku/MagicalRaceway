using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace SplineTest
{
    public class GameMaster : MonoBehaviour
    {
        private static readonly char[] configID = new char[]{(char)0x4D, (char)0x52, (char)0x43, (char)0x46}; //"MRCF"
        private static readonly char[] configVersion = new char[]{(char)0x33, (char)0x39}; //"39"
#if UNITY_EDITOR
        private static readonly string configPath = "Assets/Scorefiles/init.cfg";
#elif UNITY_STANDALONE
        private static readonly string configPath = "Scorefiles/init.cfg";
#elif UNITY_ANDROID
        private static readonly string configPath = "Scorefiles/init.cfg";
#else
        private static readonly string configPath = "Scorefiles/init.cfg";
#endif
        private int maxRes; //Highest allowable resolution multiplier, from the dimensions of the screen

        public GameObject menuMaster;
        public GameObject playMaster;
        public GameObject touchControlsCanvas;
        public GameObject playTouchControls;
        public GameObject menuTouchControls;
        public GameObject creatorLogoObject;
        public GameObject fadeScreen;
        public HighScoreGroup[] scoreGroups;
        public SoundQueuer BGMSource; //Probably redundant now
        public BTMPlayer BTMSource;
        public TrackDefinition[] tracks;
        public int currentTrackNum;
        public bool skipToPlay; //Development only, leave as false for release builds
        public FullScreenMode dMode;
        public int chosenResolution;
        public int resolutionMultiplier;
        public int MaxResolutionMultiplier { get{ return maxRes; } }
        public float BGMVolume;
        public float SFXVolume;
        public int mQuality; //Which OPNA emulation to use
        public PlayerInput playerInput;
        public InputActionAsset defaultActions;
        public InputActionAsset currentActions;
        PlayMaster pm;
        MenuMaster mm;
        public Animator fadeAnimator;
        float logoDisplayTimeLeft;
        bool hasFinishedDisplayingLogo;
        public bool inTransition;
        public delegate void VoidFn();
        public delegate void VoidFnWithOneInt(int num);

        public string appBaseDirectory; //Best used with the Android version

        void Awake()
        {
            mm = menuMaster.GetComponent<MenuMaster>();
            pm = playMaster.GetComponent<PlayMaster>();
            inTransition = false;
            fadeAnimator = fadeScreen.GetComponent<Animator>();
            scoreGroups = new HighScoreGroup[5];
#if UNITY_ANDROID
            appBaseDirectory = Application.persistentDataPath; //Needed otherwise it will default to the root of the entire system, which we don't have read/write permissions for anyway
#else
            appBaseDirectory = ""; //Not needed for other platforms
#endif
#if UNITY_EDITOR
            scoreGroups[0] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/test.mrs");
            scoreGroups[1] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/easy.mrs");
            scoreGroups[2] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/medium.mrs");
            scoreGroups[3] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/hard.mrs");
            scoreGroups[4] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/insane.mrs");
#elif UNITY_STANDALONE
            if(!Directory.Exists("Scorefiles"))
            {
                Directory.CreateDirectory("Scorefiles");
                HighScoreGroup.WriteDefaultScoreDataToFile("");
                WriteDefaultConfig();
            }
            scoreGroups[0] = HighScoreGroup.ImportScoreDataFromFile("Scorefiles/test.mrs");
            scoreGroups[1] = HighScoreGroup.ImportScoreDataFromFile("Scorefiles/easy.mrs");
            scoreGroups[2] = HighScoreGroup.ImportScoreDataFromFile("Scorefiles/medium.mrs");
            scoreGroups[3] = HighScoreGroup.ImportScoreDataFromFile("Scorefiles/hard.mrs");
            scoreGroups[4] = HighScoreGroup.ImportScoreDataFromFile("Scorefiles/insane.mrs");
#elif UNITY_ANDROID
            if(!Directory.Exists(appBaseDirectory + "Scorefiles"))
            {
                Directory.CreateDirectory(appBaseDirectory + "Scorefiles");
                HighScoreGroup.WriteDefaultScoreDataToFile(appBaseDirectory);
                WriteDefaultConfig();
            }
            scoreGroups[0] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/test.mrs");
            scoreGroups[1] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/easy.mrs");
            scoreGroups[2] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/medium.mrs");
            scoreGroups[3] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/hard.mrs");
            scoreGroups[4] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/insane.mrs");
#endif
            maxRes = Screen.currentResolution.height/240; //Does not account for screens which are narrower than 4:3
			//Must enable touch support, but only for mobile platforms
#if UNITY_ANDROID
            UnityEngine.InputSystem.EnhancedTouch.EnhancedTouchSupport.Enable();
            touchControlsCanvas.SetActive(true);
#elif UNITY_IOS
            UnityEngine.InputSystem.EnhancedTouch.EnhancedTouchSupport.Enable();
            touchControlsCanvas.SetActive(true);
#endif
            ReadConfig();
            hasFinishedDisplayingLogo = false;
            playerInput.actions = currentActions;
#if UNITY_ANDROID //Game is fullscreen only on Android

#else
            if (dMode == FullScreenMode.Windowed)
            {
                if (resolutionMultiplier > maxRes) resolutionMultiplier = maxRes;
                Screen.SetResolution(320 * resolutionMultiplier, 240 * resolutionMultiplier, dMode);
            }
            else Screen.SetResolution(Screen.resolutions[chosenResolution].width, Screen.resolutions[chosenResolution].height, dMode, Screen.resolutions[chosenResolution].refreshRate);
#endif
            if(skipToPlay)
            {
                StartGame(0);
            }
            else
            {
                DisplayLogo();
            }
        }

        public IEnumerator DoFadeAndFunction(VoidFn func, GameObject nextSelObj = null, float fadeOutSpeed = 1f, float fadeInSpeed = 1f, float waitTime = 0f)
        {
            mm.eventSystem.SetSelectedGameObject(null); //Make sure we can't navigate menus until the transition is done
            fadeAnimator.SetTrigger("FadeOut");
            fadeAnimator.SetFloat("Speed", fadeOutSpeed);
            inTransition = true;
            yield return new WaitForSecondsRealtime(0.2666666666666666666666f / fadeOutSpeed);
            yield return new WaitForSecondsRealtime(waitTime);
            func(); //Do the given function when the screen is blank
            fadeAnimator.SetTrigger("FadeIn");
            fadeAnimator.SetFloat("Speed", fadeInSpeed);
            mm.eventSystem.SetSelectedGameObject(nextSelObj); //Make it so that the selectors can adjust
            yield return new WaitForEndOfFrame();
            yield return new WaitForEndOfFrame();
            mm.eventSystem.SetSelectedGameObject(null);
            yield return new WaitForSecondsRealtime(0.2666666666666666666666f / fadeInSpeed);
            mm.eventSystem.SetSelectedGameObject(nextSelObj); //Commit reactivation after transition
            inTransition = false;
            yield break;
        }

        public IEnumerator DoFadeAndFunction(VoidFnWithOneInt func, int param, GameObject nextSelObj = null, float fadeOutSpeed = 1f, float fadeInSpeed = 1f, float waitTime = 0f)
        {
            mm.eventSystem.SetSelectedGameObject(null); //Make sure we can't navigate menus until the transition is done
            fadeAnimator.SetTrigger("FadeOut");
            fadeAnimator.SetFloat("Speed", fadeOutSpeed);
            inTransition = true;
            yield return new WaitForSecondsRealtime(0.2666666666666666666666f / fadeOutSpeed);
            yield return new WaitForSecondsRealtime(waitTime);
            func(param); //Do the given function when the screen is blank
            fadeAnimator.SetTrigger("FadeIn");
            fadeAnimator.SetFloat("Speed", fadeInSpeed);
            mm.eventSystem.SetSelectedGameObject(nextSelObj); //Make it so that the selectors can adjust
            yield return new WaitForEndOfFrame();
            yield return new WaitForEndOfFrame();
            mm.eventSystem.SetSelectedGameObject(null);
            yield return new WaitForSecondsRealtime(0.2666666666666666666666f / fadeInSpeed);
            mm.eventSystem.SetSelectedGameObject(nextSelObj); //Commit reactivation after transition
            inTransition = false;
            yield break;
        }

        void ReadConfig()
        {
            char[] charlist;
#if UNITY_ANDROID
            if (File.Exists(appBaseDirectory + configPath))
#else
            if (File.Exists(configPath))
#endif
            {
#if UNITY_ANDROID
                BinaryReader reader = new BinaryReader(File.Open(appBaseDirectory + configPath, FileMode.Open), Encoding.GetEncoding(28591));
#else
                BinaryReader reader = new BinaryReader(File.Open(configPath, FileMode.Open), Encoding.GetEncoding(28591));
#endif
                charlist = reader.ReadChars(4);
                if(new String(charlist) != new String(configID)) //Check if the file is a config file
                {
                    Debug.LogWarning("init.cfg is not valid. init.cfg must start with 'MRCF' in the header.");
                    return;
                }
                charlist = reader.ReadChars(2);
                if(new String(charlist) != new String(configVersion)) //Check if it is the right version
                {
                    Debug.LogWarning("init.cfg is incompatible. '39' is the current config file version indicator.");
                    return;
                }
                charlist = reader.ReadChars(1);
                if(charlist[0] != 0x02) //Just me being a bit pedantic
                {
                    Debug.LogWarning("init.cfg has an incorrectly terminated header. Terminate the header with the STX control (0x02).");
                    return;
                }
                dMode = (FullScreenMode)reader.ReadByte();
                chosenResolution = reader.ReadByte();
                resolutionMultiplier = reader.ReadByte();
                BGMVolume = reader.ReadByte();
                SFXVolume = reader.ReadByte();
                mQuality = reader.ReadByte();
                currentActions = ScriptableObject.CreateInstance<InputActionAsset>();
                currentActions.LoadFromJson(reader.ReadString());
                Debug.Log("init.cfg was successfully loaded!");
                reader.Close();
                return;
            }
            else //If the config file doesn't exist, write the default config to a new config file
            {
                Debug.LogWarning("init.cfg could not be found. Creating default configuration");
				WriteDefaultConfig();
                return;
            }
        }

        public void WriteConfig()
        {
#if UNITY_ANDROID
            BinaryWriter writer = new BinaryWriter(File.Open(appBaseDirectory + configPath, FileMode.Create), Encoding.GetEncoding(28591));
#else
            BinaryWriter writer = new BinaryWriter(File.Open(configPath, FileMode.Create), Encoding.GetEncoding(28591));
#endif
            writer.Write(configID);
            writer.Write(configVersion);
            writer.Write((byte)0x02);
            writer.Write((byte)dMode);
            writer.Write((byte)chosenResolution);
            writer.Write((byte)resolutionMultiplier);
            writer.Write((byte)BGMVolume);
            writer.Write((byte)SFXVolume);
            writer.Write((byte)mQuality);
            writer.Write(currentActions.ToJson());
            writer.Write((byte)0x04);
            writer.Close();
        }

        public void WriteDefaultConfig() //Use this only to generate the default configuration settings
        {
#if UNITY_ANDROID
            BinaryWriter writer = new BinaryWriter(File.Open(appBaseDirectory + configPath, FileMode.Create), Encoding.GetEncoding(28591));
#else
            BinaryWriter writer = new BinaryWriter(File.Open(configPath, FileMode.Create), Encoding.GetEncoding(28591));
#endif
            writer.Write(configID);
            writer.Write(configVersion);
            writer.Write((byte)0x02);
            writer.Write((byte)0x03);
            writer.Write((byte)0x00);
            writer.Write((byte)0x02);
            writer.Write((byte)0x64);
            writer.Write((byte)0x64);
            writer.Write((byte)0x00);
            writer.Write(defaultActions.ToJson());
            writer.Write((byte)0x04);
            writer.Close();
        }

        public void StartGame(int songNum)
        {
            menuMaster.SetActive(false);
            playMaster.SetActive(true);
#if UNITY_ANDROID
            menuTouchControls.SetActive(false);
            playTouchControls.SetActive(true);
#elif UNITY_IOS
            menuTouchControls.SetActive(false);
            playTouchControls.SetActive(true);
#endif
            pm.currentTrack = tracks[currentTrackNum];
            pm.SetUp(songNum);
        }

        public void ReturnToMainMenu()
        {
            playMaster.SetActive(false);
            menuMaster.SetActive(true);
#if UNITY_ANDROID
            playTouchControls.SetActive(false);
            menuTouchControls.SetActive(true);
#elif UNITY_IOS
            playTouchControls.SetActive(false);
            menuTouchControls.SetActive(true);
#endif
            mm.SetUp();
        }

        public void DisplayLogo()
        {
            creatorLogoObject.SetActive(true);
            logoDisplayTimeLeft = 7.0f;
        }

        void Update()
        {
            if(!hasFinishedDisplayingLogo)
            {
                logoDisplayTimeLeft -= Time.deltaTime;
                if(logoDisplayTimeLeft <= 0.0f)
                {
                    hasFinishedDisplayingLogo = true;
                    creatorLogoObject.SetActive(false);
                    ReturnToMainMenu();
                }
            }
        }
    }
}