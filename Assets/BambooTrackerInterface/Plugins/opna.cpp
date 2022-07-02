/*
 * Copyright (C) 2018-2020 Rerrah
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#include "opna.h"
#include <cstdint>
#include <algorithm>
#include "ymfmintf2608.h"

namespace chip
{
namespace
{
constexpr double VOL_REDUC_ = 7.5;

enum SoundSourceIndex : int { FM = 0, SSG = 1 };

inline double clamp(double value, double low, double high)
{
	return std::min<double>(std::max<double>(value, low), high);
}
}

size_t OPNA::count_ = 0;

OPNA::OPNA(int clock, int rate, size_t maxDuration, size_t dramSize,
		   std::unique_ptr<AbstractResampler> fmResampler, std::unique_ptr<AbstractResampler> ssgResampler,
		   std::shared_ptr<AbstractRegisterWriteLogger> logger)
	: Chip(count_++, clock, rate, 110933, maxDuration,
		   std::move(fmResampler), std::move(ssgResampler),	// autoRate = 110933: FM internal rate
		   logger),
	  dramSize_(dramSize)
{
	regBack_ = new uint8_t[0x200];
	for(int i = 0; i < 0x200; i++)
	{
		regBack_[i] = 0;
	}

	fprintf(stderr, "Using emulator: YMFM\n"); //Bambootracker does not use this chip emulator; I have been forced to change from the MAME emulator because it is now under GPL, which is not compatible with CC-BY-NC.
	intf_ = &ymfm_intf2608; //Also, 'Nuked' uses some MAME code and is quite demanding anyway, so I can't use that either.
	
	funcSetRate(rate);

	uint8_t EmuCore = 0;
	intf_->set_ay_emu_core(EmuCore);

	uint8_t AYDisable = 0;	// Enable
	uint8_t AYFlags = 0;		// None
	internalRate_[FM] = intf_->device_start(
							id_, clock, AYDisable, AYFlags,
							reinterpret_cast<int*>(&internalRate_[SSG]), dramSize);

	initResampler();

	setVolumeFM(0);
	setVolumeSSG(0);

	reset();
}

OPNA::~OPNA()
{
	intf_->device_stop(id_);

	--count_;
}

void OPNA::reset()
{
	std::lock_guard<std::mutex> lg(mutex_);

	intf_->device_reset(id_);
}

void OPNA::setRegister(uint32_t offset, uint8_t value)
{
	std::lock_guard<std::mutex> lg(mutex_);

	regBack_[offset] = value;

	intf_->data_port_a_w(id_, offset, value);
	
	if (logger_) {
		//logger_->recordRegisterChange(offset, value);
	}
	/*/
	else if (intf_ == &ymfm_intf2608) {
		
	}
	else {
		if (offset & 0x100) {
			intf_->control_port_b_w(id_, 2, offset & 0xff);
			intf_->data_port_b_w(id_, 3, value & 0xff);
		}
		else
		{
			intf_->control_port_a_w(id_, 0, offset & 0xff);
			intf_->data_port_a_w(id_, 1, value & 0xff);
		}
	}
	//*/
}

uint8_t OPNA::getRegister(uint32_t offset) const
{
	return intf_->read_port_r(id_, offset);
	/*/
	if (intf_ == &ymfm_intf2608) {
		return intf_->read_port_r(id_, offset);
	}
	if (offset & 0x100) {
		intf_->control_port_b_w(id_, 2, offset & 0xff);
	}
	else
	{
		intf_->control_port_a_w(id_, 0, offset & 0xff);
	}
	return intf_->read_port_r(id_, 1);
	//*/
}

uint8_t OPNA::debugGetRegister(int offset) const
{
	return intf_->read_port_r(id_, offset + 0x200);
}


void OPNA::setVolumeFM(double dB)
{
	std::lock_guard<std::mutex> lg(mutex_);
	volumeRatio_[FM] = std::pow(10.0, (dB - VOL_REDUC_) / 20.0);
}

void OPNA::setVolumeSSG(double dB)
{
	std::lock_guard<std::mutex> lg(mutex_);
	volumeRatio_[SSG] = std::pow(10.0, (dB - VOL_REDUC_) / 20.0);
}

size_t OPNA::getDRAMSize() const noexcept
{
	return dramSize_;
}

void OPNA::mix(int16_t* stream, size_t nSamples)
{
	std::lock_guard<std::mutex> lg(mutex_);
	sample **bufFM, **bufSSG;

	// Set FM buffer
	if (internalRate_[FM] == rate_) {
		intf_->stream_update(id_, buffer_[FM], nSamples);
		bufFM = buffer_[FM];
	}
	else {
		size_t intrSize = resampler_[FM]->calculateInternalSampleSize(nSamples);
		intf_->stream_update(id_, buffer_[FM], intrSize);
		bufFM = resampler_[FM]->interpolate(buffer_[FM], nSamples, intrSize);
	}

	// Set SSG buffer
	if (internalRate_[SSG] == rate_) {
		intf_->stream_update_ay(id_, buffer_[SSG], nSamples);
		bufSSG = buffer_[SSG];
	}
	else {
		size_t intrSize = resampler_[SSG]->calculateInternalSampleSize(nSamples);
		intf_->stream_update_ay(id_, buffer_[SSG], intrSize);
		bufSSG = resampler_[SSG]->interpolate(buffer_[SSG], nSamples, intrSize);
	}
	int16_t* p = stream;
	for (size_t i = 0; i < nSamples; ++i) {
		for (int pan = STEREO_LEFT; pan <= STEREO_RIGHT; ++pan) {
			double s = volumeRatio_[FM] * bufFM[pan][i] + volumeRatio_[SSG] * bufSSG[pan][i];
			*p++ = static_cast<int16_t>(clamp(s * masterVolumeRatio_, -32768.0, 32767.0));
		}
	}
}
}
