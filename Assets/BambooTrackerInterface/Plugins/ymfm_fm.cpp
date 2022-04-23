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
#include "ymfm.h"
#include "ymfm_fm.h"

namespace ymfm
{


//moved to header because of fucking linker errors



//*********************************************************
//  FM OPERATOR
//*********************************************************

//-------------------------------------------------
//  fm_operator - constructor
//-------------------------------------------------
/*
template<class RegisterType>
fm_operator<RegisterType>::fm_operator(fm_engine_base<RegisterType> &owner, uint32_t opoffs) :
	m_choffs(0),
	m_opoffs(opoffs),
	m_phase(0),
	m_env_attenuation(0x3ff),
	m_env_state(EG_RELEASE),
	m_ssg_inverted(false),
	m_key_state(0),
	m_keyon_live(0),
	m_regs(owner.regs()),
	m_owner(owner)
{
}
*/

//-------------------------------------------------
//  reset - reset the channel state
//-------------------------------------------------
/*
template<class RegisterType>
void fm_operator<RegisterType>::reset()
{
	// reset our data
	m_phase = 0;
	m_env_attenuation = 0x3ff;
	m_env_state = EG_RELEASE;
	m_ssg_inverted = 0;
	m_key_state = 0;
	m_keyon_live = 0;
}
*/

//-------------------------------------------------
//  save_restore - save or restore the data
//-------------------------------------------------
/*
template<class RegisterType>
void fm_operator<RegisterType>::save_restore(ymfm_saved_state &state)
{
	state.save_restore(m_phase);
	state.save_restore(m_env_attenuation);
	state.save_restore(m_env_state);
	state.save_restore(m_ssg_inverted);
	state.save_restore(m_key_state);
	state.save_restore(m_keyon_live);
}
*/

//-------------------------------------------------
//  prepare - prepare for clocking
//-------------------------------------------------
/*
template<class RegisterType>
bool fm_operator<RegisterType>::prepare()
{
	// cache the data
	m_regs.cache_operator_data(m_choffs, m_opoffs, m_cache);

	// clock the key state
	clock_keystate(uint32_t(m_keyon_live != 0));
	m_keyon_live &= ~(1 << KEYON_CSM);

	// we're active until we're quiet after the release
	return (m_env_state != (RegisterType::EG_HAS_REVERB ? EG_REVERB : EG_RELEASE) || m_env_attenuation < EG_QUIET);
}
*/

//-------------------------------------------------
//  clock - master clocking function
//-------------------------------------------------
/*
template<class RegisterType>
void fm_operator<RegisterType>::clock(uint32_t env_counter, int32_t lfo_raw_pm)
{
	// clock the SSG-EG state (OPN/OPNA)
	if (m_regs.op_ssg_eg_enable(m_opoffs))
		clock_ssg_eg_state();

	// clock the envelope if on an envelope cycle; env_counter is a x.2 value
	if (bitfield(env_counter, 0, 2) == 0)
		clock_envelope(env_counter >> 2);

	// clock the phase
	clock_phase(lfo_raw_pm);
}
*/

//-------------------------------------------------
//  compute_volume - compute the 14-bit signed
//  volume of this operator, given a phase
//  modulation and an AM LFO offset
//-------------------------------------------------
/*
template<class RegisterType>
int32_t fm_operator<RegisterType>::compute_volume(uint32_t phase, uint32_t am_offset) const
{
	// the low 10 bits of phase represents a full 2*PI period over
	// the full sin wave

#if 0
// temporary envelope logging
if (m_choffs == 0)
{
	printf("  %c@%02X:%03X", "PADSRV"[m_env_state], m_cache.eg_rate[m_env_state], envelope_attenuation(am_offset));
	if (m_opoffs == 0x18) printf("\n");
}
#endif

	// early out if the envelope is effectively off
	if (m_env_attenuation > EG_QUIET)
		return 0;

	// get the absolute value of the sin, as attenuation, as a 4.8 fixed point value
	uint32_t sin_attenuation = m_cache.waveform[phase & (RegisterType::WAVEFORM_LENGTH - 1)];

	// get the attenuation from the evelope generator as a 4.6 value, shifted up to 4.8
	uint32_t env_attenuation = envelope_attenuation(am_offset) << 2;

	// combine into a 5.8 value, then convert from attenuation to 13-bit linear volume
	int32_t result = attenuation_to_volume((sin_attenuation & 0x7fff) + env_attenuation);

	// negate if in the negative part of the sin wave (sign bit gives 14 bits)
	return bitfield(sin_attenuation, 15) ? -result : result;
}
*/

//-------------------------------------------------
//  compute_noise_volume - compute the 14-bit
//  signed noise volume of this operator, given a
//  noise input value and an AM offset
//-------------------------------------------------
/*
template<class RegisterType>
int32_t fm_operator<RegisterType>::compute_noise_volume(uint32_t am_offset) const
{
	// application manual says the logarithmic transform is not applied here, so we
	// just use the raw envelope attenuation, inverted (since 0 attenuation should be
	// maximum), and shift it up from a 10-bit value to an 11-bit value
	int32_t result = (envelope_attenuation(am_offset) ^ 0x3ff) << 1;

	// QUESTION: is AM applied still?

	// negate based on the noise state
	return bitfield(m_regs.noise_state(), 0) ? -result : result;
}
*/

//-------------------------------------------------
//  keyonoff - signal a key on/off event
//-------------------------------------------------
/*
template<class RegisterType>
void fm_operator<RegisterType>::keyonoff(uint32_t on, keyon_type type)
{
	m_keyon_live = (m_keyon_live & ~(1 << int(type))) | (bitfield(on, 0) << int(type));
}
*/

//-------------------------------------------------
//  start_attack - start the attack phase; called
//  when a keyon happens or when an SSG-EG cycle
//  is complete and restarts
//-------------------------------------------------
/*
template<class RegisterType>
void fm_operator<RegisterType>::start_attack(bool is_restart)
{
	// don't change anything if already in attack state
	if (m_env_state == EG_ATTACK)
		return;
	m_env_state = EG_ATTACK;

	// generally not inverted at start, except if SSG-EG is enabled and
	// one of the inverted modes is specified; leave this alone on a
	// restart, as it is managed by the clock_ssg_eg_state() code
	if (RegisterType::EG_HAS_SSG && !is_restart)
		m_ssg_inverted = m_regs.op_ssg_eg_enable(m_opoffs) & bitfield(m_regs.op_ssg_eg_mode(m_opoffs), 2);

	// reset the phase when we start an attack due to a key on
	// (but not when due to an SSG-EG restart except in certain cases
	// managed directly by the SSG-EG code)
	if (!is_restart)
		m_phase = 0;

	// if the attack rate >= 62 then immediately go to max attenuation
	if (m_cache.eg_rate[EG_ATTACK] >= 62)
		m_env_attenuation = 0;
}
*/

//-------------------------------------------------
//  start_release - start the release phase;
//  called when a keyoff happens
//-------------------------------------------------
/*
template<class RegisterType>
void fm_operator<RegisterType>::start_release()
{
	// don't change anything if already in release state
	if (m_env_state >= EG_RELEASE)
		return;
	m_env_state = EG_RELEASE;

	// if attenuation if inverted due to SSG-EG, snap the inverted attenuation
	// as the starting point
	if (RegisterType::EG_HAS_SSG && m_ssg_inverted)
	{
		m_env_attenuation = (0x200 - m_env_attenuation) & 0x3ff;
		m_ssg_inverted = false;
	}
}
*/

//-------------------------------------------------
//  clock_keystate - clock the keystate to match
//  the incoming keystate
//-------------------------------------------------
/*
template<class RegisterType>
void fm_operator<RegisterType>::clock_keystate(uint32_t keystate)
{
	assert(keystate == 0 || keystate == 1);

	// has the key changed?
	if ((keystate ^ m_key_state) != 0)
	{
		m_key_state = keystate;

		// if the key has turned on, start the attack
		if (keystate != 0)
		{
			// OPLL has a DP ("depress"?) state to bring the volume
			// down before starting the attack
			if (RegisterType::EG_HAS_DEPRESS && m_env_attenuation < 0x200)
				m_env_state = EG_DEPRESS;
			else
				start_attack();
		}

		// otherwise, start the release
		else
			start_release();
	}
}
*/

//-------------------------------------------------
//  clock_ssg_eg_state - clock the SSG-EG state;
//  should only be called if SSG-EG is enabled
//-------------------------------------------------
/*
template<class RegisterType>
void fm_operator<RegisterType>::clock_ssg_eg_state()
{
	// work only happens once the attenuation crosses above 0x200
	if (!bitfield(m_env_attenuation, 9))
		return;

	// 8 SSG-EG modes:
	//    000: repeat normally
	//    001: run once, hold low
	//    010: repeat, alternating between inverted/non-inverted
	//    011: run once, hold high
	//    100: inverted repeat normally
	//    101: inverted run once, hold low
	//    110: inverted repeat, alternating between inverted/non-inverted
	//    111: inverted run once, hold high
	uint32_t mode = m_regs.op_ssg_eg_mode(m_opoffs);

	// hold modes (1/3/5/7)
	if (bitfield(mode, 0))
	{
		// set the inverted flag to the end state (0 for modes 1/7, 1 for modes 3/5)
		m_ssg_inverted = bitfield(mode, 2) ^ bitfield(mode, 1);

		// if holding, force the attenuation to the expected value once we're
		// past the attack phase
		if (m_env_state != EG_ATTACK)
			m_env_attenuation = m_ssg_inverted ? 0x200 : 0x3ff;
	}

	// continuous modes (0/2/4/6)
	else
	{
		// toggle invert in alternating mode (even in attack state)
		m_ssg_inverted ^= bitfield(mode, 1);

		// restart attack if in decay/sustain states
		if (m_env_state == EG_DECAY || m_env_state == EG_SUSTAIN)
			start_attack(true);

		// phase is reset to 0 in modes 0/4
		if (bitfield(mode, 1) == 0)
			m_phase = 0;
	}

	// in all modes, once we hit release state, attenuation is forced to maximum
	if (m_env_state == EG_RELEASE)
		m_env_attenuation = 0x3ff;
}
*/

//-------------------------------------------------
//  clock_envelope - clock the envelope state
//  according to the given count
//-------------------------------------------------
/*
template<class RegisterType>
void fm_operator<RegisterType>::clock_envelope(uint32_t env_counter)
{
	// handle attack->decay transitions
	if (m_env_state == EG_ATTACK && m_env_attenuation == 0)
		m_env_state = EG_DECAY;

	// handle decay->sustain transitions; it is important to do this immediately
	// after the attack->decay transition above in the event that the sustain level
	// is set to 0 (in which case we will skip right to sustain without doing any
	// decay); as an example where this can be heard, check the cymbals sound
	// in channel 0 of shinobi's test mode sound #5
	if (m_env_state == EG_DECAY && m_env_attenuation >= m_cache.eg_sustain)
		m_env_state = EG_SUSTAIN;

	// fetch the appropriate 6-bit rate value from the cache
	uint32_t rate = m_cache.eg_rate[m_env_state];

	// compute the rate shift value; this is the shift needed to
	// apply to the env_counter such that it becomes a 5.11 fixed
	// point number
	uint32_t rate_shift = rate >> 2;
	env_counter <<= rate_shift;

	// see if the fractional part is 0; if not, it's not time to clock
	if (bitfield(env_counter, 0, 11) != 0)
		return;

	// determine the increment based on the non-fractional part of env_counter
	uint32_t relevant_bits = bitfield(env_counter, (rate_shift <= 11) ? 11 : rate_shift, 3);
	uint32_t increment = attenuation_increment(rate, relevant_bits);

	// attack is the only one that increases
	if (m_env_state == EG_ATTACK)
	{
		// glitch means that attack rates of 62/63 don't increment if
		// changed after the initial key on (where they are handled
		// specially); nukeykt confirms this happens on OPM, OPN, OPL/OPLL
		// at least so assuming it is true for everyone
		if (rate < 62)
			m_env_attenuation += (~m_env_attenuation * increment) >> 4;
	}

	// all other cases are similar
	else
	{
		// non-SSG-EG cases just apply the increment
		if (!m_regs.op_ssg_eg_enable(m_opoffs))
			m_env_attenuation += increment;

		// SSG-EG only applies if less than mid-point, and then at 4x
		else if (m_env_attenuation < 0x200)
			m_env_attenuation += 4 * increment;

		// clamp the final attenuation
		if (m_env_attenuation >= 0x400)
			m_env_attenuation = 0x3ff;

		// transition from depress to attack
		if (RegisterType::EG_HAS_DEPRESS && m_env_state == EG_DEPRESS && m_env_attenuation >= 0x200)
			start_attack();

		// transition from release to reverb, should switch at -18dB
		if (RegisterType::EG_HAS_REVERB && m_env_state == EG_RELEASE && m_env_attenuation >= 0xc0)
			m_env_state = EG_REVERB;
	}
}
*/

//-------------------------------------------------
//  clock_phase - clock the 10.10 phase value; the
//  OPN version of the logic has been verified
//  against the Nuked phase generator
//-------------------------------------------------
/*
template<class RegisterType>
void fm_operator<RegisterType>::clock_phase(int32_t lfo_raw_pm)
{
	// read from the cache, or recalculate if PM active
	uint32_t phase_step = m_cache.phase_step;
	if (phase_step == opdata_cache::PHASE_STEP_DYNAMIC)
		phase_step = m_regs.compute_phase_step(m_choffs, m_opoffs, m_cache, lfo_raw_pm);

	// finally apply the step to the current phase value
	m_phase += phase_step;
}
*/

//-------------------------------------------------
//  envelope_attenuation - return the effective
//  attenuation of the envelope
//-------------------------------------------------
/*
template<class RegisterType>
uint32_t fm_operator<RegisterType>::envelope_attenuation(uint32_t am_offset) const
{
	uint32_t result = m_env_attenuation >> m_cache.eg_shift;

	// invert if necessary due to SSG-EG
	if (RegisterType::EG_HAS_SSG && m_ssg_inverted)
		result = (0x200 - result) & 0x3ff;

	// add in LFO AM modulation
	if (m_regs.op_lfo_am_enable(m_opoffs))
		result += am_offset;

	// add in total level and KSL from the cache
	result += m_cache.total_level;

	// clamp to max, apply shift, and return
	return std::min<uint32_t>(result, 0x3ff);
}
*/



//*********************************************************
//  FM CHANNEL
//*********************************************************

//-------------------------------------------------
//  fm_channel - constructor
//-------------------------------------------------
/*
template<class RegisterType>
fm_channel<RegisterType>::fm_channel(fm_engine_base<RegisterType> &owner, uint32_t choffs) :
	m_choffs(choffs),
	m_feedback{ 0, 0 },
	m_feedback_in(0),
	m_op{ nullptr, nullptr, nullptr, nullptr },
	m_regs(owner.regs()),
	m_owner(owner)
{
}
*/

//-------------------------------------------------
//  reset - reset the channel state
//-------------------------------------------------
/*
template<class RegisterType>
void fm_channel<RegisterType>::reset()
{
	// reset our data
	m_feedback[0] = m_feedback[1] = 0;
	m_feedback_in = 0;
}
*/

//-------------------------------------------------
//  save_restore - save or restore the data
//-------------------------------------------------
/*
template<class RegisterType>
void fm_channel<RegisterType>::save_restore(ymfm_saved_state &state)
{
	state.save_restore(m_feedback[0]);
	state.save_restore(m_feedback[1]);
	state.save_restore(m_feedback_in);
}
*/

//-------------------------------------------------
//  keyonoff - signal key on/off to our operators
//-------------------------------------------------
/*
template<class RegisterType>
void fm_channel<RegisterType>::keyonoff(uint32_t states, keyon_type type, uint32_t chnum)
{
	for (uint32_t opnum = 0; opnum < array_size(m_op); opnum++)
		if (m_op[opnum] != nullptr)
			m_op[opnum]->keyonoff(bitfield(states, opnum), type);

	if (debug::LOG_KEYON_EVENTS && ((debug::GLOBAL_FM_CHANNEL_MASK >> chnum) & 1) != 0)
		for (uint32_t opnum = 0; opnum < array_size(m_op); opnum++)
			if (m_op[opnum] != nullptr)
				debug::log_keyon("%c%s\n", bitfield(states, opnum) ? '+' : '-', m_regs.log_keyon(m_choffs, m_op[opnum]->opoffs()).c_str());
}
*/

//-------------------------------------------------
//  prepare - prepare for clocking
//-------------------------------------------------
/*
template<class RegisterType>
bool fm_channel<RegisterType>::prepare()
{
	uint32_t active_mask = 0;

	// prepare all operators and determine if they are active
	for (uint32_t opnum = 0; opnum < array_size(m_op); opnum++)
		if (m_op[opnum] != nullptr)
			if (m_op[opnum]->prepare())
				active_mask |= 1 << opnum;

	return (active_mask != 0);
}
*/

//-------------------------------------------------
//  clock - master clock of all operators
//-------------------------------------------------
/*
template<class RegisterType>
void fm_channel<RegisterType>::clock(uint32_t env_counter, int32_t lfo_raw_pm)
{
	// clock the feedback through
	m_feedback[0] = m_feedback[1];
	m_feedback[1] = m_feedback_in;

	for (uint32_t opnum = 0; opnum < array_size(m_op); opnum++)
		if (m_op[opnum] != nullptr)
			m_op[opnum]->clock(env_counter, lfo_raw_pm);
}
*/

//-------------------------------------------------
//  output_2op - combine 4 operators according to
//  the specified algorithm, returning a sum
//  according to the rshift and clipmax parameters,
//  which vary between different implementations
//-------------------------------------------------
/*
template<class RegisterType>
void fm_channel<RegisterType>::output_2op(output_data &output, uint32_t rshift, int32_t clipmax) const
{
	// The first 2 operators should be populated
	assert(m_op[0] != nullptr);
	assert(m_op[1] != nullptr);

	// AM amount is the same across all operators; compute it once
	uint32_t am_offset = m_regs.lfo_am_offset(m_choffs);

	// operator 1 has optional self-feedback
	int32_t opmod = 0;
	uint32_t feedback = m_regs.ch_feedback(m_choffs);
	if (feedback != 0)
		opmod = (m_feedback[0] + m_feedback[1]) >> (10 - feedback);

	// compute the 14-bit volume/value of operator 1 and update the feedback
	int32_t op1value = m_feedback_in = m_op[0]->compute_volume(m_op[0]->phase() + opmod, am_offset);

	// now that the feedback has been computed, skip the rest if all volumes
	// are clear; no need to do all this work for nothing
	if (m_regs.ch_output_any(m_choffs) == 0)
		return;

	// Algorithms for two-operator case:
	//    0: O1 -> O2 -> out
	//    1: (O1 + O2) -> out
	int32_t result;
	if (bitfield(m_regs.ch_algorithm(m_choffs), 0) == 0)
	{
		// some OPL chips use the previous sample for modulation instead of
		// the current sample
		opmod = (RegisterType::MODULATOR_DELAY ? m_feedback[1] : op1value) >> 1;
		result = m_op[1]->compute_volume(m_op[1]->phase() + opmod, am_offset) >> rshift;
	}
	else
	{
		result = op1value + (m_op[1]->compute_volume(m_op[1]->phase(), am_offset) >> rshift);
		int32_t clipmin = -clipmax - 1;
		result = clamp(result, clipmin, clipmax);
	}

	// add to the output
	add_to_output(m_choffs, output, result);
}
*/

//-------------------------------------------------
//  output_4op - combine 4 operators according to
//  the specified algorithm, returning a sum
//  according to the rshift and clipmax parameters,
//  which vary between different implementations
//-------------------------------------------------
/*
template<class RegisterType>
void fm_channel<RegisterType>::output_4op(output_data &output, uint32_t rshift, int32_t clipmax) const
{
	// all 4 operators should be populated
	assert(m_op[0] != nullptr);
	assert(m_op[1] != nullptr);
	assert(m_op[2] != nullptr);
	assert(m_op[3] != nullptr);

	// AM amount is the same across all operators; compute it once
	uint32_t am_offset = m_regs.lfo_am_offset(m_choffs);

	// operator 1 has optional self-feedback
	int32_t opmod = 0;
	uint32_t feedback = m_regs.ch_feedback(m_choffs);
	if (feedback != 0)
		opmod = (m_feedback[0] + m_feedback[1]) >> (10 - feedback);

	// compute the 14-bit volume/value of operator 1 and update the feedback
	int32_t op1value = m_feedback_in = m_op[0]->compute_volume(m_op[0]->phase() + opmod, am_offset);

	// now that the feedback has been computed, skip the rest if all volumes
	// are clear; no need to do all this work for nothing
	if (m_regs.ch_output_any(m_choffs) == 0)
		return;

	// OPM/OPN offer 8 different connection algorithms for 4 operators,
	// and OPL3 offers 4 more, which we designate here as 8-11.
	//
	// The operators are computed in order, with the inputs pulled from
	// an array of values (opout) that is populated as we go:
	//    0 = 0
	//    1 = O1
	//    2 = O2
	//    3 = O3
	//    4 = (O4)
	//    5 = O1+O2
	//    6 = O1+O3
	//    7 = O2+O3
	//
	// The s_algorithm_ops table describes the inputs and outputs of each
	// algorithm as follows:
	//
	//      ---------x use opout[x] as operator 2 input
	//      ------xxx- use opout[x] as operator 3 input
	//      ---xxx---- use opout[x] as operator 4 input
	//      --x------- include opout[1] in final sum
	//      -x-------- include opout[2] in final sum
	//      x--------- include opout[3] in final sum
	#define ALGORITHM(op2in, op3in, op4in, op1out, op2out, op3out) \
		((op2in) | ((op3in) << 1) | ((op4in) << 4) | ((op1out) << 7) | ((op2out) << 8) | ((op3out) << 9))
	static uint16_t const s_algorithm_ops[8+4] =
	{
		ALGORITHM(1,2,3, 0,0,0),    //  0: O1 -> O2 -> O3 -> O4 -> out (O4)
		ALGORITHM(0,5,3, 0,0,0),    //  1: (O1 + O2) -> O3 -> O4 -> out (O4)
		ALGORITHM(0,2,6, 0,0,0),    //  2: (O1 + (O2 -> O3)) -> O4 -> out (O4)
		ALGORITHM(1,0,7, 0,0,0),    //  3: ((O1 -> O2) + O3) -> O4 -> out (O4)
		ALGORITHM(1,0,3, 0,1,0),    //  4: ((O1 -> O2) + (O3 -> O4)) -> out (O2+O4)
		ALGORITHM(1,1,1, 0,1,1),    //  5: ((O1 -> O2) + (O1 -> O3) + (O1 -> O4)) -> out (O2+O3+O4)
		ALGORITHM(1,0,0, 0,1,1),    //  6: ((O1 -> O2) + O3 + O4) -> out (O2+O3+O4)
		ALGORITHM(0,0,0, 1,1,1),    //  7: (O1 + O2 + O3 + O4) -> out (O1+O2+O3+O4)
		ALGORITHM(1,2,3, 0,0,0),    //  8: O1 -> O2 -> O3 -> O4 -> out (O4)         [same as 0]
		ALGORITHM(0,2,3, 1,0,0),    //  9: (O1 + (O2 -> O3 -> O4)) -> out (O1+O4)   [unique]
		ALGORITHM(1,0,3, 0,1,0),    // 10: ((O1 -> O2) + (O3 -> O4)) -> out (O2+O4) [same as 4]
		ALGORITHM(0,2,0, 1,0,1)     // 11: (O1 + (O2 -> O3) + O4) -> out (O1+O3+O4) [unique]
	};
	uint32_t algorithm_ops = s_algorithm_ops[m_regs.ch_algorithm(m_choffs)];

	// populate the opout table
	int16_t opout[8] = {};
	opout[0] = 0;
	opout[1] = op1value;

	// compute the 14-bit volume/value of operator 2
	opmod = opout[bitfield(algorithm_ops, 0, 1)] >> 1;
	opout[2] = m_op[1]->compute_volume(m_op[1]->phase() + opmod, am_offset);
	opout[5] = opout[1] + opout[2];

	// compute the 14-bit volume/value of operator 3
	opmod = opout[bitfield(algorithm_ops, 1, 3)] >> 1;
	opout[3] = m_op[2]->compute_volume(m_op[2]->phase() + opmod, am_offset);
	opout[6] = opout[1] + opout[3];
	opout[7] = opout[2] + opout[3];

	// compute the 14-bit volume/value of operator 4; this could be a noise
	// value on the OPM; all algorithms consume OP4 output at a minimum
	int32_t result;
	if (m_regs.noise_enable() && m_choffs == 7)
		result = m_op[3]->compute_noise_volume(am_offset);
	else
	{
		opmod = opout[bitfield(algorithm_ops, 4, 3)] >> 1;
		result = m_op[3]->compute_volume(m_op[3]->phase() + opmod, am_offset);
	}
	result >>= rshift;

	// optionally add OP1, OP2, OP3
	int32_t clipmin = -clipmax - 1;
	if (bitfield(algorithm_ops, 7) != 0)
		result = clamp(result + (opout[1] >> rshift), clipmin, clipmax);
	if (bitfield(algorithm_ops, 8) != 0)
		result = clamp(result + (opout[2] >> rshift), clipmin, clipmax);
	if (bitfield(algorithm_ops, 9) != 0)
		result = clamp(result + (opout[3] >> rshift), clipmin, clipmax);

	// add to the output
	add_to_output(m_choffs, output, result);
}
*/

//-------------------------------------------------
//  output_rhythm_ch6 - special case output
//  computation for OPL channel 6 in rhythm mode,
//  which outputs a Bass Drum instrument
//-------------------------------------------------
/*
template<class RegisterType>
void fm_channel<RegisterType>::output_rhythm_ch6(output_data &output, uint32_t rshift, int32_t clipmax) const
{
	// AM amount is the same across all operators; compute it once
	uint32_t am_offset = m_regs.lfo_am_offset(m_choffs);

	// Bass Drum: this uses operators 12 and 15 (i.e., channel 6)
	// in an almost-normal way, except that if the algorithm is 1,
	// the first operator is ignored instead of added in

	// operator 1 has optional self-feedback
	int32_t opmod = 0;
	uint32_t feedback = m_regs.ch_feedback(m_choffs);
	if (feedback != 0)
		opmod = (m_feedback[0] + m_feedback[1]) >> (10 - feedback);

	// compute the 14-bit volume/value of operator 1 and update the feedback
	int32_t opout1 = m_feedback_in = m_op[0]->compute_volume(m_op[0]->phase() + opmod, am_offset);

	// compute the 14-bit volume/value of operator 2, which is the result
	opmod = bitfield(m_regs.ch_algorithm(m_choffs), 0) ? 0 : (opout1 >> 1);
	int32_t result = m_op[1]->compute_volume(m_op[1]->phase() + opmod, am_offset) >> rshift;

	// add to the output
	add_to_output(m_choffs, output, result * 2);
}
*/

//-------------------------------------------------
//  output_rhythm_ch7 - special case output
//  computation for OPL channel 7 in rhythm mode,
//  which outputs High Hat and Snare Drum
//  instruments
//-------------------------------------------------
/*
template<class RegisterType>
void fm_channel<RegisterType>::output_rhythm_ch7(uint32_t phase_select, output_data &output, uint32_t rshift, int32_t clipmax) const
{
	// AM amount is the same across all operators; compute it once
	uint32_t am_offset = m_regs.lfo_am_offset(m_choffs);
	uint32_t noise_state = bitfield(m_regs.noise_state(), 0);

	// High Hat: this uses the envelope from operator 13 (channel 7),
	// and a combination of noise and the operator 13/17 phase select
	// to compute the phase
	uint32_t phase = (phase_select << 9) | (0xd0 >> (2 * (noise_state ^ phase_select)));
	int32_t result = m_op[0]->compute_volume(phase, am_offset) >> rshift;

	// Snare Drum: this uses the envelope from operator 16 (channel 7),
	// and a combination of noise and operator 13 phase to pick a phase
	uint32_t op13phase = m_op[0]->phase();
	phase = (0x100 << bitfield(op13phase, 8)) ^ (noise_state << 8);
	result += m_op[1]->compute_volume(phase, am_offset) >> rshift;
	result = clamp(result, -clipmax - 1, clipmax);

	// add to the output
	add_to_output(m_choffs, output, result * 2);
}
*/

//-------------------------------------------------
//  output_rhythm_ch8 - special case output
//  computation for OPL channel 8 in rhythm mode,
//  which outputs Tom Tom and Top Cymbal instruments
//-------------------------------------------------
/*
template<class RegisterType>
void fm_channel<RegisterType>::output_rhythm_ch8(uint32_t phase_select, output_data &output, uint32_t rshift, int32_t clipmax) const
{
	// AM amount is the same across all operators; compute it once
	uint32_t am_offset = m_regs.lfo_am_offset(m_choffs);

	// Tom Tom: this is just a single operator processed normally
	int32_t result = m_op[0]->compute_volume(m_op[0]->phase(), am_offset) >> rshift;

	// Top Cymbal: this uses the envelope from operator 17 (channel 8),
	// and the operator 13/17 phase select to compute the phase
	uint32_t phase = 0x100 | (phase_select << 9);
	result += m_op[1]->compute_volume(phase, am_offset) >> rshift;
	result = clamp(result, -clipmax - 1, clipmax);

	// add to the output
	add_to_output(m_choffs, output, result * 2);
}
*/


//*********************************************************
//  FM ENGINE BASE
//*********************************************************

//-------------------------------------------------
//  fm_engine_base - constructor
//-------------------------------------------------
/*
template<class RegisterType>
fm_engine_base<RegisterType>::fm_engine_base<RegisterType>(ymfm_interface &intf) :
	m_intf(intf),
	m_env_counter(0),
	m_status(0),
	m_clock_prescale(RegisterType::DEFAULT_PRESCALE),
	m_irq_mask(STATUS_TIMERA | STATUS_TIMERB),
	m_irq_state(0),
	m_timer_running{0,0},
	m_active_channels(ALL_CHANNELS),
	m_modified_channels(ALL_CHANNELS),
	m_prepare_count(0)
{
	// inform the interface of their engine
	m_intf.m_engine = this;

	// create the channels
	for (uint32_t chnum = 0; chnum < CHANNELS; chnum++)
		m_channel[chnum] = std::make_unique<fm_channel<RegisterType>>(*this, RegisterType::channel_offset(chnum));

	// create the operators
	for (uint32_t opnum = 0; opnum < OPERATORS; opnum++)
		m_operator[opnum] = std::make_unique<fm_operator<RegisterType>>(*this, RegisterType::operator_offset(opnum));

	// do the initial operator assignment
	assign_operators();
}
*/


//-------------------------------------------------
//  reset - reset the overall state
//-------------------------------------------------
/*
template<class RegisterType>
void fm_engine_base<RegisterType>::reset()
{
	// reset all status bits
	set_reset_status(0, 0xff);

	// register type-specific initialization
	m_regs.reset();

	// explicitly write to the mode register since it has side-effects
	// QUESTION: old cores initialize this to 0x30 -- who is right?
	write(RegisterType::REG_MODE, 0);

	// reset the channels
	for (auto &chan : m_channel)
		chan->reset();

	// reset the operators
	for (auto &op : m_operator)
		op->reset();
}
*/


//-------------------------------------------------
//  save_restore - save or restore the data
//-------------------------------------------------
/*
template<class RegisterType>
void fm_engine_base<RegisterType>::save_restore(ymfm_saved_state &state)
{
	// save our data
	state.save_restore(m_env_counter);
	state.save_restore(m_status);
	state.save_restore(m_clock_prescale);
	state.save_restore(m_irq_mask);
	state.save_restore(m_irq_state);
	state.save_restore(m_timer_running[0]);
	state.save_restore(m_timer_running[1]);

	// save the register/family data
	m_regs.save_restore(state);

	// save channel data
	for (uint32_t chnum = 0; chnum < CHANNELS; chnum++)
		m_channel[chnum]->save_restore(state);

	// save operator data
	for (uint32_t opnum = 0; opnum < OPERATORS; opnum++)
		m_operator[opnum]->save_restore(state);

	// invalidate any caches
	invalidate_caches();
}
*/

//-------------------------------------------------
//  clock - iterate over all channels, clocking
//  them forward one step
//-------------------------------------------------
/*
template<class RegisterType>
uint32_t fm_engine_base<RegisterType>::clock(uint32_t chanmask)
{
	// if something was modified, prepare
	// also prepare every 4k samples to catch ending notes
	if (m_modified_channels != 0 || m_prepare_count++ >= 4096)
	{
		// reassign operators to channels if dynamic
		if (RegisterType::DYNAMIC_OPS)
			assign_operators();

		// call each channel to prepare
		m_active_channels = 0;
		for (uint32_t chnum = 0; chnum < CHANNELS; chnum++)
			if (bitfield(chanmask, chnum))
				if (m_channel[chnum]->prepare())
					m_active_channels |= 1 << chnum;

		// reset the modified channels and prepare count
		m_modified_channels = m_prepare_count = 0;
	}

	// if the envelope clock divider is 1, just increment by 4;
	// otherwise, increment by 1 and manually wrap when we reach the divide count
	if (RegisterType::EG_CLOCK_DIVIDER == 1)
		m_env_counter += 4;
	else if (bitfield(++m_env_counter, 0, 2) == RegisterType::EG_CLOCK_DIVIDER)
		m_env_counter += 4 - RegisterType::EG_CLOCK_DIVIDER;

	// clock the noise generator
	int32_t lfo_raw_pm = m_regs.clock_noise_and_lfo();

	// now update the state of all the channels and operators
	for (uint32_t chnum = 0; chnum < CHANNELS; chnum++)
		if (bitfield(chanmask, chnum))
			m_channel[chnum]->clock(m_env_counter, lfo_raw_pm);

#if 0
//Temporary debugging...
static double curtime = 0;
//for (uint32_t chnum = 0; chnum < CHANNELS; chnum++)
uint32_t chnum = 4;
{
	printf("t=%.4f ch%d: ", curtime, chnum);
	for (uint32_t opnum = 0; opnum < 4; opnum++)
	{
		auto op = debug_channel(chnum)->debug_operator(opnum);
		auto eg_state = op->debug_eg_state();
		printf(" %c%03X[%02X]%c ", "PADSRV"[eg_state], op.debug_eg_attenuation(), op.debug_cache().eg_rate[eg_state], m_regs.op_ssg_eg_enable(op.opoffs()) ? '*' : ' ');
	}
	printf(" -- ");
}
curtime += 1.0 / double(sample_rate(7670454));
#endif

	// return the envelope counter as it is used to clock ADPCM-A
	return m_env_counter;
}
*/

//-------------------------------------------------
//  output - compute a sum over the relevant
//  channels
//-------------------------------------------------
/*
template<class RegisterType>
void fm_engine_base<RegisterType>::output(output_data &output, uint32_t rshift, int32_t clipmax, uint32_t chanmask) const
{
	// mask out some channels for debug purposes
	chanmask &= debug::GLOBAL_FM_CHANNEL_MASK;

	// mask out inactive channels
	chanmask &= m_active_channels;

	// handle the rhythm case, where some of the operators are dedicated
	// to percussion (this is an OPL-specific feature)
	if (m_regs.rhythm_enable())
	{
		// we don't support the OPM noise channel here; ensure it is off
		assert(m_regs.noise_enable() == 0);

		// precompute the operator 13+17 phase selection value
		uint32_t op13phase = m_operator[13]->phase();
		uint32_t op17phase = m_operator[17]->phase();
		uint32_t phase_select = (bitfield(op13phase, 2) ^ bitfield(op13phase, 7)) | bitfield(op13phase, 3) | (bitfield(op17phase, 5) ^ bitfield(op17phase, 3));

		// sum over all the desired channels
		for (uint32_t chnum = 0; chnum < CHANNELS; chnum++)
			if (bitfield(chanmask, chnum))
			{
				if (chnum == 6)
					m_channel[chnum]->output_rhythm_ch6(output, rshift, clipmax);
				else if (chnum == 7)
					m_channel[chnum]->output_rhythm_ch7(phase_select, output, rshift, clipmax);
				else if (chnum == 8)
					m_channel[chnum]->output_rhythm_ch8(phase_select, output, rshift, clipmax);
				else if (m_channel[chnum]->is4op())
					m_channel[chnum]->output_4op(output, rshift, clipmax);
				else
					m_channel[chnum]->output_2op(output, rshift, clipmax);
			}
	}
	else
	{
		// sum over all the desired channels
		for (uint32_t chnum = 0; chnum < CHANNELS; chnum++)
			if (bitfield(chanmask, chnum))
			{
				if (m_channel[chnum]->is4op())
					m_channel[chnum]->output_4op(output, rshift, clipmax);
				else
					m_channel[chnum]->output_2op(output, rshift, clipmax);
			}
	}
}
*/

//-------------------------------------------------
//  write - handle writes to the OPN registers
//-------------------------------------------------
/*
template<class RegisterType>
void fm_engine_base<RegisterType>::write(uint16_t regnum, uint8_t data)
{
	debug::log_fm_write("%03X = %02X\n", regnum, data);

	// special case: writes to the mode register can impact IRQs;
	// schedule these writes to ensure ordering with timers
	if (regnum == RegisterType::REG_MODE)
	{
		m_intf.ymfm_sync_mode_write(data);
		return;
	}

	// for now just mark all channels as modified
	m_modified_channels = ALL_CHANNELS;

	// most writes are passive, consumed only when needed
	uint32_t keyon_channel = 0;
	uint32_t keyon_opmask = 0;
	if (m_regs.write(regnum, data, keyon_channel, keyon_opmask))
	{
		// handle writes to the keyon register(s)
		if (keyon_channel < CHANNELS)
		{
			// normal channel on/off
			m_channel[keyon_channel]->keyonoff(keyon_opmask, KEYON_NORMAL, keyon_channel);
		}
		else if (CHANNELS >= 9 && keyon_channel == RegisterType::RHYTHM_CHANNEL)
		{
			// special case for the OPL rhythm channels
			m_channel[6]->keyonoff(bitfield(keyon_opmask, 4) ? 3 : 0, KEYON_RHYTHM, 6);
			m_channel[7]->keyonoff(bitfield(keyon_opmask, 0) | (bitfield(keyon_opmask, 3) << 1), KEYON_RHYTHM, 7);
			m_channel[8]->keyonoff(bitfield(keyon_opmask, 2) | (bitfield(keyon_opmask, 1) << 1), KEYON_RHYTHM, 8);
		}
	}
}
*/


//-------------------------------------------------
//  status - return the current state of the
//  status flags
//-------------------------------------------------
/*
template<class RegisterType>
uint8_t fm_engine_base<RegisterType>::status() const
{
	return m_status & ~STATUS_BUSY & ~m_regs.status_mask();
}
*/

//-------------------------------------------------
//  assign_operators - get the current mapping of
//  operators to channels and assign them all
//-------------------------------------------------
/*
template<class RegisterType>
void fm_engine_base<RegisterType>::assign_operators()
{
	typename RegisterType::operator_mapping map = {};
	m_regs.operator_map(map);

	for (uint32_t chnum = 0; chnum < CHANNELS; chnum++)
		for (uint32_t index = 0; index < 4; index++)
		{
			uint32_t opnum = bitfield(map.chan[chnum], 8 * index, 8);
			m_channel[chnum]->assign(index, (opnum == 0xff) ? nullptr : m_operator[opnum].get());
		}
}
*/
//-------------------------------------------------
//  update_timer - update the state of the given
//  timer
//-------------------------------------------------
/*
template<class RegisterType>
void fm_engine_base<RegisterType>::update_timer(uint32_t tnum, uint32_t enable)
{
	// if the timer is live, but not currently enabled, set the timer
	if (enable && !m_timer_running[tnum])
	{
		// period comes from the registers, and is different for each
		uint32_t period = (tnum == 0) ? (1024 - m_regs.timer_a_value()) : 16 * (256 - m_regs.timer_b_value());

		// reset it
		m_intf.ymfm_set_timer(tnum, period * OPERATORS * m_clock_prescale);
		m_timer_running[tnum] = 1;
	}

	// if the timer is not live, ensure it is not enabled
	else if (!enable)
	{
		m_intf.ymfm_set_timer(tnum, -1);
		m_timer_running[tnum] = 0;
	}
}
*/

//-------------------------------------------------
//  engine_timer_expired - timer has expired - signal
//  status and possibly IRQs
//-------------------------------------------------
/*
template<class RegisterType>
void fm_engine_base<RegisterType>::engine_timer_expired(uint32_t tnum)
{
	// update status
	if (tnum == 0 && m_regs.enable_timer_a())
		set_reset_status(STATUS_TIMERA, 0);
	else if (tnum == 1 && m_regs.enable_timer_b())
		set_reset_status(STATUS_TIMERB, 0);

	// if timer A fired in CSM mode, trigger CSM on all relevant channels
	if (tnum == 0 && m_regs.csm())
		for (uint32_t chnum = 0; chnum < CHANNELS; chnum++)
			if (bitfield(RegisterType::CSM_TRIGGER_MASK, chnum))
				m_channel[chnum]->keyonoff(1, KEYON_CSM, chnum);

	// reset
	m_timer_running[tnum] = false;
	update_timer(tnum, 1);
}
*/

//-------------------------------------------------
//  check_interrupts - check the interrupt sources
//  for interrupts
//-------------------------------------------------
/*
template<class RegisterType>
void fm_engine_base<RegisterType>::engine_check_interrupts()
{
	// update the state
	uint8_t old_state = m_irq_state;
	m_irq_state = ((m_status & m_irq_mask & ~m_regs.status_mask()) != 0);

	// set the IRQ status bit
	if (m_irq_state)
		m_status |= STATUS_IRQ;
	else
		m_status &= ~STATUS_IRQ;

	// if changed, signal the new state
	if (old_state != m_irq_state)
		m_intf.ymfm_update_irq(m_irq_state ? true : false);
}
*/

//-------------------------------------------------
//  engine_mode_write - handle a mode register write
//  via timer callback
//-------------------------------------------------
/*
template<class RegisterType>
void fm_engine_base<RegisterType>::engine_mode_write(uint8_t data)
{
	// mark all channels as modified
	m_modified_channels = ALL_CHANNELS;

	// actually write the mode register now
	uint32_t dummy1 = 0, dummy2 = 0;
	m_regs.write(RegisterType::REG_MODE, data, dummy1, dummy2);

	// reset IRQ status -- when written, all other bits are ignored
	// QUESTION: should this maybe just reset the IRQ bit and not all the bits?
	//   That is, check_interrupts would only set, this would only clear?
	if (m_regs.irq_reset())
		set_reset_status(0, 0x78);
	else
	{
		// reset timer status
		uint8_t reset_mask = 0;
		if (m_regs.reset_timer_b())
			reset_mask |= RegisterType::STATUS_TIMERB;
		if (m_regs.reset_timer_a())
			reset_mask |= RegisterType::STATUS_TIMERA;
		set_reset_status(0, reset_mask);

		// load timers
		update_timer(1, m_regs.load_timer_b());
		update_timer(0, m_regs.load_timer_a());
	}
}
*/
}
