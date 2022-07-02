/*
* Bamboo Tracker Player
* A library for playing .btm files
* Maxim Hoxha 2021-2022
* Most of the code is not mine, copyright notices have been retained
* There have been many modifications to other files, though.
*/

#include "BambooTrackerPlayer.h"

//A lot of this code was taken from source files in Bamboo Tracker that were not included

std::shared_ptr<OPNAController> chipController;
std::shared_ptr<InstrumentsManager> instManager;
std::shared_ptr<TickCounter> tickCounter;
std::shared_ptr<PlaybackManager> pbManager;
std::shared_ptr<Module> currentModule;
//std::shared_ptr<PreciseTimer> tickTimer;
Song* currentSong;
SongType songType;
Track* track;
Pattern* pattern;
Step* actualStep;
int currentSongNum;
int currentNotes[18];
int chNum;
int ticksToNextStep;
bool isSongPlaying = false;
int16_t containerList[16384];
char charList[256];

std::shared_ptr<Module> loadModule(const uint8_t *byteArray, const size_t size)
{
	std::shared_ptr<Module> mod = std::make_shared<Module>();
	io::BinaryContainer container;
	std::vector<uint8_t> byteVector;
	for (int i = 0; i < size; i++)
	{
		byteVector.push_back(byteArray[i]);
	}
	std::move(std::begin(byteVector), std::end(byteVector), std::back_inserter(container));
	io::ModuleIO::getInstance().loadModule(container, mod, instManager);
	tickCounter->setInterruptRate(mod->getTickFrequency());
	return mod;
}

void updateCurrentNotes()
{
	int order = pbManager->getPlayingOrderNumber();
	int step = pbManager->getPlayingStepNumber();
	int noteNum;
	for (int ch = 0; ch < chNum; ch++)
	{
		track = &(currentSong->getTrack(ch));
		pattern = &(track->getPatternFromOrderNumber(order));
		actualStep = &(pattern->getStep(step));
		noteNum = actualStep->getNoteNumber();
		currentNotes[ch] = noteNum;
	}
}

inline void resetCurrentNotes()
{
	for (int i = 0; i < 18; i++)
	{
		currentNotes[i] = -2; //Make all the notes key-off
	}
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) void __stdcall advanceTick()
#else
extern "C" void advanceTick()
#endif
{
	if (!isSongPlaying) return;
	ticksToNextStep = pbManager->streamCountUp();
	updateCurrentNotes();
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) void __stdcall InitialisePlayerModuleData(const uint8_t *modData, const size_t dataSize)
#else
extern "C" void InitialisePlayerModuleData(const uint8_t *modData, const size_t dataSize)
#endif
{
	isSongPlaying = false;
	chipController = std::make_shared<OPNAController>(7987200, 55466, 40);
	instManager = std::make_shared<InstrumentsManager>(false);
	tickCounter = std::make_shared<TickCounter>();
	currentModule = loadModule(modData, dataSize);
	//pbManager = std::make_unique<PlaybackManager>(chipController, instManager, tickCounter, currentModule, false);
	pbManager = std::unique_ptr<PlaybackManager>(new PlaybackManager(chipController, instManager, tickCounter, currentModule, false));
	chipController->setMasterVolume(100);
	chipController->setMasterVolumeFM(currentModule->getCustomMixerFMLevel());
	chipController->setMasterVolumeSSG(currentModule->getCustomMixerSSGLevel());
	chipController->clearSamplesADPCM();
	std::vector<int> idcs = instManager->getSampleADPCMValidIndices();
	for (auto sampNum : idcs)
	{
		size_t startAddr, stopAddr;
		if (chipController->storeSampleADPCM(instManager->getSampleADPCMRawSample(sampNum), startAddr, stopAddr)) {
			instManager->setSampleADPCMStartAddress(sampNum, startAddr);
			instManager->setSampleADPCMStopAddress(sampNum, stopAddr);
		}
	}
	//tickTimer = std::make_unique<PreciseTimer>();
	//tickTimer->setFunction(advanceTick);
	//tickTimer->setInterval(1000000/currentModule->getTickFrequency());
	resetCurrentNotes();
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) void __stdcall DestroyEmulator()
#else
extern "C" void DestroyEmulator()
#endif
{
	pbManager.~shared_ptr();
	currentModule.~shared_ptr();
	tickCounter.~shared_ptr();
	instManager.~shared_ptr();
	chipController.~shared_ptr();
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) void __stdcall playSong(int songNum)
#else
extern "C" void playSong(int songNum)
#endif
{
	resetCurrentNotes();
	//tickTimer->stop();
	auto& song = currentModule->getSong(songNum);
	pbManager->setSong(currentModule, songNum);
	currentSongNum = songNum;
	chipController->reset();
	chipController->setMode(song.getStyle().type);
	tickCounter->resetCount();
	tickCounter->setTempo(song.getTempo());
	tickCounter->setSpeed(song.getSpeed());
	tickCounter->setGroove(currentModule->getGroove(song.getGroove()));
	tickCounter->setGrooveState(song.isUsedTempo() ? GrooveState::Invalid : GrooveState::ValidByGlobal);
	currentSong = &song;
	songType = currentSong->getStyle().type;
	if (songType == SongType::Standard) chNum = 15;
	else if (songType == SongType::FM3chExpanded) chNum = 18;
	pbManager->startPlayFromStart();
	isSongPlaying = true;
	//tickTimer->start();
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) void __stdcall stopSong()
#else
extern "C" void stopSong()
#endif
{
	pbManager->stopPlaySong();
	isSongPlaying = false;
	//tickTimer->stop();
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) void __stdcall setVolume(int volPercent)
#else
extern "C" void setVolume(int volPercent)
#endif
{
	chipController->setMasterVolume(volPercent);
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) int16_t* __stdcall getStreamData(size_t numSamples)
#else
extern "C" int16_t* getStreamData(size_t numSamples)
#endif
{
	int16_t* container = containerList;
	chipController->getStreamSamples(container, numSamples/2); //Stereo, although OPNA is quite bad at stereo
	return container;
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) int __stdcall getNumSongs()
#else
extern "C" int getNumSongs()
#endif
{
	return currentModule->getSongCount();
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) int __stdcall getCurrentBPM()
#else
extern "C" int getCurrentBPM()
#endif
{
	return tickCounter->getTempo();
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) int __stdcall getCurrentSpeed()
#else
extern "C" int getCurrentSpeed()
#endif
{
	return tickCounter->getSpeed();
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) int __stdcall getTickInStep()
#else
extern "C" int getTickInStep()
#endif
{
	return ticksToNextStep;
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) int __stdcall getCurrentNote(int channel)
#else
extern "C" int getCurrentNote(int channel)
#endif
{
	if (channel >= 18) channel = 17;
	else if (channel < 0) channel = 0;
	return currentNotes[channel];
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) int __stdcall getRegister(int addr)
#else
extern "C" int getRegister(int addr)
#endif
{
	return chipController->debugGetRegister(addr);
}

#ifdef _MSC_VER
extern "C" __declspec(dllexport) char* __stdcall getSongName(int songNum)
#else
extern "C" char* getSongName(int songNum)
#endif
{
	std::string titleString = currentModule->getSong(songNum).getTitle();
	char* charlist = charList;
	const char* stringlist = titleString.c_str();
	for (int i = 0; i < 256; i++)
	{
		charlist[i] = stringlist[i];
		if (stringlist[i] == (char)0x00) break;
	}
	return charlist;
}