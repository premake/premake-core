#include "../UnitTest++.h"
#include "../TimeHelpers.h"

#include "RecordingReporter.h"

namespace {

TEST (TimeConstraintMacroQualifiesNamespace)
{
    // If this compiles without a "using namespace UnitTest;", all is well.
    UNITTEST_TIME_CONSTRAINT(1);
}

TEST (TimeConstraintMacroUsesCorrectInfo)
{
    int testLine = 0;
    RecordingReporter reporter;
    {
        UnitTest::TestResults testResults_(&reporter);
        UNITTEST_TIME_CONSTRAINT(10);                    testLine = __LINE__;
        UnitTest::TimeHelpers::SleepMs(20);
    }
    CHECK_EQUAL (1, reporter.testFailedCount);
    CHECK (std::strstr(reporter.lastFailedFile, __FILE__));
    CHECK_EQUAL (testLine, reporter.lastFailedLine);
    CHECK (std::strstr(reporter.lastFailedTest, "TimeConstraintMacroUsesCorrectInfo"));
}

}
