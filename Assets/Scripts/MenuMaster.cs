using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Audio;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

namespace SplineTest
{
    public class MenuMaster : MonoBehaviour
    {
        public GameMaster gm;
        public GameObject menuUIRoot;
        public GameObject ostWarning;
        public bool isOstBundled;
        public EventSystem eventSystem;
        public PlayerInput pInput;
        public SoundQueuer sounds;
        InputAction mNavi;

        public TouchButton acceptTButton;
        public TouchButton declineTButton;
        public TouchButton dpadUpTButton;
        public TouchButton dpadDownTButton;
        public TouchButton dpadLeftTButton;
        public TouchButton dpadRightTButton;

        public GameObject leftSelector;
        public GameObject rightSelector;
        public GameObject BGObject;

        public GameObject mainMenu;
        public GameObject startButton;
        public GameObject scoresButton;
        public GameObject musicButton;
        public GameObject configButton;
        public GameObject quitButton;

        public GameObject scoresMenu;

        public GameObject configMenuPC;
        public GameObject configMenuMobile;
        public GameObject displayModeSelector;
        public GameObject resolutionSelector;
        public GameObject BGMVolSelector;
        public GameObject SFXVolSelector;
        public GameObject musicQualitySelector;
        public GameObject resetScoresButton;
        public GameObject resetScoresConfirmation;
        public GameObject controlConfigButton;
        public GameObject confirmButton;
        public GameObject declineButton;
        public GameObject controlConfigMenu;
        public GameObject returnFromControlConfigButton;
        public GameObject BGMVolSelectorMobile;
        public GameObject SFXVolSelectorMobile;
        public GameObject musicQualitySelectorMobile;
        public GameObject resetScoresButtonMobile;
        public GameObject resetScoresConfirmationMobile;
        public GameObject confirmButtonMobile;
        public GameObject declineButtonMobile;
        public AudioMixer audioMixer;

        public GameObject musicMenu;
        public GameObject musicTitle;
        public GameObject musicComments;

        public GameObject difficultyMenu;
        public GameObject easyButton;
        public GameObject mediumButton;
        public GameObject hardButton;
        public GameObject insaneButton;

        public GameObject BGMMenu;
        public GameObject song1Button;
        public GameObject song2Button;
        public GameObject song3Button;
        public GameObject song4Button;

        RectTransform leftSelectorTransform;
        RectTransform rightSelectorTransform;
        Image leftSelectorImage;
        Image rightSelectorImage;
        Transform BGTransform;
        SpriteRenderer BGSprite;

        Button startB;
        Button scoresB;
        Button musicB;
        Button configB;
        Button quitB;

        Text musicTitleText;
        Text musicCommentText;

        Text displayModeText;
        Text resolutionText;
        Text BGMVolText;
        Text SFXVolText;
        Text musicQualityText;

        Text BGMVolTextMobile;
        Text SFXVolTextMobile;
        Text musicQualityTextMobile;
        
        Text song1Text;
        Text song2Text;
        Text song3Text;
        Text song4Text;

        Button easyB;
        Button mediumB;
        Button hardB;
        Button insaneB;

        Button song1B;
        Button song2B;
        Button song3B;
        Button song4B;

        float BGPos;
        GameObject currentSelected;
        Button currentSelectedButton;
        Selectable upOfSelected;
        Selectable downOfSelected;
        Selectable leftOfSelected;
        Selectable rightOfSelected;
        RectTransform currentSelTransform;
        Rect currentSelRect;
        int menuState;
        FullScreenMode oldDispMode;
        int oldRes;
        int oldResMul;
        float oldBGMVol;
        float oldSFXVol;
        int oldMusQ;
        bool awaitingConfirmation;
        readonly Vector2 ScreenDim = new Vector2(0f,240f);
        delegate void VoidFn();
        delegate void VoidFnWithOneInt(int num);

