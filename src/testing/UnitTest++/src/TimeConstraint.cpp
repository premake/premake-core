#include "TimeConstraint.h"
#include "TestResults.h"
#include "MemoryOutStream.h"

namespace UnitTest {


TimeConstraint::TimeConstraint(int ms, TestResults& result, TestDetails const& details)
    : m_result(result)
	, m_details(details)
    , m_maxMs(ms)
{
    m_timer.Start();
}

TimeConstraint::~TimeConstraint()
{
    int const totalTimeInMs = m_timer.GetTimeInMs();
    if (totalTimeInMs > m_maxMs)
    {
        MemoryOutStream stream;
        stream << "Time constraint failed. Expected to run test under " << m_maxMs <<
                  "ms but took " << totalTimeInMs << "ms.";
        m_result.OnTestFailure(m_details, stream.GetText());
    }
}

}
