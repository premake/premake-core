#include "TimeHelpers.h"
#include <windows.h>

namespace UnitTest {

Timer::Timer()
    : m_startTime(0)
{
    m_threadId = ::GetCurrentThread();
    DWORD_PTR systemMask;
    ::GetProcessAffinityMask(GetCurrentProcess(), &m_processAffinityMask, &systemMask);
    
    ::SetThreadAffinityMask(m_threadId, 1);
	::QueryPerformanceFrequency(reinterpret_cast< LARGE_INTEGER* >(&m_frequency));
    ::SetThreadAffinityMask(m_threadId, m_processAffinityMask);
}

void Timer::Start()
{
    m_startTime = GetTime();
}

int Timer::GetTimeInMs() const
{
    __int64 const elapsedTime = GetTime() - m_startTime;
	double const seconds = double(elapsedTime) / double(m_frequency);
	return int(seconds * 1000.0f);
}

__int64 Timer::GetTime() const
{
    LARGE_INTEGER curTime;
    ::SetThreadAffinityMask(m_threadId, 1);
	::QueryPerformanceCounter(&curTime);
    ::SetThreadAffinityMask(m_threadId, m_processAffinityMask);
    return curTime.QuadPart;
}



void TimeHelpers::SleepMs(int const ms)
{
	::Sleep(ms);
}

}
