/*
 * Copyright (C) 2018-2021 Rerrah
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

#pragma once
#include <vector>
#include "sequence_iterator_interface.h"
#include "sequence_property.h"

class ArpeggioEffectIterator : public SequenceIteratorInterface<InstrumentSequenceBaseUnit>
{
public:
	ArpeggioEffectIterator(int second, int third);
	SequenceType type() const noexcept override { return SequenceType::AbsoluteSequence; }

	InstrumentSequenceBaseUnit data() const noexcept override;

	int next() override;
	int front() override;
	inline int release() override { return next(); }
	int end() override;

private:
	bool started_;
	InstrumentSequenceBaseUnit second_, third_;
};

class WavingEffectIterator : public SequenceIteratorInterface<InstrumentSequenceBaseUnit>
{
public:
	WavingEffectIterator(int period, int depth);
	SequenceType type() const noexcept override { return SequenceType::AbsoluteSequence; }

	InstrumentSequenceBaseUnit data() const override;

	int next() override;
	int front() override;
	inline int release() override { return next(); }
	int end() override;

private:
	bool started_;
	std::vector<InstrumentSequenceBaseUnit> seq_;
};

class NoteSlideEffectIterator : public SequenceIteratorInterface<InstrumentSequenceBaseUnit>
{
public:
	NoteSlideEffectIterator(int speed, int seminote);
	SequenceType type() const noexcept override { return SequenceType::AbsoluteSequence; }

	InstrumentSequenceBaseUnit data() const override;

	int next() override;
	int front() override;
	inline int release() override { return next(); }
	int end() override;

private:
	bool started_;
	std::vector<InstrumentSequenceBaseUnit> seq_;
};
