using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SplineTest
{
    public class SoundQueuer : MonoBehaviour
    {
        public AudioClip[] clips;
        public AudioSource source;

        public void Play(int clipNum, bool loop = true)
        {
            if (source.clip == clips[clipNum] && source.isPlaying) return;
            source.clip = clips[clipNum];
            source.loop = loop;
            source.Play();
        }
        
        public void SetPitch(float pitch)
        {
            source.pitch = pitch;
        }

        public void PlayOneShot(int clipNum)
        {
            source.PlayOneShot(clips[clipNum]);
        }
        
        public void PlayOneShotVariableVolume(int clipNum, float vol)
        {
            source.PlayOneShot(clips[clipNum], vol);
        }

        public void Stop()
        {
            source.Stop();
        }

        public void Pause()
        {
            source.Pause();
        }

        public void Unpause()
        {
            source.UnPause();
        }
    }
}