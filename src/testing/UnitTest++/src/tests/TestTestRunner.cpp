#include "../UnitTest++.h"
#include "RecordingReporter.h"
#include "../ReportAssert.h"
#include "../TestList.h"
#include "../TimeHelpers.h"
#include "../TimeConstraint.h"

using namespace UnitTest;

namespace
{

struct MockTest : public Test
{
    MockTest(char const* testName, bool const success_, bool const assert_, int const count_ = 1)
        : Test(testName)
        , success(success_)
        , asserted(assert_)
        , count(count_)
    {
    }

    virtual void RunImpl(TestResults& testResults_) const
    {
        for (int i=0; i < count; ++i)
        {
            if (asserted)
                ReportAssert("desc", "file", 0);
            else if (!success)
                testResults_.OnTestFailure(m_details, "message");
        }
    }

    bool const success;
    bool const asserted;
    int const count;
};


struct TestRunnerFixture
{
    RecordingReporter reporter;
    TestList list;
};

TEST_FIXTURE(TestRunnerFixture, TestStartIsReportedCorrectly)
{
    MockTest test("goodtest", true, false);
    list.Add(&test);

    RunAllTests(reporter, list, 0);
    CHECK_EQUAL(1, reporter.testRunCount);
    CHECK_EQUAL("goodtest", reporter.lastStartedTest);
}

TEST_FIXTURE(TestRunnerFixture, TestFinishIsReportedCorrectly)
{
    MockTest test("goodtest", true, false);
    list.Add(&test);

    RunAllTests(reporter, list, 0);
    CHECK_EQUAL(1, reporter.testFinishedCount);
    CHECK_EQUAL("goodtest", reporter.lastFinishedTest);
}

class SlowTest : public Test
{
public:
    SlowTest() : Test("slow", "somesuite", "filename", 123) {}
    virtual void RunImpl(TestResults&) const
    {
        TimeHelpers::SleepMs(20);
    }
};

TEST_FIXTURE(TestRunnerFixture, TestFinishIsCalledWithCorrectTime)
{
    SlowTest test;
    list.Add(&test);

    RunAllTests(reporter, list, 0);
    CHECK (reporter.lastFinishedTestTime >= 0.005f && reporter.lastFinishedTestTime <= 0.050f);
}

TEST_FIXTURE(TestRunnerFixture, FailureCountIsZeroWhenNoTestsAreRun)
{
    CHECK_EQUAL(0, RunAllTests(reporter, list, 0));
    CHECK_EQUAL(0, reporter.testRunCount);
    CHECK_EQUAL(0, reporter.testFailedCount);
}

TEST_FIXTURE(TestRunnerFixture, CallsReportFailureOncePerFailingTest)
{
    MockTest test1("test", false, false);
    list.Add(&test1);
    MockTest test2("test", true, false);
    list.Add(&test2);
    MockTest test3("test", false, false);
    list.Add(&test3);

    CHECK_EQUAL(2, RunAllTests(reporter, list, 0));
    CHECK_EQUAL(2, reporter.testFailedCount);
}

TEST_FIXTURE(TestRunnerFixture, TestsThatAssertAreReportedAsFailing)
{
    MockTest test("test", true, true);
    list.Add(&test);

    RunAllTests(reporter, list, 0);
    CHECK_EQUAL(1, reporter.testFailedCount);
}


TEST_FIXTURE(TestRunnerFixture, ReporterNotifiedOfTestCount)
{
    MockTest test1("test", true, false);
    MockTest test2("test", true, false);
    MockTest test3("test", true, false);
    list.Add(&test1);
    list.Add(&test2);
    list.Add(&test3);

    RunAllTests(reporter, list, 0);
    CHECK_EQUAL(3, reporter.summaryTotalTestCount);
}

TEST_FIXTURE(TestRunnerFixture, ReporterNotifiedOfFailedTests)
{
    MockTest test1("test", false, false, 2);
    MockTest test2("test", true, false);
    MockTest test3("test", false, false, 3);
    list.Add(&test1);
    list.Add(&test2);
    list.Add(&test3);

    RunAllTests(reporter, list, 0);
    CHECK_EQUAL(2, reporter.summaryFailedTestCount);
}

TEST_FIXTURE(TestRunnerFixture, ReporterNotifiedOfFailures)
{
    MockTest test1("test", false, false, 2);
    MockTest test2("test", true, false);
    MockTest test3("test", false, false, 3);
    list.Add(&test1);
    list.Add(&test2);
    list.Add(&test3);

    RunAllTests(reporter, list, 0);
    CHECK_EQUAL(5, reporter.summaryFailureCount);
}

TEST_FIXTURE(TestRunnerFixture, SlowTestPassesForHighTimeThreshold)
{
    SlowTest test;
    list.Add(&test);
    RunAllTests(reporter, list, 0);
    CHECK_EQUAL (0, reporter.testFailedCount);
}

TEST_FIXTURE(TestRunnerFixture, SlowTestFailsForLowTimeThreshold)
{
    SlowTest test;
    list.Add(&test);
    RunAllTests(reporter, list, 0, 3);
    CHECK_EQUAL (1, reporter.testFailedCount);
}

TEST_FIXTURE(TestRunnerFixture, SlowTestHasCorrectFailureInformation)
{
    SlowTest test;
    list.Add(&test);
    RunAllTests(reporter, list, 0, 3);
    CHECK_EQUAL (test.m_details.testName, reporter.lastFailedTest);
    CHECK (std::strstr(test.m_details.filename, reporter.lastFailedFile));
    CHECK_EQUAL (test.m_details.lineNumber, reporter.lastFailedLine);
    CHECK (std::strstr(reporter.lastFailedMessage, "Global time constraint failed"));
    CHECK (std::strstr(reporter.lastFailedMessage, "3ms"));
}

TEST_FIXTURE(TestRunnerFixture, SlowTestWithTimeExemptionPasses)
{
    class SlowExemptedTest : public Test
    {
    public:
        SlowExemptedTest() : Test("slowexempted", "", 0) {}
        virtual void RunImpl(TestResults&) const
        {
            UNITTEST_TIME_CONSTRAINT_EXEMPT();
            TimeHelpers::SleepMs(20);
        }
    };

    SlowExemptedTest test;
    list.Add(&test);
    RunAllTests(reporter, list, 0, 3);
    CHECK_EQUAL (0, reporter.testFailedCount);
}

struct TestSuiteFixture
{
    TestSuiteFixture()
        : test1("TestInDefaultSuite")
        , test2("TestInOtherSuite", "OtherSuite")
        , test3("SecondTestInDefaultSuite")
    {
        list.Add(&test1);
        list.Add(&test2);
    }

    Test test1;
    Test test2;
    Test test3;
    RecordingReporter reporter;
    TestList list;
};

TEST_FIXTURE(TestSuiteFixture, TestRunnerRunsAllSuitesIfNullSuiteIsPassed)
{
    RunAllTests(reporter, list, 0);
    CHECK_EQUAL(2, reporter.summaryTotalTestCount);
}

TEST_FIXTURE(TestSuiteFixture,TestRunnerRunsOnlySpecifiedSuite)
{
    RunAllTests(reporter, list, "OtherSuite");
    CHECK_EQUAL(1, reporter.summaryTotalTestCount);
    CHECK_EQUAL("TestInOtherSuite", reporter.lastFinishedTest);
}


}
