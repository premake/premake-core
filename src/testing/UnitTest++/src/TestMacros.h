#ifndef UNITTEST_TESTMACROS_H
#define UNITTEST_TESTMACROS_H

#include "Config.h"

#ifndef UNITTEST_POSIX
	#define UNITTEST_THROW_SIGNALS
#else
	#include "Posix/SignalTranslator.h"
#endif

#ifdef TEST
    #error UnitTest++ redefines TEST
#endif

#define SUITE(Name)                                                         \
    namespace Name {                                                        \
        namespace UnitTestSuite {                                           \
            inline char const* GetSuiteName () {                            \
                return #Name ;                                              \
            }                                                               \
        }                                                                   \
    }                                                                       \
    namespace Name

#define TEST_EX(Name, List)                                                \
    class Test##Name : public UnitTest::Test                               \
    {                                                                      \
    public:                                                                \
		Test##Name() : Test(#Name, UnitTestSuite::GetSuiteName(), __FILE__, __LINE__) {}  \
    private:                                                               \
        virtual void RunImpl(UnitTest::TestResults& testResults_) const;   \
    } test##Name##Instance;                                                \
																		   \
    UnitTest::ListAdder adder##Name (List, &test##Name##Instance);         \
																		   \
    void Test##Name::RunImpl(UnitTest::TestResults& testResults_) const


#define TEST(Name) TEST_EX(Name, UnitTest::Test::GetTestList())


#define TEST_FIXTURE_EX(Fixture, Name, List)                                         \
    class Fixture##Name##Helper : public Fixture									 \
	{																				 \
	public:																			 \
        Fixture##Name##Helper(UnitTest::TestDetails const& details) : m_details(details) {} \
        void RunTest(UnitTest::TestResults& testResults_);                           \
        UnitTest::TestDetails const& m_details;                                      \
    private:                                                                         \
        Fixture##Name##Helper(Fixture##Name##Helper const&);                         \
        Fixture##Name##Helper& operator =(Fixture##Name##Helper const&);             \
    };                                                                               \
																					 \
    class Test##Fixture##Name : public UnitTest::Test                                \
    {                                                                                \
    public:                                                                          \
	    Test##Fixture##Name() : Test(#Name, UnitTestSuite::GetSuiteName(), __FILE__, __LINE__) {} \
    private:                                                                         \
        virtual void RunImpl(UnitTest::TestResults& testResults_) const;             \
    } test##Fixture##Name##Instance;                                                 \
																					 \
    UnitTest::ListAdder adder##Fixture##Name (List, &test##Fixture##Name##Instance); \
																					 \
    void Test##Fixture##Name::RunImpl(UnitTest::TestResults& testResults_) const	 \
	{																				 \
		bool ctorOk = false;														 \
		try {																		 \
			Fixture##Name##Helper fixtureHelper(m_details);							 \
			ctorOk = true;															 \
			try {																	 \
				UNITTEST_THROW_SIGNALS;												 \
				fixtureHelper.RunTest(testResults_);								 \
			} catch (UnitTest::AssertException const& e) {							 \
				testResults_.OnTestFailure(UnitTest::TestDetails(m_details.testName, m_details.suiteName, e.Filename(), e.LineNumber()), e.what()); \
			} catch (std::exception const& e) {										 \
				UnitTest::MemoryOutStream stream;									 \
				stream << "Unhandled exception: " << e.what();						 \
				testResults_.OnTestFailure(m_details, stream.GetText());			 \
			} catch (...) {	testResults_.OnTestFailure(m_details, "Unhandled exception: Crash!"); } \
		}																			 \
		catch (...) {																 \
			if (ctorOk)																 \
			{																		 \
	            testResults_.OnTestFailure(UnitTest::TestDetails(m_details, __LINE__),	 \
					"Unhandled exception while destroying fixture " #Fixture);		 \
			}																		 \
			else																	 \
			{																		 \
				testResults_.OnTestFailure(UnitTest::TestDetails(m_details, __LINE__),   \
					"Unhandled exception while constructing fixture " #Fixture);         \
			}																		 \
		}																			 \
    }                                                                                \
    void Fixture##Name##Helper::RunTest(UnitTest::TestResults& testResults_)

#define TEST_FIXTURE(Fixture,Name) TEST_FIXTURE_EX(Fixture, Name, UnitTest::Test::GetTestList())

#endif