        void Awake()
        {
            mNavi = pInput.currentActionMap.FindAction("Menu Navigation");
            leftSelectorTransform = leftSelector.GetComponent<RectTransform>();
            rightSelectorTransform = rightSelector.GetComponent<RectTransform>();
            leftSelectorImage = leftSelector.GetComponent<Image>();
            rightSelectorImage = rightSelector.GetComponent<Image>();
            BGTransform = BGObject.GetComponent<Transform>();
            BGSprite = BGObject.GetComponent<SpriteRenderer>();
            startB = startButton.GetComponent<Button>();
            scoresB = scoresButton.GetComponent<Button>();
            musicB = musicButton.GetComponent<Button>();
            configB = configButton.GetComponent<Button>();
            quitB = quitButton.GetComponent<Button>();
            musicTitleText = musicTitle.GetComponent<Text>();
            musicCommentText = musicComments.GetComponent<Text>();
            displayModeText = displayModeSelector.GetComponent<Text>();
            resolutionText = resolutionSelector.GetComponent<Text>();
            BGMVolText = BGMVolSelector.GetComponent<Text>();
            SFXVolText = SFXVolSelector.GetComponent<Text>();
            musicQualityText = musicQualitySelector.GetComponent<Text>();
            BGMVolTextMobile = BGMVolSelectorMobile.GetComponent<Text>();
            SFXVolTextMobile = SFXVolSelectorMobile.GetComponent<Text>();
            musicQualityTextMobile = musicQualitySelectorMobile.GetComponent<Text>();
            easyB = easyButton.GetComponent<Button>();
            mediumB = mediumButton.GetComponent<Button>();
            hardB = hardButton.GetComponent<Button>();
            insaneB = insaneButton.GetComponent<Button>();
            song1B = song1Button.GetComponent<Button>();
            song2B = song2Button.GetComponent<Button>();
            song3B = song3Button.GetComponent<Button>();
            song4B = song4Button.GetComponent<Button>();
            song1Text = song1Button.GetComponent<Text>();
            song2Text = song2Button.GetComponent<Text>();
            song3Text = song3Button.GetComponent<Text>();
            song4Text = song4Button.GetComponent<Text>();
            BGPos = 0;
            BGSprite.color = new Color32(0xCE, 0x6B, 0xFF, 0xFF);
            menuState = 0;
            awaitingConfirmation = false;
        }

        public void SetUp()
        {
            pInput.SwitchCurrentActionMap("Menu");
            BGPos = 0;
            BGSprite.color = new Color32(0xCE, 0x6B, 0xFF, 0xFF);
            menuState = 0;
            menuUIRoot.SetActive(true);
            mainMenu.SetActive(true);
            gm.BTMSource.PlaySong(0);
            eventSystem.SetSelectedGameObject(startButton);
            currentSelected = startButton;
            audioMixer.SetFloat("BGMVol", (gm.BGMVolume <= 0)?-80f:Mathf.Log10((gm.BGMVolume)/100f)*40f);
            audioMixer.SetFloat("SFXVol", (gm.SFXVolume <= 0)?-80f:Mathf.Log10((gm.SFXVolume)/100f)*40f);
            if (isOstBundled) ostWarning.SetActive(false);
            else ostWarning.SetActive(true);
        }
        
        void OnMenuNavigation()
        {
            if (pInput.currentActionMap.FindAction("Menu Navigation").phase != InputActionPhase.Performed) return;
            sounds.PlayOneShot(2);
        }

        void OnDecline()
        {
            if (gm.inTransition || awaitingConfirmation) return;
#if UNITY_STANDALONE
            if (pInput.currentActionMap.FindAction("Decline").phase != InputActionPhase.Performed) return;
#elif UNITY_EDITOR
            if (pInput.currentActionMap.FindAction("Decline").phase != InputActionPhase.Performed) return;
#endif
            sounds.PlayOneShot(1);
            switch (menuState)
            {
                case 1:
                    OnRetractFromDifficulty();
                    break;
                case 2:
                    OnRetractFromGameSong();
                    break;
                case 3:
                    OnRetractFromScores();
                    break;
                case 4:
                    OnRetractFromMusic();
                    break;
                case 5:
                    OnRetractFromConfig();
                    break;
                case 6:
                    OnRetractFromControlRebind();
                    break;
                default:
                    break;
            }
        }

