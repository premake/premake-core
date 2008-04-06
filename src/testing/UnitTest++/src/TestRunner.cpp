#include "TestRunner.h"
#include "TestResults.h"
#include "Test.h"
#include "TestList.h"
#include "TestReporter.h"
#include "TestReporterStdout.h"
#include "TimeHelpers.h"
#include "MemoryOutStream.h"
#include <cstring>


namespace UnitTest {


int RunAllTests(TestReporter& reporter, TestList const& list, char const* suiteName, int const maxTestTimeInMs )
{
    TestResults result(&reporter);

    Timer overallTimer;
    overallTimer.Start();

    Test const* curTest = list.GetHead();
    while (curTest != 0)
    {
        if (suiteName == 0 || !std::strcmp(curTest->m_details.suiteName, suiteName))
        {
            Timer testTimer;
            testTimer.Start();
            result.OnTestStart(curTest->m_details);

            curTest->Run(result);

            int const testTimeInMs = testTimer.GetTimeInMs();
            if (maxTestTimeInMs > 0 && testTimeInMs > maxTestTimeInMs && !curTest->m_timeConstraintExempt)
            {
                MemoryOutStream stream;
                stream << "Global time constraint failed. Expected under " << maxTestTimeInMs <<
                        "ms but took " << testTimeInMs << "ms.";
                result.OnTestFailure(curTest->m_details, stream.GetText());
            }
            result.OnTestFinish(curTest->m_details, testTimeInMs/1000.0f);
        }

        curTest = curTest->next;
    }

    float const secondsElapsed = overallTimer.GetTimeInMs() / 1000.0f;
    reporter.ReportSummary(result.GetTotalTestCount(), result.GetFailedTestCount(), result.GetFailureCount(), secondsElapsed);

    return result.GetFailureCount();
}


int RunAllTests()
{
    TestReporterStdout reporter;
    return RunAllTests(reporter, Test::GetTestList(), 0);
}

}
