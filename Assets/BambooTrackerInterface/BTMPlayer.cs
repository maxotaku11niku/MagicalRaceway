﻿using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BTMPlayer : MonoBehaviour
{
    [DllImport("__Internal", CharSet = CharSet.Unicode)] //All of these methods are externally linked
    private static extern void advanceTick();
    [DllImport("__Internal", CharSet = CharSet.Unicode)]
    private static extern void InitialisePlayerModuleData([MarshalAs(UnmanagedType.LPArray)] byte[] modData, uint dataSize);
    [DllImport("__Internal", CharSet = CharSet.Unicode)]
    private static extern void DestroyEmulator();
    [DllImport("__Internal", CharSet = CharSet.Unicode)]
    private static extern void playSong(int songNum);
    [DllImport("__Internal", CharSet = CharSet.Unicode)]
    private static extern void stopSong();
    [DllImport("__Internal", CharSet = CharSet.Unicode)]
    private static extern void setVolume(int volPercent);
    [DllImport("__Internal", CharSet = CharSet.Unicode)]
    private static extern unsafe short* getStreamData(uint numSamples);
    [DllImport("__Internal", CharSet = CharSet.Unicode)]
    private static extern int getCurrentNote(int channel);
    [DllImport("__Internal", CharSet = CharSet.Unicode)]
    private static extern unsafe byte* getSongName(int songNum);
    [DllImport("__Internal", CharSet = CharSet.Unicode)]
    private static extern int getNumSongs();
    [DllImport("__Internal", CharSet = CharSet.Unicode)]
    private static extern int getCurrentBPM();
    [DllImport("__Internal", CharSet = CharSet.Unicode)]
    private static extern int getCurrentSpeed();
    [DllImport("__Internal", CharSet = CharSet.Unicode)]
    private static extern int getTickInStep();
    [DllImport("__Internal", CharSet = CharSet.Unicode)]
    private static extern int getRegister(int addr);

    public SplineTest.GameMaster gm;
    public SplineTest.MusicRoom musRoom;
    public BambooTrackerModule currentModule;
    public int numSongs;
    AudioClip audioBuffer;
    AudioSource audioOut;
    float[] backData; //Put the sample data we get from the emulator here before transfer to the buffer
    float swapTime;
    float countTime;
	public bool hasStoppedSong;
    int part;
    int writePos;
    int lowerReadBound;
    int upperReadBound;
    bool isBTMPluginLoaded = false;
    readonly int toleranceBuffer = 1024;
    readonly int buffersize = 5546;
    //readonly int buffersize = 2048;
    readonly int samplerate = 55466; //Weird, I know
    readonly int[] samplereq = new int[] { 924, 925, 924, 925, 924,
                                           925, 924, 924, 925, 924,
                                           925, 924, 925, 924, 924,
                                           925, 924, 925, 924, 925,
                                           924, 924, 925, 924, 925,
                                           924, 925, 924, 924, 925 }; //55466/60 is not an integer

    public void InitBTMPlayer()
    {
        swapTime = 1f/60f; //Synced with the emulation tick frequency
        isBTMPluginLoaded = true;
		hasStoppedSong = false;
        try
        {
            InitialisePlayerModuleData(currentModule.data, (uint)currentModule.data.Length);
        }
        catch(EntryPointNotFoundException e) //Bad linkage means we don't run the soundchip emulator, so no music :(
        {
            Debug.LogError(e.Message);
            Debug.LogError("BTM player plugin not loaded! No music will be heard!");
            isBTMPluginLoaded = false;
            return;
        }
        numSongs = GetNumberOfSongsInCurrentModule();
        audioBuffer = AudioClip.Create("audioBuffer", buffersize, 2, samplerate, false);
        audioOut = GetComponent<AudioSource>();
        audioOut.clip = audioBuffer;
        audioOut.Play();
        backData = new float[1850];
        countTime = 0.05f;
        part = 0;
        writePos = buffersize/2; //Start writing in the middle
        InvokeRepeating("CopyToStream", 0.1f, 0.016666666666666666f);
    }

    void SampleGet()
    {
        unsafe //oooOOoOoo, uNsAfE cOnTeXt
        {
            short* shortPtr = getStreamData((uint)(samplereq[part] * 2));
            for (int i = 0; i < samplereq[part] * 2; i++)
            {
                backData[i] = shortPtr[i] * 0.000030517578125f; //2^-15, multiplication is faster than division.
            }
            audioBuffer.SetData(backData, writePos);
        }
        writePos += samplereq[part];
        writePos %= buffersize; //Wrapping
        part++;
        part %= samplereq.Length;      
    }

    void CopyToStream()
    {
        if(!isBTMPluginLoaded) return;
        lowerReadBound = audioOut.timeSamples - toleranceBuffer;
        if (lowerReadBound < 0) lowerReadBound += buffersize;
        upperReadBound = (audioOut.timeSamples + toleranceBuffer) % buffersize;
        if (lowerReadBound > upperReadBound) //If the read position is getting too close to the write position, then we reset the write position to rectify this
        {
            if(!(writePos <= lowerReadBound && writePos >= upperReadBound))
            {
                audioOut.timeSamples = 0;
                writePos = buffersize / 2;
            }
        }
        else
        {
            if(writePos >= lowerReadBound && writePos <= upperReadBound)
            {
                audioOut.timeSamples = 0;
                writePos = buffersize / 2;
            }
        }
        advanceTick();
        SampleGet();
        musRoom.UpdateNotes();
    }

    public void EndOperations()
    {
        if (!isBTMPluginLoaded) return;
        DestroyEmulator();
    }

    public void PlaySong(int songNum)
    {
        if (!isBTMPluginLoaded) return;
        hasStoppedSong = true;
        try 
        {
            playSong(songNum);
            musRoom.UpdateNotes();
        }
        catch(EntryPointNotFoundException e)
        {
            Debug.LogWarning(e.Message);
            Debug.LogWarning("BTM player plugin not loaded!");
        }
    }
    
    public void StopSong()
    {
        if (!isBTMPluginLoaded) return;
        hasStoppedSong = true;
        try
        {
            stopSong();
        }
        catch (EntryPointNotFoundException e)
        {
            Debug.LogWarning(e.Message);
            Debug.LogWarning("BTM player plugin not loaded!");
        }
    }

    public void SetSongVolume(float volume)
    {
        if (!isBTMPluginLoaded) return;
        int passInt = Mathf.RoundToInt(volume*100f);
        try
        {
            setVolume(passInt);
        }
        catch (EntryPointNotFoundException e)
        {
            Debug.LogWarning(e.Message);
            Debug.LogWarning("BTM player plugin not loaded!");
        }
    }

    public IEnumerator SongFade(float time, float startVol = 1f, float endVol = 0f) //Done at the emulator level to keep it separate from the user-defined BGM level
    {
        if (!isBTMPluginLoaded) yield break;
        float fadeCounter = 0f;
        while(fadeCounter <= time)
        {
            SetSongVolume(Mathf.Lerp(startVol, endVol, fadeCounter / time));
            fadeCounter += Time.unscaledDeltaTime;
            yield return null;
        }
        SetSongVolume(endVol);
        yield break;
    }
    
    public int GetNumberOfSongsInCurrentModule()
    {
        if (!isBTMPluginLoaded) return 1;
        int tempInt = 1;
        try
        {
            tempInt = getNumSongs();
        }
        catch (EntryPointNotFoundException e)
        {
            Debug.LogWarning(e.Message);
            Debug.LogWarning("BTM player plugin not loaded!");
        }
        return tempInt;
    }

    public int GetCurrentNote(int channel)
    {
        if (!isBTMPluginLoaded) return -1;
        int tempInt = -1;
        try
        {
            tempInt = getCurrentNote(channel);
        }
        catch (EntryPointNotFoundException e)
        {
            Debug.LogWarning(e.Message);
            Debug.LogWarning("BTM player plugin not loaded!");
        }
        return tempInt;
    }
	
	public int GetCurrentBPM()
	{
        if (!isBTMPluginLoaded) return 32;
        int tempInt = 32;
		try
		{
			tempInt = getCurrentBPM();
		}
		catch (EntryPointNotFoundException e)
        {
            Debug.LogWarning(e.Message);
            Debug.LogWarning("BTM player plugin not loaded!");
        }
		return tempInt;
	}
	
	public int GetCurrentSpeed()
	{
        if (!isBTMPluginLoaded) return 6;
        int tempInt = 6;
		try
		{
			tempInt = getCurrentSpeed();
		}
		catch (EntryPointNotFoundException e)
        {
            Debug.LogWarning(e.Message);
            Debug.LogWarning("BTM player plugin not loaded!");
        }
		return tempInt;
	}
	
	public int GetTickInStep()
	{
        if (!isBTMPluginLoaded) return 0;
		int tempInt = 0;
		try
		{
			tempInt = getTickInStep();
		}
		catch (EntryPointNotFoundException e)
        {
            Debug.LogWarning(e.Message);
            Debug.LogWarning("BTM player plugin not loaded!");
        }
		return tempInt;
	}

    /*
    OPNA does have the ability to allow reads from registers, but not all of them.
    This utilises a fake backing store.
    */
    public int GetRegister(int addr)
    {
        if (!isBTMPluginLoaded) return 0;
        int tempInt = 0;
        try
        {
            tempInt = getRegister(addr);
        }
        catch (EntryPointNotFoundException e)
        {
            Debug.LogWarning(e.Message);
            Debug.LogWarning("BTM player plugin not loaded!");
        }
        return tempInt;
    }
    
    public string GetSongName(int songNum) //Unfortunately, this one will cause an exception if called without the proper linkage
    {
        if (!isBTMPluginLoaded) return "";
        unsafe
        {
            byte* inputCharList = getSongName(songNum); //Naughty C-style string handling
            List<char> realCharList = new List<char>();
            for (int i = 0; i < 256; i++)
            {
                if (inputCharList[i] == 0x00) break; //Null-termination
                realCharList.Add((char)inputCharList[i]);
            }
            return new String(realCharList.ToArray());
        }
    }
}
