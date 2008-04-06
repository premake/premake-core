#include "../UnitTest++.h"
#include "../TestMacros.h"
#include "../TestList.h"
#include "../TestResults.h"
#include "../TestReporter.h"
#include "RecordingReporter.h"

using namespace UnitTest;

namespace {

TestList list1;
TEST_EX(DummyTest, list1)
{
    (void)testResults_;
}

TEST (TestsAreAddedToTheListThroughMacro)
{
    CHECK (list1.GetHead() != 0);
    CHECK (list1.GetHead()->next == 0);
}

struct ThrowingThingie
{
    ThrowingThingie() : dummy(false)
    {
        if (!dummy)
            throw "Oops";
    } 
    bool dummy;
};

TestList list2;
TEST_FIXTURE_EX(ThrowingThingie,DummyTestName,list2)
{
    (void)testResults_;
}

TEST (ExceptionsInFixtureAreReportedAsHappeningInTheFixture)
{
    RecordingReporter reporter;
    TestResults result(&reporter);
    list2.GetHead()->Run(result);

    CHECK (strstr(reporter.lastFailedMessage, "xception"));
    CHECK (strstr(reporter.lastFailedMessage, "fixture"));
    CHECK (strstr(reporter.lastFailedMessage, "ThrowingThingie"));
}

struct DummyFixture
{
    int x;
};

// We're really testing the macros so we just want them to compile and link
SUITE(TestSuite1)
{

	TEST(SimilarlyNamedTestsInDifferentSuitesWork)
	{
		(void)testResults_;
	}

	TEST_FIXTURE(DummyFixture,SimilarlyNamedFixtureTestsInDifferentSuitesWork)
	{
	    (void)testResults_;
	}

}

SUITE(TestSuite2)
{

	TEST(SimilarlyNamedTestsInDifferentSuitesWork)
	{
	    (void)testResults_;
	}

	TEST_FIXTURE(DummyFixture,SimilarlyNamedFixtureTestsInDifferentSuitesWork)
	{
	    (void)testResults_;
	}

}

TestList macroTestList1;
TEST_EX(MacroTestHelper1,macroTestList1)
{
    (void)testResults_;
}

TEST(TestAddedWithTEST_EXMacroGetsDefaultSuite)
{
    CHECK(macroTestList1.GetHead() != NULL);
    CHECK_EQUAL ("MacroTestHelper1", macroTestList1.GetHead()->m_details.testName);
    CHECK_EQUAL ("DefaultSuite", macroTestList1.GetHead()->m_details.suiteName);
}

TestList macroTestList2;
TEST_FIXTURE_EX(DummyFixture,MacroTestHelper2,macroTestList2)
{
    (void)testResults_;
}

TEST(TestAddedWithTEST_FIXTURE_EXMacroGetsDefaultSuite)
{
    CHECK(macroTestList2.GetHead() != NULL);
    CHECK_EQUAL ("MacroTestHelper2", macroTestList2.GetHead()->m_details.testName);
    CHECK_EQUAL ("DefaultSuite", macroTestList2.GetHead()->m_details.suiteName);
}

struct FixtureCtorThrows
{
	FixtureCtorThrows()	{ throw "exception"; }
};

TestList throwingFixtureTestList1;
TEST_FIXTURE_EX(FixtureCtorThrows, FixtureCtorThrowsTestName, throwingFixtureTestList1)
{
	(void)testResults_;
}

TEST(FixturesWithThrowingCtorsAreFailures)
{
	CHECK(throwingFixtureTestList1.GetHead() != NULL);
	RecordingReporter reporter;
	TestResults result(&reporter);
	throwingFixtureTestList1.GetHead()->Run(result);

	int const failureCount = result.GetFailedTestCount();
	CHECK_EQUAL(1, failureCount);
	CHECK(strstr(reporter.lastFailedMessage, "while constructing fixture"));
}

struct FixtureDtorThrows
{
	~FixtureDtorThrows() { throw "exception"; }
};

TestList throwingFixtureTestList2;
TEST_FIXTURE_EX(FixtureDtorThrows, FixtureDtorThrowsTestName, throwingFixtureTestList2)
{
	(void)testResults_;
}

TEST(FixturesWithThrowingDtorsAreFailures)
{
	CHECK(throwingFixtureTestList2.GetHead() != NULL);
	RecordingReporter reporter;
	TestResults result(&reporter);
	throwingFixtureTestList2.GetHead()->Run(result);

	int const failureCount = result.GetFailedTestCount();
	CHECK_EQUAL(1, failureCount);
	CHECK(strstr(reporter.lastFailedMessage, "while destroying fixture"));
}

}

// We're really testing if it's possible to use the same suite in two files
// to compile and link successfuly (TestTestSuite.cpp has suite with the same name)
// Note: we are outside of the anonymous namespace
SUITE(SameTestSuite)
{
	TEST(DummyTest1)
	{
	    (void)testResults_;
	}
}

