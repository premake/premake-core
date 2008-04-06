#include "../UnitTest++.h"
#include "../TestReporter.h"
#include "../TimeHelpers.h"

using namespace UnitTest;

namespace {

TEST (PassingTestHasNoFailures)
{
    class PassingTest : public Test
    {
    public:
        PassingTest() : Test("passing") {}
        virtual void RunImpl(TestResults& testResults_) const
        {
            CHECK(true);
        }
    };

    TestResults results;
    PassingTest().Run(results);
    CHECK_EQUAL(0, results.GetFailureCount());
}


TEST (FailingTestHasFailures)
{
    class FailingTest : public Test
    {
    public:
        FailingTest() : Test("failing") {}
        virtual void RunImpl(TestResults& testResults_) const
        {
            CHECK(false);
        }
    };

    TestResults results;
    FailingTest().Run(results);
    CHECK_EQUAL(1, results.GetFailureCount());
}


TEST (ThrowingTestsAreReportedAsFailures)
{
    class CrashingTest : public Test
    {
    public:
        CrashingTest() : Test("throwing") {}
        virtual void RunImpl(TestResults&) const
        {
            throw "Blah";
        }
    };
 
    TestResults results;
    CrashingTest().Run(results);
    CHECK_EQUAL(1, results.GetFailureCount());
}


#ifndef UNITTEST_MINGW
TEST (CrashingTestsAreReportedAsFailures)
{
    class CrashingTest : public Test
    {
    public:
        CrashingTest() : Test("crashing") {}
        virtual void RunImpl(TestResults&) const
        {
            reinterpret_cast< void (*)() >(0)();
        }
    };

    TestResults results;
    CrashingTest().Run(results);
    CHECK_EQUAL(1, results.GetFailureCount());
}
#endif

TEST (TestWithUnspecifiedSuiteGetsDefaultSuite)
{
    Test test("test");
    CHECK(test.m_details.suiteName != NULL);
    CHECK_EQUAL("DefaultSuite", test.m_details.suiteName);
}

TEST (TestReflectsSpecifiedSuiteName)
{
    Test test("test", "testSuite");
    CHECK(test.m_details.suiteName != NULL);
    CHECK_EQUAL("testSuite", test.m_details.suiteName);
}


}
