// BSD 3-Clause License
//
// Copyright (c) 2021, Aaron Giles
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



#include <algorithm>
#include <cstring>
#include "opnaymfm.h"

#define LOG_WRITES (0)


namespace FM
{


//****************************************************************************
// OPNA クラス
//****************************************************************************

//----------------------------------------------------------------------------
// コンストラクタ
//----------------------------------------------------------------------------
OPNA::OPNA() :
	m_chip(*this),
	m_clock(DEFAULT_CLOCK),
	m_clocks(0),
	m_output(),
	m_step(0),
	m_pos(0),
	rate(8000),
	frhythm_adpcm_rom(false),
	rhythm{},
	rhythmtvol(0),
	rhythmtl(0),
	rhythmkey(0),
	output_step(0x1000000000000ull / rate),
	output_pos(0),
	timer_period{},
	timer_count{},
	reg27(0)
{	
	// テーブル作成
	for (int i = -FM_TLPOS; i < FM_TLENTS; i++)	{
		tltable[i + FM_TLPOS] = (unsigned int)((65536. * pow(2.0, i * -16. / (int)FM_TLENTS)) - 1);
	}
}


//----------------------------------------------------------------------------
// デストラクタ
//----------------------------------------------------------------------------
OPNA::~OPNA()
{
	for (int i=0; i<6; i++)
		delete[] rhythm[i].sample;
}

//----------------------------------------------------------------------------
// 初期化
//----------------------------------------------------------------------------
bool OPNA::Init(uint32_t c, uint32_t r, bool ip)
{
	m_clock = c;
	rate = r;
	m_clocks = 0;
	m_step = 0x1000000000000ull / m_chip.sample_rate(m_clock);
	m_pos = 0;
	
	frhythm_adpcm_rom = true;
	m_data[ymfm::ACCESS_ADPCM_A] = std::vector<uint8_t>(0x2000, 0);
	for(int i = 0; i < m_data[ymfm::ACCESS_ADPCM_A].size(); i++)
	{
		m_data[ymfm::ACCESS_ADPCM_A][i] = YMFM_ADPCM_ROM[i];
	}
	
	if (!SetRate(c, r, ip))
		return false;
	
	m_chip.reset();
	
	SetVolumeFM(0);
	SetVolumePSG(0);
	SetVolumeADPCM(0);
	SetVolumeRhythmTotal(0);
	for (int i = 0; i < 6; i++)
		SetVolumeRhythm(i, 0);
	
	return true;
}


//----------------------------------------------------------------------------
// サンプリングレート変更
//----------------------------------------------------------------------------
bool OPNA::SetRate(uint32_t r)
{
	rate = r;
	output_step = 0x1000000000000ull / rate;
	return true;
}


bool OPNA::SetRate(uint32_t c, uint32_t r, bool)
{
	SetRate(r);
	
	m_clock = c;
	rate = r;
	
	return true;
}


//----------------------------------------------------------------------------
// リズム音を読み込む
//----------------------------------------------------------------------------
bool OPNA::LoadRhythmSample()
{
	frhythm_adpcm_rom = false;
	
	int i;
	for (i = 0; i < 6; i++)
		rhythm[i].pos = ~0;
	
	for (i = 0; i < 6; i++)
	{
		uint32_t fsize = YMFM_ADPCM_ROM_addr[2*i+1] - YMFM_ADPCM_ROM_addr[2*i] + 1;
		uint32_t startaddr = YMFM_ADPCM_ROM_addr[2*i];
				
		delete rhythm[i].sample;
		rhythm[i].sample = new int16_t[fsize];
		if (!rhythm[i].sample)
			break;
		for(int j = 0; j < fsize; j++)
		{
			rhythm[i].sample[j] = ((int16_t)YMFM_ADPCM_ROM[j + startaddr])*256;
		}
		
		rhythm[i].rate = 55466;
		rhythm[i].step = rhythm[i].rate * 1024 / rate;
		rhythm[i].pos = rhythm[i].size = fsize * 1024;
	}
	if (i != 6)
	{
		for (i = 0; i < 6; i++)
		{
			delete[] rhythm[i].sample;
			rhythm[i].sample = 0;
		}
		return false;
	}
	return true;
}


//----------------------------------------------------------------------------
// リセット
//----------------------------------------------------------------------------
void OPNA::Reset()
{
	m_chip.reset();
}


//----------------------------------------------------------------------------
// 音量設定
//----------------------------------------------------------------------------
void OPNA::SetVolumeFM(int db)
{
	int32_t volume;
	
	db = (std::min)(db, 20);
	if (db > -192)
		volume = int(65536.0 * pow(10.0, db / 40.0));
	else
		volume = 0;
	
	m_chip.setfmvolume(volume);
}


void OPNA::SetVolumePSG(int db)
{
	int32_t volume;
	
	db = (std::min)(db, 20);
	if (db > -192)
		volume = int(65536.0 * pow(10.0, db / 40.0));
	else
		volume = 0;
	
	m_chip.setpsgvolume(volume);
}


void OPNA::SetVolumeADPCM(int db)
{
	int32_t volume;
	
	db = (std::min)(db, 20);
	if (db > -192)
		volume = int(65536.0 * pow(10.0, db / 40.0));
	else
		volume = 0;
	
	m_chip.setadpcmvolume(volume);
}


void OPNA::SetVolumeRhythmTotal(int db)
{
	int32_t volume;
	
	db = (std::min)(db, 20);
	rhythmtvol = -(db * 2 / 3);
	
	if (db > -192)
		volume = int(65536.0 * pow(10.0, db / 40.0));
	else
		volume = 0;
	
	m_chip.setrhythmvolume(volume);
}


void OPNA::SetVolumeRhythm(int index, int db)
{
	db = (std::min)(db, 20);
	rhythm[index].volume = -(db * 2 / 3);
}


//----------------------------------------------------------------------------
// レジスタアレイにデータを設定
//----------------------------------------------------------------------------
void OPNA::SetReg(uint32_t addr, uint32_t data)
{
	if (addr >= 0x10 && addr <= 0x1f && !frhythm_adpcm_rom) {
		// rhythmをwavで鳴らす時
		
		switch (addr)
		{
		case 0x10:			// DM/KEYON
			if (!(data & 0x80))	// KEY ON
			{
				rhythmkey |= data & 0x3f;
				if (data & 0x01) rhythm[0].pos = 0;
				if (data & 0x02) rhythm[1].pos = 0;
				if (data & 0x04) rhythm[2].pos = 0;
				if (data & 0x08) rhythm[3].pos = 0;
				if (data & 0x10) rhythm[4].pos = 0;
				if (data & 0x20) rhythm[5].pos = 0;
			}
			else
			{					// DUMP
				rhythmkey &= ~data;
			}
			break;
			
		case 0x11:
			rhythmtl = ~data & 63;
			break;
			
		case 0x18: 		// Bass Drum
		case 0x19:		// Snare Drum
		case 0x1a:		// Top Cymbal
		case 0x1b:		// Hihat
		case 0x1c:		// Tom-tom
		case 0x1d:		// Rim shot
			rhythm[addr & 7].pan = (data >> 6) & 3;
			rhythm[addr & 7].level = ~data & 31;
			break;
		}
		
	} else {
		uint32_t addr1 = 0 + 2 * ((addr >> 8) & 3);
		uint8_t data1 = addr & 0xff;
		uint32_t addr2 = addr1 + 1;
		uint8_t data2 = data;
		
		// write to the chip
		if (addr1 != 0xffff)
		{
			if (LOG_WRITES)
				printf("Write %10.5f: %03X=%02X\n", double(m_clocks) / double(m_chip.sample_rate(m_clock)), data1, data2);
			m_chip.write(addr1, data1);
			m_chip.write(addr2, data2);
		}
	}
}


//----------------------------------------------------------------------------
// レジスタ取得
//----------------------------------------------------------------------------
uint32_t OPNA::GetReg(uint32_t addr)
{
	if(addr & 0x200)
	{
		return m_chip.readDebug(addr&0x1FF);
	}

	uint32_t addr1 = 0 + 2 * ((addr >> 8) & 3);
	uint8_t data1 = addr & 0xff;
	uint32_t addr2 = addr1 + 1;
	uint8_t result = 0;
	
	// write to the chip
	if (addr1 != 0xffff)
	{
		m_chip.write(addr1, data1);
		result = m_chip.read(addr2);
		if (LOG_WRITES)
			printf("Read  %10.5f: %03X=%02X\n", double(m_clocks) / double(m_chip.sample_rate(m_clock)), data1, result);
		
	} else {
		result = 1;
	}
	
	return result;
}


//----------------------------------------------------------------------------
// ステータスを読み込む
//----------------------------------------------------------------------------
uint32_t OPNA::ReadStatus()
{
	return m_chip.read_status();
}


//----------------------------------------------------------------------------
// 拡張ステータスを読み込む
//----------------------------------------------------------------------------
uint32_t OPNA::ReadStatusEx()
{
	return m_chip.read_status_hi();
}


//----------------------------------------------------------------------------
// タイマー時間処理
//----------------------------------------------------------------------------
bool OPNA::Count(uint32_t us)
{
	bool result = false;
	
	if (reg27 & 1) {
		if (timer_count[0] > 0) {
			timer_count[0] -= ((emulated_time)us << (48 - 6)) / (1000000 >> 6);
		}
	}
	
	if (reg27 & 2) {
		if (timer_count[1] > 0) {
			timer_count[1] -= ((emulated_time)us << (48 - 6)) / (1000000 >> 6);
		}
	}
	
	for (int i = 0; i < sizeof(timer_count) / sizeof(emulated_time); i++) {
		if ((reg27 & (4 << i)) && timer_count[i] < 0) {
			result = true;
			do {
				timer_count[i] += timer_period[i];
			} while (timer_count[i] < 0);
			
			m_engine->engine_timer_expired(i);
		}
	}
	
	return result;
}


//----------------------------------------------------------------------------
// 次にタイマーが発生するまでの時間を求める
//----------------------------------------------------------------------------
uint32_t OPNA::GetNextEvent()
{
	if (timer_count[0] == 0 && timer_count[1] == 0) {
		return 0;
	}
	
	emulated_time result = INT64_MAX;
	for (int i = 0; i < sizeof(timer_count) / sizeof(emulated_time); i++) {
		if (timer_count[i] > 0) {
			result = (std::min)(result, timer_count[i]);
		}
	}
	return (result + ((emulated_time)1 << 48) / 1000000) * (1000000 >> 6) >> (48 - 6);
}


//----------------------------------------------------------------------------
// 合成
// in:		buffer		合成先
//			nsamples	合成サンプル数
//
//----------------------------------------------------------------------------
void OPNA::Mix(Sample* buffer, int nsamples)
{
	int nsamples2 = nsamples;
	Sample* buffer2 = buffer;
	
	while (nsamples2-- != 0)
	{
		int32_t outputs[2] = { 0, 0 };
		generate(output_pos, output_step, outputs);
		output_pos += output_step;
		*buffer2 += outputs[0];
		buffer2++;
		*buffer2 += outputs[1];
		buffer2++;
	}
	
	if (!frhythm_adpcm_rom) {
		RhythmMix(buffer, nsamples);
	}
}

void OPNA::GetFMSamples(Sample* bufferFM0, Sample* bufferFM1, int nsamples)
{
	int nsamples2 = nsamples;
	int ssgind = 0;
	
	while (nsamples2-- > 0)
	{
		int32_t outputs[2] = { 0, 0 };
		generateSplit(output_pos, output_step, outputs, ssgind);
		output_pos += output_step;
		bufferFM0[ssgind] = outputs[0];
		bufferFM1[ssgind] = outputs[1];
		ssgind++;
	}

	return;
}

void OPNA::GetSSGSamples(Sample* bufferSSG0, Sample* bufferSSG1, int nsamples)
{
	int nsamples2 = nsamples;
	int ssgind = 0;

	while(nsamples2-- > 0)
	{
		bufferSSG0[ssgind] = ssgbuf[ssgind];
		bufferSSG1[ssgind] = ssgbuf[ssgind];
		ssgind++;
	}

	return;
}

//----------------------------------------------------------------------------
// generate one output sample of output
//----------------------------------------------------------------------------
void OPNA::generate(emulated_time output_start, emulated_time output_step, int32_t* buffer)
{
	uint32_t addr1 = 0xffff, addr2 = 0xffff;
	uint8_t data1 = 0, data2 = 0;
	
	// generate at the appropriate sample rate
	for (; m_pos <= output_start; m_pos += m_step)
	{
		m_chip.generate(&m_output);
	}
	
	// add the final result to the buffer
	
	int32_t out0 = m_output.data[0];
	int32_t out1 = m_output.data[1 % ymfm::ym2608::OUTPUTS];
	int32_t out2 = m_output.data[2 % ymfm::ym2608::OUTPUTS];
	*buffer++ += out0 + out2;
	*buffer++ += out1 + out2;
	
	m_clocks++;
}

void OPNA::generateSplit(emulated_time output_start, emulated_time output_step, int32_t* buffer, int ssgind)
{
	uint32_t addr1 = 0xffff, addr2 = 0xffff;
	uint8_t data1 = 0, data2 = 0;
	
	// generate at the appropriate sample rate
	for (; m_pos <= output_start; m_pos += m_step)
	{
		m_chip.generate(&m_output);
	}
	
	// add the final result to the buffer
	
	int32_t out0 = m_output.data[0];
	int32_t out1 = m_output.data[1 % ymfm::ym2608::OUTPUTS];
	int32_t out2 = m_output.data[2 % ymfm::ym2608::OUTPUTS];
	buffer[0] = out0;
	buffer[1] = out1;
	ssgbuf[ssgind] = out2;
	
	m_clocks++;
}

//----------------------------------------------------------------------------
// データコピー
//----------------------------------------------------------------------------
void OPNA::StoreSample(Sample& dest, ISample data)
{
	if (sizeof(Sample) == 2)
		dest = (Sample)Limit(dest + data, 0x7fff, -0x8000);
	else
		dest += data;
}


//----------------------------------------------------------------------------
// リズム合成(wav)
//----------------------------------------------------------------------------
void OPNA::RhythmMix(Sample* buffer, uint32_t count)
{
	if (rhythmtvol < 128 && rhythm[0].sample && (rhythmkey & 0x3f)) {
		Sample* limit = buffer + count * 2;
		for (int i = 0; i < 6; i++) {
			Rhythm& r = rhythm[i];
			if ((rhythmkey & (1 << i)) /* //@ && r.level < 128 */) {
				int db = Limit(rhythmtl + rhythmtvol + r.level + r.volume, 127, -31);
				int vol = tltable[FM_TLPOS + (db << (FM_TLBITS - 7))] >> 4;
				int maskl = -((r.pan >> 1) & 1);
				int maskr = -(r.pan & 1);
				
				for (Sample* dest = buffer; dest < limit && r.pos < r.size; dest += 2) {
					int sample = (r.sample[r.pos / 1024] * vol) >> 12;
					r.pos += r.step;
					StoreSample(dest[0], sample & maskl);
					StoreSample(dest[1], sample & maskr);
				}
			}
		}
	}
}

void OPNA::RhythmMixSplit(Sample* bufferL, Sample* bufferR, uint32_t count)
{
	if (rhythmtvol < 128 && rhythm[0].sample && (rhythmkey & 0x3f)) {
		Sample* limitL = bufferL + count;
		Sample* limitR = bufferR + count;
		for (int i = 0; i < 6; i++) {
			Rhythm& r = rhythm[i];
			if ((rhythmkey & (1 << i)) /* //@ && r.level < 128 */) {
				int db = Limit(rhythmtl + rhythmtvol + r.level + r.volume, 127, -31);
				int vol = tltable[FM_TLPOS + (db << (FM_TLBITS - 7))] >> 4;
				int maskl = -((r.pan >> 1) & 1);
				int maskr = -(r.pan & 1);
				
				for (int i = 0; i < count && r.pos < r.size; i++) {
					int sample = (r.sample[r.pos / 1024] * vol) >> 12;
					r.pos += r.step;
					StoreSample(bufferL[i], sample & maskl);
					StoreSample(bufferR[i], sample & maskr);
				}
			}
		}
	}
}


//----------------------------------------------------------------------------
// write data to the ADPCM-A buffer
//----------------------------------------------------------------------------
void OPNA::write_data(ymfm::access_class type, uint32_t base, uint32_t length, uint8_t const* src)
{
	uint32_t end = base + length;
	if (end > m_data[type].size())
		m_data[type].resize(end);
	memcpy(&m_data[type][base], src, length);
}


//----------------------------------------------------------------------------
// Get sample rate
//----------------------------------------------------------------------------
uint32_t OPNA::sample_rate() const
{
	return m_chip.sample_rate(m_clock);
}


//----------------------------------------------------------------------------
// callback : handle read from the buffer
//----------------------------------------------------------------------------
uint8_t OPNA::ymfm_external_read(ymfm::access_class type, uint32_t offset)
{
	if (!frhythm_adpcm_rom && type == ymfm::ACCESS_ADPCM_A) {
		return 0;
	}
	
	auto& data = m_data[type];
	return (offset < data.size()) ? data[offset] : 0;
}


//----------------------------------------------------------------------------
// callback : handle write to the buffer
//----------------------------------------------------------------------------
void OPNA::ymfm_external_write(ymfm::access_class type, uint32_t address, uint8_t data)
{
	write_data(type, address, 1, &data);
}


//----------------------------------------------------------------------------
// callback : clear timer
//----------------------------------------------------------------------------
void OPNA::ymfm_sync_mode_write(uint8_t data)
{
	reg27 = data;
	
	/* //@ とりあえず無効化
	if (reg27 & 0x10) {
		timer_count[0] = timer_period[0];
		reg27 &= ~0x10;
	}
	if (reg27 & 0x20) {
		timer_count[1] = timer_period[1];
		reg27 &= ~0x20;
	}
	*/
	
	ymfm_interface::ymfm_sync_mode_write(reg27);
}


//----------------------------------------------------------------------------
// callback : set timer
//----------------------------------------------------------------------------
void OPNA::ymfm_set_timer(uint32_t tnum, int32_t duration_in_clocks)
{
	if (duration_in_clocks >= 0) {
		timer_period[tnum] = (((emulated_time)duration_in_clocks << 43) / m_clock) << 5;
		timer_count[tnum] = timer_period[tnum];
	}
	else {
		timer_period[tnum] = 0;
		timer_count[tnum] = 0;
	}
}


}	// namespace FM
