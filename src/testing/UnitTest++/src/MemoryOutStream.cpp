#include "MemoryOutStream.h"

#ifndef UNITTEST_USE_CUSTOM_STREAMS


namespace UnitTest {

char const* MemoryOutStream::GetText() const
{
    m_text = this->str();
    return m_text.c_str();
}


}


#else


#include <cstring>
#include <cstdio>

namespace UnitTest {

namespace {

template<typename ValueType>
void FormatToStream(MemoryOutStream& stream, char const* format, ValueType const& value)
{
    char txt[32];
    std::sprintf(txt, format, value);
    stream << txt;
}

int RoundUpToMultipleOfPow2Number (int n, int pow2Number)
{
    return (n + (pow2Number - 1)) & ~(pow2Number - 1);
}

}


MemoryOutStream::MemoryOutStream(int const size)
    : m_capacity (0)
    , m_buffer (0)

{
    GrowBuffer(size);
}

MemoryOutStream::~MemoryOutStream()
{
    delete [] m_buffer;
}

char const* MemoryOutStream::GetText() const
{
    return m_buffer;
}

MemoryOutStream& MemoryOutStream::operator << (char const* txt)
{
    int const bytesLeft = m_capacity - (int)std::strlen(m_buffer);
    int const bytesRequired = (int)std::strlen(txt) + 1;

    if (bytesRequired > bytesLeft)
    {
        int const requiredCapacity = bytesRequired + m_capacity - bytesLeft;
        GrowBuffer(requiredCapacity);
    }

    std::strcat(m_buffer, txt);
    return *this;
}

MemoryOutStream& MemoryOutStream::operator << (int const n)
{
    FormatToStream(*this, "%i", n);
    return *this;
}

MemoryOutStream& MemoryOutStream::operator << (long const n)
{
    FormatToStream(*this, "%li", n);
    return *this;
}

MemoryOutStream& MemoryOutStream::operator << (unsigned long const n)
{
    FormatToStream(*this, "%lu", n);
    return *this;
}

MemoryOutStream& MemoryOutStream::operator << (float const f)
{
    FormatToStream(*this, "%ff", f);
    return *this;    
}

MemoryOutStream& MemoryOutStream::operator << (void const* p)
{
    FormatToStream(*this, "%p", p);
    return *this;    
}

MemoryOutStream& MemoryOutStream::operator << (unsigned int const s)
{
    FormatToStream(*this, "%u", s);
    return *this;    
}

MemoryOutStream& MemoryOutStream::operator <<(double const d)
{
	FormatToStream(*this, "%f", d);
	return *this;
}

int MemoryOutStream::GetCapacity() const
{
    return m_capacity;
}


void MemoryOutStream::GrowBuffer(int const desiredCapacity)
{
    int const newCapacity = RoundUpToMultipleOfPow2Number(desiredCapacity, GROW_CHUNK_SIZE);

    char* buffer = new char[newCapacity];
    if (m_buffer)
        std::strcpy(buffer, m_buffer);
    else
        std::strcpy(buffer, "");

    delete [] m_buffer;
    m_buffer = buffer;
    m_capacity = newCapacity;
}

}


#endif
