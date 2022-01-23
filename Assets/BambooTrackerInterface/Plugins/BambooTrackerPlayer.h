#pragma once
#include <iterator>
#include "opna_controller.h"
#include "playback.h"
#include "tick_counter.h"
#include "instruments_manager.h"
#include "btm_io.h"
#include "precise_timer.h"

extern "C" void advanceTick();
extern "C" void InitialisePlayerModuleData(int emu, const uint8_t * modData, const size_t dataSize);
extern "C" void DestroyEmulator();
extern "C" void playSong(int songNum);
extern "C" void stopSong();
extern "C" void setVolume(int volPercent);
extern "C" int16_t* getStreamData(size_t numSamples);
extern "C" int getNumSongs();
extern "C" int getCurrentBPM();
extern "C" int getCurrentSpeed();
extern "C" int getTickInStep();
extern "C" int getCurrentNote(int channel);
extern "C" char* getSongName(int songNum);