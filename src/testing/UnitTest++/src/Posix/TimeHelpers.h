#ifndef UNITTEST_TIMEHELPERS_H
#define UNITTEST_TIMEHELPERS_H

#include <sys/time.h>

namespace UnitTest {

class Timer
{
public:
    Timer();
    void Start();
    int GetTimeInMs() const;    

private:
    struct timeval m_startTime;    
};


namespace TimeHelpers
{
void SleepMs (int ms);
}


}

#endif
