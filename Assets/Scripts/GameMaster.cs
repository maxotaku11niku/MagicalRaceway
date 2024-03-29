﻿using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace SplineTest
{
    public class GameMaster : MonoBehaviour
    {
        private static readonly char[] configID = new char[]{(char)0x4D, (char)0x52, (char)0x43, (char)0x46}; //"MRCF"
        private static readonly char[] configVersion = new char[]{(char)0x34, (char)0x32}; //"42"
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
        public bool mToggle;
        public bool accelInvert;
        public PlayerInput playerInput;
        public InputActionAsset defaultActions;
        public InputActionAsset currentActions;
        PlayMaster pm;
        MenuMaster mm;
        public Animator fadeAnimator;
        float logoDisplayTimeLeft;
        bool hasFinishedDisplayingLogo;
        bool musicDebugVisible;
        public bool inTransition;
        public delegate void VoidFn();
        public delegate void VoidFnWithOneInt(int num);

        public string appBaseDirectory; //Best used with the Android version
        public GameObject musicDebugObject;
        Text musicDebugText;

        void Awake()
        {
            musicDebugVisible = false;
            musicDebugText = musicDebugObject.GetComponent<Text>();
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
            scoreGroups[0] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/easy.mrs");
            scoreGroups[1] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/medium.mrs");
            scoreGroups[2] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/hard.mrs");
            scoreGroups[3] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/insane.mrs");
            scoreGroups[4] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/test.mrs");
#elif UNITY_STANDALONE
            if(!Directory.Exists("Scorefiles"))
            {
                Directory.CreateDirectory("Scorefiles");
                HighScoreGroup.WriteDefaultScoreDataToFile("");
                WriteDefaultConfig();
            }
            scoreGroups[0] = HighScoreGroup.ImportScoreDataFromFile("Scorefiles/easy.mrs");
            scoreGroups[1] = HighScoreGroup.ImportScoreDataFromFile("Scorefiles/medium.mrs");
            scoreGroups[2] = HighScoreGroup.ImportScoreDataFromFile("Scorefiles/hard.mrs");
            scoreGroups[3] = HighScoreGroup.ImportScoreDataFromFile("Scorefiles/insane.mrs");
            scoreGroups[4] = HighScoreGroup.ImportScoreDataFromFile("Scorefiles/test.mrs");
#elif UNITY_ANDROID
            if(!Directory.Exists(appBaseDirectory + "Scorefiles"))
            {
                Directory.CreateDirectory(appBaseDirectory + "Scorefiles");
                HighScoreGroup.WriteDefaultScoreDataToFile(appBaseDirectory);
                WriteDefaultConfig();
            }
            scoreGroups[0] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/easy.mrs");
            scoreGroups[1] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/medium.mrs");
            scoreGroups[2] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/hard.mrs");
            scoreGroups[3] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/insane.mrs");
            scoreGroups[4] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/test.mrs");
#endif
            for(int i = 0; i < scoreGroups.Length; i++)
            {
                if(scoreGroups[i] == null)
                {
                    switch(i)
                    {
                        case 0:
#if UNITY_EDITOR
                            HighScoreGroup.easyDefault.WriteScoreDataToFile("Assets/Scorefiles/easy.mrs");
#elif UNITY_STANDALONE
                            HighScoreGroup.easyDefault.WriteScoreDataToFile("Scorefiles/easy.mrs");
#elif UNITY_ANDROID
                            HighScoreGroup.easyDefault.WriteScoreDataToFile(appBaseDirectory + "Scorefiles/easy.mrs");
#endif
                            break;
                        case 1:
#if UNITY_EDITOR
                            HighScoreGroup.mediumDefault.WriteScoreDataToFile("Assets/Scorefiles/medium.mrs");
#elif UNITY_STANDALONE
                            HighScoreGroup.mediumDefault.WriteScoreDataToFile("Scorefiles/medium.mrs");
#elif UNITY_ANDROID
                            HighScoreGroup.mediumDefault.WriteScoreDataToFile(appBaseDirectory + "Scorefiles/medium.mrs");
#endif
                            break;
                        case 2:
#if UNITY_EDITOR
                            HighScoreGroup.hardDefault.WriteScoreDataToFile("Assets/Scorefiles/hard.mrs");
#elif UNITY_STANDALONE
                            HighScoreGroup.hardDefault.WriteScoreDataToFile("Scorefiles/hard.mrs");
#elif UNITY_ANDROID
                            HighScoreGroup.hardDefault.WriteScoreDataToFile(appBaseDirectory + "Scorefiles/hard.mrs");
#endif
                            break;
                        case 3:
#if UNITY_EDITOR
                            HighScoreGroup.insaneDefault.WriteScoreDataToFile("Assets/Scorefiles/insane.mrs");
#elif UNITY_STANDALONE
                            HighScoreGroup.insaneDefault.WriteScoreDataToFile("Scorefiles/insane.mrs");
#elif UNITY_ANDROID
                            HighScoreGroup.insaneDefault.WriteScoreDataToFile(appBaseDirectory + "Scorefiles/insane.mrs");
#endif
                            break;
                        case 4:
#if UNITY_EDITOR
                            HighScoreGroup.testDefault.WriteScoreDataToFile("Assets/Scorefiles/test.mrs");
#elif UNITY_STANDALONE
                            HighScoreGroup.testDefault.WriteScoreDataToFile("Scorefiles/test.mrs");
#elif UNITY_ANDROID
                            HighScoreGroup.testDefault.WriteScoreDataToFile(appBaseDirectory + "Scorefiles/test.mrs");
#endif
                            break;
                    }
                }
                ReloadScores();
            }
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
            if(mToggle) BTMSource.InitBTMPlayer();
            if(skipToPlay)
            {
                StartGame(0);
            }
            else
            {
                DisplayLogo();
            }
        }

        public void ReloadScores()
        {
#if UNITY_EDITOR
            scoreGroups[0] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/easy.mrs");
            scoreGroups[1] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/medium.mrs");
            scoreGroups[2] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/hard.mrs");
            scoreGroups[3] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/insane.mrs");
            scoreGroups[4] = HighScoreGroup.ImportScoreDataFromFile("Assets/Scorefiles/test.mrs");
#else
            scoreGroups[0] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/easy.mrs");
            scoreGroups[1] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/medium.mrs");
            scoreGroups[2] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/hard.mrs");
            scoreGroups[3] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/insane.mrs");
            scoreGroups[4] = HighScoreGroup.ImportScoreDataFromFile(appBaseDirectory + "Scorefiles/test.mrs");
#endif
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
                BinaryReader reader = new BinaryReader(File.Open(appBaseDirectory + configPath, FileMode.Open), Encoding.GetEncoding(65001));
#else
                BinaryReader reader = new BinaryReader(File.Open(configPath, FileMode.Open), Encoding.GetEncoding(65001));
#endif
                charlist = reader.ReadChars(4);
                if(new String(charlist) != new String(configID)) //Check if the file is a config file
                {
                    Debug.LogWarning("init.cfg is not valid. init.cfg must start with 'MRCF' in the header.");
                    reader.Close();
                    return;
                }
                charlist = reader.ReadChars(2);
                if(new String(charlist) != new String(configVersion)) //Check if it is the right version
                {
                    Debug.LogWarning("init.cfg is incompatible. '42' is the current config file version indicator. Writing default config file.");
                    reader.Close();
                    WriteDefaultConfig();
                    return;
                }
                charlist = reader.ReadChars(1);
                if(charlist[0] != 0x02) //Just me being a bit pedantic
                {
                    Debug.LogWarning("init.cfg has an incorrectly terminated header. Terminate the header with the STX control (0x02).");
                    reader.Close();
                    return;
                }
                dMode = (FullScreenMode)reader.ReadByte();
                chosenResolution = reader.ReadByte();
                resolutionMultiplier = reader.ReadByte();
                BGMVolume = reader.ReadByte();
                SFXVolume = reader.ReadByte();
                mToggle = (reader.ReadByte() == 0) ? false : true;
                accelInvert = (reader.ReadByte() == 0) ? false : true;
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
            BinaryWriter writer = new BinaryWriter(File.Open(appBaseDirectory + configPath, FileMode.Create), Encoding.GetEncoding(65001));
#else
            BinaryWriter writer = new BinaryWriter(File.Open(configPath, FileMode.Create), Encoding.GetEncoding(65001));
#endif
            writer.Write(configID);
            writer.Write(configVersion);
            writer.Write((byte)0x02);
            writer.Write((byte)dMode);
            writer.Write((byte)chosenResolution);
            writer.Write((byte)resolutionMultiplier);
            writer.Write((byte)BGMVolume);
            writer.Write((byte)SFXVolume);
            writer.Write((byte)(mToggle ? 1 : 0));
            writer.Write((byte)(accelInvert ? 1 : 0));
            writer.Write(currentActions.ToJson());
            writer.Write((byte)0x04);
            writer.Close();
        }

        public void WriteDefaultConfig() //Use this only to generate the default configuration settings
        {
#if UNITY_ANDROID
            BinaryWriter writer = new BinaryWriter(File.Open(appBaseDirectory + configPath, FileMode.Create), Encoding.GetEncoding(65001));
#else
            BinaryWriter writer = new BinaryWriter(File.Open(configPath, FileMode.Create), Encoding.GetEncoding(65001));
#endif
            writer.Write(configID);
            writer.Write(configVersion);
            writer.Write((byte)0x02);
            writer.Write((byte)0x03); //Display Mode = Windowed
            writer.Write((byte)0x00); //Lowest possible resolution
            writer.Write((byte)0x02); //Windowed Resolution = 640 x 480
            writer.Write((byte)0x64); //BGM Volume = 100%
            writer.Write((byte)0x64); //SFX Volume = 100%
            writer.Write((byte)0x01); //Music on
            writer.Write((byte)0x00); //Accelerator button -> accelerates
            writer.Write(defaultActions.ToJson());
            writer.Write((byte)0x04);
            writer.Close();
            ReadConfig();
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

        void ToggleMusicDebug()
        {
            musicDebugVisible = !musicDebugVisible;
            musicDebugObject.SetActive(musicDebugVisible);
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
            if(Keyboard.current.altKey.isPressed && Keyboard.current.mKey.wasPressedThisFrame)
            {
                ToggleMusicDebug();
            }
            if(musicDebugVisible)
            {
                musicDebugText.text = "";
                StringBuilder sb = new StringBuilder();
                for(int i = 0; i < 0x1D0; i++)
                {
                    if(i%0x10 == 0)
                    {
                        if(i>=0) sb.Append("\n");
                        sb.AppendFormat("{0:X3}", i);
                    }
                    if(i%0x4 == 0)
                    {
                        sb.Append(" ");
                    }
                    sb.AppendFormat("{0:X2}", BTMSource.GetRegister(i));
                }
                sb.Append("\nYM2608 Register Viewer - Press Alt-M");
                musicDebugText.text = sb.ToString();
            }
        }
    }
}