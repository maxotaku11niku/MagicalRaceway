using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;

namespace SplineTest
{
    public class MusicRoom : MonoBehaviour
    {
        public GameMaster gm;
        public MenuMaster mm;
        public TouchButton acceptTButton;
        public TouchButton declineTButton;
        public TouchButton dpadUpTButton;
        public TouchButton dpadDownTButton;
        public TouchButton dpadLeftTButton;
        public TouchButton dpadRightTButton;
        public Text songTitleText;
        public Text musicCommentText;
        [TextArea(5,10)]
        public string[] musicComments;
        public ChannelPianoControl[] pianoChannels;
        public BTMPlayer btmPlayer;
        InputAction mNavi;
        InputAction mConfirm;
        int channelNum;
        int currentSelectedSongNum;
        int currentPlayingSongNum;

        void Awake()
        {
            currentSelectedSongNum = 0;
            currentPlayingSongNum = 0;
            mNavi = mm.pInput.currentActionMap.FindAction("Menu Navigation");
            mConfirm = mm.pInput.currentActionMap.FindAction("Accept");
            songTitleText.text = (currentSelectedSongNum + 1).ToString() + ": " + btmPlayer.GetSongName(currentSelectedSongNum); //Song names are stored in the module files
            if (mm.isOstBundled) musicCommentText.text = musicComments[currentSelectedSongNum];
            else musicCommentText.text = "OST not bundled! Be careful not to share this testing version!"; //Displays only when testing the emulation and piano display. Must be manually set
        }
        
        void OnEnable()
        {
            currentSelectedSongNum = 0;
            currentPlayingSongNum = 0;
            songTitleText.color = new Color32(0x4A, 0xFF, 0x4A, 0xFF);
            songTitleText.text = (currentSelectedSongNum + 1).ToString() + ": " + btmPlayer.GetSongName(currentSelectedSongNum);
            if (mm.isOstBundled) musicCommentText.text = musicComments[currentSelectedSongNum];
            else musicCommentText.text = "OST not bundled! Be careful not to share this testing version!";
        }
        
        void OnDisable()
        {
            btmPlayer.PlaySong(0);
            if (mm.isOstBundled) musicCommentText.text = musicComments[0];
            else musicCommentText.text = "OST not bundled! Be careful not to share this testing version!";
        }
		

        void Update()
        {
            if(mNavi.triggered || dpadLeftTButton.isDown || dpadRightTButton.isDown) //Selecting a song
            {
#if UNITY_EDITOR
                currentSelectedSongNum += (int)(mNavi.ReadValue<Vector2>().x);
#elif UNITY_STANDALONE
                currentSelectedSongNum += (int)(mNavi.ReadValue<Vector2>().x);
#elif UNITY_ANDROID
                if (dpadRightTButton.isDown)
                {
                    currentSelectedSongNum++;
                }
                else if (dpadLeftTButton.isDown)
                {
                    currentSelectedSongNum--;
                }
#elif UNITY_IOS
                if (dpadRightTButton.isDown)
                {
                    currentSelectedSongNum++;
                }
                else if (dpadLeftTButton.isDown)
                {
                    currentSelectedSongNum--;
                }
#endif
                if (currentSelectedSongNum >= btmPlayer.numSongs) currentSelectedSongNum = 0;
                else if (currentSelectedSongNum < 0) currentSelectedSongNum = btmPlayer.numSongs - 1;
                songTitleText.text = (currentSelectedSongNum + 1).ToString() + ": " + btmPlayer.GetSongName(currentSelectedSongNum);
                if(currentSelectedSongNum == currentPlayingSongNum) songTitleText.color = new Color32(0x4A, 0xFF, 0x4A, 0xFF); //Set title colour to a greenish colour if the song is currently playing
                else songTitleText.color = new Color32(0xFF, 0xAD, 0xC6, 0xFF);
            }
            if(mConfirm.triggered || acceptTButton.isDown) //Playing a song
            {
                btmPlayer.PlaySong(currentSelectedSongNum);
                currentPlayingSongNum = currentSelectedSongNum;
                songTitleText.color = new Color32(0x4A, 0xFF, 0x4A, 0xFF);
                if (mm.isOstBundled) musicCommentText.text = musicComments[currentSelectedSongNum];
                else musicCommentText.text = "OST not bundled! Be careful not to share this testing version!";
            }
			if(btmPlayer.hasStoppedSong)
			{
				btmPlayer.hasStoppedSong = false;
				for (int i = 0; i < 9; i++)
				{
					channelNum = i;
					pianoChannels[i].SetNote(-2);
				}
			}
			else if(btmPlayer.GetTickInStep() == 0) //Only change notes on step advance
			{
				for (int i = 0; i < 9; i++)
				{
					channelNum = i;
					pianoChannels[i].SetNote(btmPlayer.GetCurrentNote(channelNum));
				}
			}
        }
    }
}