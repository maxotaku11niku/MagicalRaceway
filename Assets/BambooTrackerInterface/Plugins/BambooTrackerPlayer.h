#pragma once
#include <iterator>
#include "opna_controller.h"
#include "playback.h"
#include "tick_counter.h"
#include "instruments_manager.h"
#include "btm_io.h"
#include "precise_timer.h"

extern "C"
{
	void advanceTick();
	void InitialisePlayerModuleData(const uint8_t* modData, const size_t dataSize);
	void DestroyEmulator();
	void playSong(int songNum);
	void stopSong();
	void setVolume(int volPercent);
	int16_t* getStreamData(size_t numSamples);
	int getNumSongs();
	int getCurrentBPM();
	int getCurrentSpeed();
	int getTickInStep();
	int getCurrentNote(int channel);
	int getRegister(int addr);
	char* getSongName(int songNum);
}