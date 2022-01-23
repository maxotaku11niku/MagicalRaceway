using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace SplineTest
{
    public class ChannelPianoControl : MonoBehaviour
    {
        public Sprite[] pianoSprites; //Sprites representing all the possible notes in an octave. Each channel permits only one note at a time
        public Image[] octaveImages; //Actual images for each sprite
		int previousNote;
		bool breakUpIdenticalNote = false;
		bool endBreak = false;

        public void SetNote(int note)
        {
			if(note < -1) //Not a playing note
			{
				previousNote = -1;
				for(int i = 0; i < 8; i++)
				{
					octaveImages[i].sprite = pianoSprites[12];
				}
			}
			else if(note == -1) //No changes this step
			{
				return;
			}
			else if(note == previousNote)
			{
				breakUpIdenticalNote = true;
			}
			else
			{
				previousNote = note;
				for(int i = 0; i < 8; i++) //Iterate over all 8 octaves
				{
					if (note >= i * 12 && note < (i + 1) * 12) octaveImages[i].sprite = pianoSprites[note % 12];
					else octaveImages[i].sprite = pianoSprites[12];
				}
			}
        }
		
		void Update()
		{
			if(endBreak)
			{
				for(int i = 0; i < 8; i++)
				{
					if (previousNote >= i * 12 && previousNote < (i + 1) * 12) octaveImages[i].sprite = pianoSprites[previousNote % 12];
					else octaveImages[i].sprite = pianoSprites[12];
				}
				breakUpIdenticalNote = false;
				endBreak = false;
			}
			else if(breakUpIdenticalNote) //Short period of showing no note to make it clear the same note has been retriggered
			{
				for(int i = 0; i < 8; i++)
				{
					octaveImages[i].sprite = pianoSprites[12];
				}
				endBreak = true;
			}
		}
    }
}