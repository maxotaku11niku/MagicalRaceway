#pragma once
#include "chip_def.h"
#include "opnaymfm.h"

void ymfm_set_ay_emu_core(uint8_t Emulator);
int device_start_ymfm(uint8_t ChipID, int clock, uint8_t AYDisable, uint8_t AYFlags, int* AYrate, uint32_t dramSize);
void device_stop_ymfm(uint8_t ChipID);
void device_reset_ymfm(uint8_t ChipID);
void ymfm_control_port_a_w(uint8_t ChipID, uint32_t offset, uint8_t data);
void ymfm_control_port_b_w(uint8_t ChipID, uint32_t offset, uint8_t data);
void ymfm_data_port_a_w(uint8_t ChipID, uint32_t offset, uint8_t data);
void ymfm_data_port_b_w(uint8_t ChipID, uint32_t offset, uint8_t data);
uint8_t ymfm_read_port_r(uint8_t ChipID, uint32_t offset);
void ymfm_stream_update(uint8_t ChipID, sample **outputs, int samples);
void ymfm_stream_update_ay(uint8_t ChipID, sample **outputs, int samples);

extern struct intf2608 ymfm_intf2608;