/*
YMFM interface to Bamboo Tracker code
*/
#include "ymfmintf2608.h"

FM::OPNA* ChipList[2];
uint32_t currOffset;
sample* SSGOutput;

void ymfm_set_ay_emu_core(uint8_t Emulator)
{
    return;
}

int device_start_ymfm(uint8_t ChipID, int clock, uint8_t AYDisable, uint8_t AYFlags, int* AYrate, uint32_t dramSize)
{
    FM::OPNA* newChip = new FM::OPNA();
    newChip->Init(clock, clock/144);
    *AYrate = clock/144;
    ChipList[ChipID] = newChip;
    return clock/144;
}

void device_stop_ymfm(uint8_t ChipID)
{
    FM::OPNA* chip = ChipList[ChipID];
    delete chip;
    ChipList[ChipID] = nullptr;
    return;
}

void device_reset_ymfm(uint8_t ChipID)
{
    FM::OPNA* chip = ChipList[ChipID];
    chip->Reset();
    return;
}

void ymfm_control_port_a_w(uint8_t ChipID, uint32_t offset, uint8_t data)
{
    FM::OPNA* chip = ChipList[ChipID];
    currOffset = data;
    return;
}

void ymfm_control_port_b_w(uint8_t ChipID, uint32_t offset, uint8_t data)
{
    FM::OPNA* chip = ChipList[ChipID];
    currOffset = data + 0x100;
    return;
}

void ymfm_data_port_a_w(uint8_t ChipID, uint32_t offset, uint8_t data)
{
    FM::OPNA* chip = ChipList[ChipID];
    chip->SetReg(offset, data);
    return;
}

void ymfm_data_port_b_w(uint8_t ChipID, uint32_t offset, uint8_t data)
{
    FM::OPNA* chip = ChipList[ChipID];
    chip->SetReg(offset, data);
    return;
}

uint8_t ymfm_read_port_r(uint8_t ChipID, uint32_t offset)
{
    FM::OPNA* chip = ChipList[ChipID];
    return chip->GetReg(offset);
}

void ymfm_stream_update(uint8_t ChipID, sample **outputs, int samples)
{
    FM::OPNA* chip = ChipList[ChipID];
    chip->GetFMSamples(outputs[0], outputs[1], samples);
    return;
}

void ymfm_stream_update_ay(uint8_t ChipID, sample **outputs, int samples)
{
    FM::OPNA* chip = ChipList[ChipID];
    chip->GetSSGSamples(outputs[0], outputs[1], samples);
    return;
}

struct intf2608 ymfm_intf2608 =
{
	/*.set_ay_emu_core =*/ &ymfm_set_ay_emu_core,
	/*.device_start =*/ &device_start_ymfm,
	/*.device_stop =*/ &device_stop_ymfm,
	/*.device_reset =*/ &device_reset_ymfm,
	/*.control_port_a_w =*/ &ymfm_control_port_a_w,
	/*.control_port_b_w =*/ &ymfm_control_port_b_w,
	/*.data_port_a_w =*/ &ymfm_data_port_a_w,
	/*.data_port_b_w =*/ &ymfm_data_port_b_w,
	/*.read_port_r =*/ &ymfm_read_port_r,
	/*.stream_update =*/ &ymfm_stream_update,
	/*.stream_update_ay =*/ &ymfm_stream_update_ay,
};