        void Update()
        {
            BGPos += 60f*Time.deltaTime;
            BGPos %= 128f;
            BGTransform.position = new Vector3(-BGPos - 64f, -BGPos - 64f, 0);
            currentSelected = eventSystem.currentSelectedGameObject;
#if UNITY_ANDROID
            currentSelectedButton = currentSelected.GetComponent<Button>();
            upOfSelected = currentSelected.GetComponent<Selectable>().FindSelectableOnUp();
            downOfSelected = currentSelected.GetComponent<Selectable>().FindSelectableOnDown();
            leftOfSelected = currentSelected.GetComponent<Selectable>().FindSelectableOnLeft();
            rightOfSelected = currentSelected.GetComponent<Selectable>().FindSelectableOnRight();
            if (dpadUpTButton.isDown)
            {
                if (upOfSelected != null) eventSystem.SetSelectedGameObject(upOfSelected.gameObject);
                sounds.PlayOneShot(2);
            }
            else if(dpadDownTButton.isDown)
            {
                if (downOfSelected != null) eventSystem.SetSelectedGameObject(downOfSelected.gameObject);
                sounds.PlayOneShot(2);
            }
            else if (dpadLeftTButton.isDown)
            {
                if (leftOfSelected != null) eventSystem.SetSelectedGameObject(leftOfSelected.gameObject);
                sounds.PlayOneShot(2);
            }
            else if (dpadRightTButton.isDown)
            {
                if (rightOfSelected != null) eventSystem.SetSelectedGameObject(rightOfSelected.gameObject);
                sounds.PlayOneShot(2);
            }
            if(declineTButton.isDown)
            {
                OnDecline();
            }
            else if(acceptTButton.isDown)
            {
                if(currentSelectedButton != null) currentSelectedButton.OnSubmit(null);
            }
#elif UNITY_IOS
            currentSelectedButton = currentSelected.GetComponent<Button>();
            upOfSelected = currentSelected.GetComponent<Selectable>().FindSelectableOnUp();
            downOfSelected = currentSelected.GetComponent<Selectable>().FindSelectableOnDown();
            leftOfSelected = currentSelected.GetComponent<Selectable>().FindSelectableOnLeft();
            rightOfSelected = currentSelected.GetComponent<Selectable>().FindSelectableOnRight();
            if (dpadUpTButton.isDown)
            {
                if (upOfSelected != null) eventSystem.SetSelectedGameObject(upOfSelected.gameObject);
                sounds.PlayOneShot(2);
            }
            else if(dpadDownTButton.isDown)
            {
                if (downOfSelected != null) eventSystem.SetSelectedGameObject(downOfSelected.gameObject);
                sounds.PlayOneShot(2);
            }
            else if (dpadLeftTButton.isDown)
            {
                if (leftOfSelected != null) eventSystem.SetSelectedGameObject(leftOfSelected.gameObject);
                sounds.PlayOneShot(2);
            }
            else if (dpadRightTButton.isDown)
            {
                if (rightOfSelected != null) eventSystem.SetSelectedGameObject(rightOfSelected.gameObject);
                sounds.PlayOneShot(2);
            }
            if(declineTButton.isDown)
            {
                OnDecline();
            }
            else if(acceptTButton.isDown)
            {
                if(currentSelectedButton != null) currentSelectedButton.OnSubmit(null);
            }
#endif
            if (currentSelected != null)
            {
                currentSelTransform = currentSelected.GetComponent<RectTransform>();
                currentSelRect = currentSelTransform.rect;
                leftSelectorTransform.localScale = currentSelTransform.localScale;
                rightSelectorTransform.localScale = currentSelTransform.localScale;
            }
            if(currentSelected == displayModeSelector)
            {
                leftSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMax + 16f) * currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                rightSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMin - 16f) * currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                if(mNavi.triggered)
                {
                    gm.dMode += (int)(mNavi.ReadValue<Vector2>().x);
                    if (gm.dMode < FullScreenMode.ExclusiveFullScreen) gm.dMode = FullScreenMode.Windowed;
                    if (gm.dMode > FullScreenMode.Windowed) gm.dMode = FullScreenMode.ExclusiveFullScreen;
                    displayModeText.text = gm.dMode.ToString();
                    if(gm.dMode == FullScreenMode.Windowed) resolutionText.text = (gm.resolutionMultiplier * 320).ToString() + "×" + (gm.resolutionMultiplier * 240).ToString();
                    else resolutionText.text = Screen.resolutions[gm.chosenResolution].ToString();
                }
            }
            else if(currentSelected == resolutionSelector)
            {
                leftSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMax + 16f)*currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                rightSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMin - 16f)*currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                if(mNavi.triggered)
                {
                    if(gm.dMode == FullScreenMode.Windowed)
                    {
                        gm.resolutionMultiplier += (int)(mNavi.ReadValue<Vector2>().x);
                        if (gm.resolutionMultiplier < 1) gm.resolutionMultiplier = gm.MaxResolutionMultiplier;
                        if (gm.resolutionMultiplier > gm.MaxResolutionMultiplier) gm.resolutionMultiplier = 1;
                        resolutionText.text = (gm.resolutionMultiplier * 320).ToString() + "×" + (gm.resolutionMultiplier * 240).ToString();
                    }
                    else
                    {
                        gm.chosenResolution += (int)(mNavi.ReadValue<Vector2>().x);
                        if (gm.chosenResolution < 0) gm.chosenResolution = Screen.resolutions.Length - 1;
                        if (gm.chosenResolution >= Screen.resolutions.Length) gm.chosenResolution = 0;
                        resolutionText.text = Screen.resolutions[gm.chosenResolution].ToString();
                    }
                }
            }
            else if(currentSelected == BGMVolSelector)
            {
                leftSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMax + 16f)*currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                rightSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMin - 16f)*currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                gm.BGMVolume += mNavi.ReadValue<Vector2>().x * Time.deltaTime*20f;
                if(gm.BGMVolume < 0) gm.BGMVolume = 0f;
                if(gm.BGMVolume > 100) gm.BGMVolume = 100f;
                audioMixer.SetFloat("BGMVol", (gm.BGMVolume <= 0)?-80f:Mathf.Log10((gm.BGMVolume)/100f)*40f);
                BGMVolText.text = ((int)gm.BGMVolume).ToString() + "%";
            }
            else if(currentSelected == BGMVolSelectorMobile)
            {
                leftSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMax + 16f) * currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                rightSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMin - 16f) * currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                if(dpadRightTButton.isHeld)
                {
                    gm.BGMVolume += Time.deltaTime * 20f;
                }
                else if (dpadLeftTButton.isHeld)
                {
                    gm.BGMVolume -= Time.deltaTime * 20f;
                }
                if (gm.BGMVolume < 0) gm.BGMVolume = 0f;
                if (gm.BGMVolume > 100) gm.BGMVolume = 100f;
                audioMixer.SetFloat("BGMVol", (gm.BGMVolume <= 0) ? -80f : Mathf.Log10((gm.BGMVolume) / 100f) * 40f);
                BGMVolTextMobile.text = ((int)gm.BGMVolume).ToString() + "%";
            }
            else if(currentSelected == SFXVolSelector)
            {
                leftSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMax + 16f)*currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                rightSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMin - 16f)*currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                gm.SFXVolume += mNavi.ReadValue<Vector2>().x * Time.deltaTime*20f;
                if(gm.SFXVolume < 0) gm.SFXVolume = 0;
                if(gm.SFXVolume > 100) gm.SFXVolume = 100;
                audioMixer.SetFloat("SFXVol", (gm.SFXVolume <= 0)?-80f:Mathf.Log10((gm.SFXVolume)/100f)*40f);
                SFXVolText.text = ((int)gm.SFXVolume).ToString() + "%";
            }
            else if (currentSelected == SFXVolSelectorMobile)
            {
                leftSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMax + 16f) * currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                rightSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMin - 16f) * currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                if (dpadRightTButton.isHeld)
                {
                    gm.SFXVolume += Time.deltaTime * 20f;
                }
                else if (dpadLeftTButton.isHeld)
                {
                    gm.SFXVolume -= Time.deltaTime * 20f;
                }
                if (gm.SFXVolume < 0) gm.SFXVolume = 0;
                if (gm.SFXVolume > 100) gm.SFXVolume = 100;
                audioMixer.SetFloat("SFXVol", (gm.SFXVolume <= 0) ? -80f : Mathf.Log10((gm.SFXVolume) / 100f) * 40f);
                SFXVolTextMobile.text = ((int)gm.SFXVolume).ToString() + "%";
            }
            else if(currentSelected == musicQualitySelector)
            {
                leftSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMax + 16f) * currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                rightSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMin - 16f) * currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                if (mNavi.triggered)
                {
                    gm.mQuality += (int)(mNavi.ReadValue<Vector2>().x);
                    if (gm.mQuality < 0) gm.mQuality = 2;
                    if (gm.mQuality > 2) gm.mQuality = 0;
                    switch(gm.mQuality)
                    {
                        case 0:
                            musicQualityText.text = "Normal";
                            break;
                        case 1:
                            musicQualityText.text = "High";
                            break;
                        case 2:
                            musicQualityText.text = "YMFM Test";
                            break;
                    }
                }
            }
            else if (currentSelected == musicQualitySelectorMobile)
            {
                leftSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMax + 16f) * currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                rightSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMin - 16f) * currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                if (dpadLeftTButton.isDown || dpadRightTButton.isDown)
                {
                    if (dpadRightTButton.isDown)
                    {
                        gm.mQuality++;
                    }
                    else if (dpadLeftTButton.isDown)
                    {
                        gm.mQuality--;
                    }
                    if (gm.mQuality < 0) gm.mQuality = 2;
                    if (gm.mQuality > 2) gm.mQuality = 0;
                    switch (gm.mQuality)
                    {
                        case 0:
                            musicQualityTextMobile.text = "Normal";
                            break;
                        case 1:
                            musicQualityTextMobile.text = "High";
                            break;
                        case 2:
                            musicQualityTextMobile.text = "YMFM Test";
                            break;
                    }
                }
            }
            else if(currentSelected == musicTitle)
            {
                leftSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMax + 16f) * currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
                rightSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMin - 16f) * currentSelTransform.localScale.x, currentSelRect.yMin) + currentSelTransform.anchoredPosition;
            }
            else if(currentSelected != null)
            {
                leftSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMin - 8f)*currentSelTransform.localScale.x, currentSelRect.yMin) + (Vector2)currentSelTransform.position - ScreenDim;
                rightSelectorTransform.anchoredPosition = new Vector2((currentSelRect.xMax + 8f)*currentSelTransform.localScale.x, currentSelRect.yMin) + (Vector2)currentSelTransform.position - ScreenDim;
            }
        }

        public void OnStartSelected()
        {
            StartCoroutine(gm.DoFadeAndFunction(GotoDifficultyFromMain, easyButton));
        }

        void GotoDifficultyFromMain()
        {
            mainMenu.SetActive(false);
            difficultyMenu.SetActive(true);
            BGSprite.color = new Color32(0xFF, 0xB5, 0x63, 0xFF);
            menuState = 1;
        }

        public void OnScoresSelected()
        {
            StartCoroutine(gm.DoFadeAndFunction(GotoScoresFromMain));
        }
        
        void GotoScoresFromMain()
        {
            mainMenu.SetActive(false);
            scoresMenu.SetActive(true);
            BGSprite.color = new Color32(0xFF, 0x5A, 0x00, 0xFF);
            leftSelector.SetActive(false);
            rightSelector.SetActive(false);
            menuState = 3;
        }

        public void OnRetractFromScores()
        {
            StartCoroutine(gm.DoFadeAndFunction(GotoMainFromScores, scoresButton));
        }

        void GotoMainFromScores()
        {
            scoresMenu.SetActive(false);
            mainMenu.SetActive(true);
            BGSprite.color = new Color32(0xCE, 0x6B, 0xFF, 0xFF);
            leftSelector.SetActive(true);
            rightSelector.SetActive(true);
            menuState = 0;
        }

        public void OnMusicSelected()
        {
            StartCoroutine(gm.DoFadeAndFunction(GotoMusicFromMain, musicTitle));
        }

        void GotoMusicFromMain()
        {
            mainMenu.SetActive(false);
            musicMenu.SetActive(true);
            BGSprite.color = new Color32(0x18, 0x39, 0x84, 0xFF);
            menuState = 4;
        }

        public void OnRetractFromMusic()
        {
            StartCoroutine(gm.DoFadeAndFunction(GotoMainFromMusic, musicButton));
        }

        void GotoMainFromMusic()
        {
            musicMenu.SetActive(false);
            mainMenu.SetActive(true);
            BGSprite.color = new Color32(0xCE, 0x6B, 0xFF, 0xFF);
            menuState = 0;
        }

        public void OnConfigSelected()
        {
#if UNITY_STANDALONE
            StartCoroutine(gm.DoFadeAndFunction(GotoConfigFromMain, displayModeSelector));
#elif UNITY_EDITOR
            StartCoroutine(gm.DoFadeAndFunction(GotoConfigFromMain, displayModeSelector));
#elif UNITY_ANDROID
            StartCoroutine(gm.DoFadeAndFunction(GotoConfigFromMain, BGMVolSelectorMobile));
#elif UNITY_IOS
            StartCoroutine(gm.DoFadeAndFunction(GotoConfigFromMain, BGMVolSelectorMobile));
#endif
        }

        void GotoConfigFromMain()
        {
            mainMenu.SetActive(false);
#if UNITY_STANDALONE
            configMenuPC.SetActive(true);
#elif UNITY_EDITOR
            configMenuPC.SetActive(true);
#elif UNITY_ANDROID
            configMenuMobile.SetActive(true);
#elif UNITY_IOS
            configMenuMobile.SetActive(true);
#endif
            BGSprite.color = new Color32(0x00, 0xCE, 0x73, 0xFF);
            menuState = 5;
            oldDispMode = gm.dMode;
            oldRes = gm.chosenResolution;
            oldResMul = gm.resolutionMultiplier;
            oldBGMVol = gm.BGMVolume;
            oldSFXVol = gm.SFXVolume;
            oldMusQ = gm.mQuality;
            displayModeText.text = gm.dMode.ToString();
            if (gm.dMode == FullScreenMode.Windowed) resolutionText.text = (gm.resolutionMultiplier * 320).ToString() + "×" + (gm.resolutionMultiplier * 240).ToString();
            else resolutionText.text = Screen.resolutions[gm.chosenResolution].ToString();
            BGMVolText.text = ((int)gm.BGMVolume).ToString() + "%";
            SFXVolText.text = ((int)gm.SFXVolume).ToString() + "%";
            BGMVolTextMobile.text = ((int)gm.BGMVolume).ToString() + "%";
            SFXVolTextMobile.text = ((int)gm.SFXVolume).ToString() + "%";
            switch (gm.mQuality)
            {
                case 0:
                    musicQualityText.text = "Normal";
                    musicQualityTextMobile.text = "Normal";
                    break;
                case 1:
                    musicQualityText.text = "High";
                    musicQualityTextMobile.text = "High";
                    break;
                case 2:
                    musicQualityText.text= "YMFM Test";
                    musicQualityTextMobile.text = "YMFM Test";
                    break;
            }
        }

        public void OnConfirmConfig()
        {
            StartCoroutine(gm.DoFadeAndFunction(GotoMainFromConfigConfirm, configButton));
        }

        void GotoMainFromConfigConfirm()
        {
#if UNITY_STANDALONE
            configMenuPC.SetActive(false);
#elif UNITY_EDITOR
            configMenuPC.SetActive(false);
#elif UNITY_ANDROID
            configMenuMobile.SetActive(false);
#elif UNITY_IOS
            configMenuMobile.SetActive(false);
#endif
            mainMenu.SetActive(true);
            BGSprite.color = new Color32(0xCE, 0x6B, 0xFF, 0xFF);
            menuState = 0;
            gm.WriteConfig();
#if UNITY_STANDALONE
            if (gm.dMode == FullScreenMode.Windowed) Screen.SetResolution(320 * gm.resolutionMultiplier, 240 * gm.resolutionMultiplier, FullScreenMode.Windowed);
            else Screen.SetResolution(Screen.resolutions[gm.chosenResolution].width, Screen.resolutions[gm.chosenResolution].height, gm.dMode, Screen.resolutions[gm.chosenResolution].refreshRate);
#endif
            audioMixer.SetFloat("BGMVol", (gm.BGMVolume <= 0) ? -80f : Mathf.Log10(((float)gm.BGMVolume) / 100f) * 40f);
            audioMixer.SetFloat("SFXVol", (gm.SFXVolume <= 0) ? -80f : Mathf.Log10(((float)gm.SFXVolume) / 100f) * 40f);
        }

        public void OnRetractFromConfig()
        {
            StartCoroutine(gm.DoFadeAndFunction(GotoMainFromConfigRevert, configButton));
        }

        void GotoMainFromConfigRevert()
        {
#if UNITY_STANDALONE
            configMenuPC.SetActive(false);
#elif UNITY_EDITOR
            configMenuPC.SetActive(false);
#elif UNITY_ANDROID
            configMenuMobile.SetActive(false);
#elif UNITY_IOS
            configMenuMobile.SetActive(false);
#endif
            mainMenu.SetActive(true);
            BGSprite.color = new Color32(0xCE, 0x6B, 0xFF, 0xFF);
            menuState = 0;
            gm.resolutionMultiplier = oldResMul;
            gm.BGMVolume = oldBGMVol;
            gm.SFXVolume = oldSFXVol;
            gm.WriteConfig();
            audioMixer.SetFloat("BGMVol", (gm.BGMVolume <= 0) ? -80f : Mathf.Log10(((float)gm.BGMVolume) / 100f) * 40f);
            audioMixer.SetFloat("SFXVol", (gm.SFXVolume <= 0) ? -80f : Mathf.Log10(((float)gm.SFXVolume) / 100f) * 40f);
        }

        public void OnControlRebindSelected()
        {
            configMenuPC.SetActive(false);
            controlConfigMenu.SetActive(true);
            eventSystem.SetSelectedGameObject(returnFromControlConfigButton);
            menuState = 6;
        }

        public void OnRetractFromControlRebind()
        {
            controlConfigMenu.SetActive(false);
            configMenuPC.SetActive(true);
            eventSystem.SetSelectedGameObject(controlConfigButton);
            menuState = 5;
        }

        public void OnResetScores()
        {
#if UNITY_STANDALONE
            resetScoresConfirmation.SetActive(true);
#elif UNITY_EDITOR
            resetScoresConfirmation.SetActive(true);
#elif UNITY_ANDROID
            resetScoresConfirmationMobile.SetActive(true);
#elif UNITY_IOS
            resetScoresConfirmationMobile.SetActive(true);
#endif
            StartCoroutine(AwatingScoreResetConfirmation());
        }

        public IEnumerator AwatingScoreResetConfirmation()
        {
            float confirmTimeLeft = 10f;
            yield return new WaitForSecondsRealtime(0.05f);
            awaitingConfirmation = true;
            while (true)
            {
                if (pInput.currentActionMap.FindAction("Accept").triggered || acceptTButton.isDown)
                {
                    HighScoreGroup.WriteDefaultScoreDataToFile(gm.appBaseDirectory);
#if UNITY_STANDALONE
                    resetScoresConfirmation.SetActive(false);
#elif UNITY_EDITOR
                    resetScoresConfirmation.SetActive(false);
#elif UNITY_ANDROID
                    resetScoresConfirmationMobile.SetActive(false);
#elif UNITY_IOS
                    resetScoresConfirmationMobile.SetActive(false);
#endif
                    gm.ReloadScores();
                    awaitingConfirmation = false;
                    yield break;
                }
                else if (confirmTimeLeft < 0f || declineTButton.isDown || dpadUpTButton.isDown || dpadDownTButton.isDown || dpadLeftTButton.isDown || dpadRightTButton.isDown || mNavi.triggered || pInput.currentActionMap.FindAction("Decline").triggered)
                {
#if UNITY_STANDALONE
                    resetScoresConfirmation.SetActive(false);
#elif UNITY_EDITOR
                    resetScoresConfirmation.SetActive(false);
#elif UNITY_ANDROID
                    resetScoresConfirmationMobile.SetActive(false);
#elif UNITY_IOS
                    resetScoresConfirmationMobile.SetActive(false);
#endif
                    awaitingConfirmation = false;
                    yield break;
                }
                confirmTimeLeft -= Time.unscaledDeltaTime;
                yield return null;
            }
        }

        public void OnQuitSelected()
        {
#if UNITY_EDITOR
            UnityEditor.EditorApplication.ExitPlaymode();
#else
            Application.Quit();
#endif
        }

        public void OnDifficultySelected(int diffLevel)
        {
            difficultyMenu.SetActive(false);
            BGMMenu.SetActive(true);
            eventSystem.SetSelectedGameObject(song1Button);
            BGSprite.color = new Color32(0x8C, 0xCE, 0xFF, 0xFF);
            menuState = 2;
            gm.currentTrackNum = diffLevel;
            song1Text.text = gm.BTMSource.GetSongName(1);
            song2Text.text = gm.BTMSource.GetSongName(2);
            song3Text.text = gm.BTMSource.GetSongName(3);
            song4Text.text = gm.BTMSource.GetSongName(4);
        }

        public void OnRetractFromDifficulty()
        {
            StartCoroutine(gm.DoFadeAndFunction(GotoMainFromStart, startButton));
        }
        
        void GotoMainFromStart()
        {
            difficultyMenu.SetActive(false);
            mainMenu.SetActive(true);
            BGSprite.color = new Color32(0xCE, 0x6B, 0xFF, 0xFF);
            menuState = 0;
        }

        public void OnGameSongSelected(int songNum)
        {
            StartCoroutine(gm.BTMSource.SongFade(1.5f));
            StartCoroutine(gm.DoFadeAndFunction(GotoGameFromStart, songNum, null, 0.25f, 1f, 1f));
        }

        void GotoGameFromStart(int songNum)
        {
            BGMMenu.SetActive(false);
            menuUIRoot.SetActive(false);
            gm.BTMSource.StopSong();
            gm.BTMSource.SetSongVolume(1.0f);
            gm.StartGame(songNum);
        }

        public void OnRetractFromGameSong()
        {
            BGMMenu.SetActive(false);
            difficultyMenu.SetActive(true);
            eventSystem.SetSelectedGameObject(easyButton);
            BGSprite.color = new Color32(0xFF, 0xB5, 0x63, 0xFF);
            menuState = 1;
        }
    }
}