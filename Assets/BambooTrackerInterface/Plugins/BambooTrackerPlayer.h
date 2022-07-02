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
	#ifdef _MSC_VER
	__declspec(dllexport) void __stdcall advanceTick();
	__declspec(dllexport) void __stdcall InitialisePlayerModuleData(const uint8_t* modData, const size_t dataSize);
	__declspec(dllexport) void __stdcall DestroyEmulator();
	__declspec(dllexport) void __stdcall playSong(int songNum);
	__declspec(dllexport) void __stdcall stopSong();
	__declspec(dllexport) void __stdcall setVolume(int volPercent);
	__declspec(dllexport) int16_t* __stdcall getStreamData(size_t numSamples);
	__declspec(dllexport) int __stdcall getNumSongs();
	__declspec(dllexport) int __stdcall getCurrentBPM();
	__declspec(dllexport) int __stdcall getCurrentSpeed();
	__declspec(dllexport) int __stdcall getTickInStep();
	__declspec(dllexport) int __stdcall getCurrentNote(int channel);
	__declspec(dllexport) int __stdcall getRegister(int addr);
	__declspec(dllexport) char* __stdcall getSongName(int songNum);
	#else
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
	#endif
}