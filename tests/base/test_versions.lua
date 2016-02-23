--
-- tests/base/test_versions.lua
-- Verify the version comparisons.
-- Copyright (c) 2015 Jason Perkins and the Premake project
--

	local suite = test.declare("premake_versions")

	local p = premake


--
-- If only major version is specified, anything after should pass.
--

	function suite.pass_majorOnly_sameMajor()
		test.istrue(p.checkVersion("1.0.0", "1"))
	end

	function suite.pass_majorOnly_laterMajor()
		test.istrue(p.checkVersion("2.0.0", "1"))
	end

	function suite.pass_majorOnly_laterMinor()
		test.istrue(p.checkVersion("1.1.0", "1"))
	end

	function suite.pass_majorOnly_laterPatch()
		test.istrue(p.checkVersion("1.0.1", "1"))
	end

--
-- prereleases should be fail against true release.
--

	function suite.fail_majorOnly_alpha()
		test.isfalse(p.checkVersion("1.0.0-alpha1", "1"))
	end

	function suite.fail_majorOnly_dev()
		test.isfalse(p.checkVersion("1.0.0-dev", "1"))
	end

--
-- ealier versions should be fail against major release.
--

	function suite.fail_earlierMajor()
		test.isfalse(p.checkVersion("0.9.0", "1"))
	end

--
-- If major and minor are specified, anything after should pass
--

	function suite.pass_majorMinor_sameMajorMinor()
		test.istrue(p.checkVersion("1.1.0", "1.1"))
	end

	function suite.pass_majorMinor_sameMajorLaterMinor()
		test.istrue(p.checkVersion("1.2.0", "1.1"))
	end

	function suite.pass_majorMinor_sameMajorLaterPath()
		test.istrue(p.checkVersion("1.1.1", "1.1"))
	end

	function suite.pass_majorMinor_laterMajorSameMinor()
		test.istrue(p.checkVersion("2.0.0", "1.1"))
	end

	function suite.pass_majorMinor_laterMajorEarlierMinor()
		test.istrue(p.checkVersion("2.0.0", "1.1"))
	end

	function suite.pass_majorMinor_laterMajorLaterMinor()
		test.istrue(p.checkVersion("2.2.0", "1.1"))
	end

	function suite.fail_majorMinor_sameMajorEarlierMinor()
		test.isfalse(p.checkVersion("1.0.0", "1.1"))
	end

	function suite.fail_majorMinor_earlierMajor()
		test.isfalse(p.checkVersion("0.9.0", "1.1"))
	end


--
-- Alpha comes before beta comes before dev
--

	function suite.pass_alphaBeforeBeta()
		test.istrue(p.checkVersion("1.0.0-beta1", "1.0.0-alpha1"))
	end

	function suite.fail_alphaBeforeBeta()
		test.isfalse(p.checkVersion("1.0.0-alpha1", "1.0.0-beta1"))
	end

	function suite.pass_betaBeforeDev()
		test.istrue(p.checkVersion("1.0.0-dev", "1.0.0-beta1"))
	end

	function suite.fail_betaBeforeDev()
		test.isfalse(p.checkVersion("1.0.0-beta1", "1.0.0-dev"))
	end


--
-- Check ">=" operator
--

	function suite.pass_ge_sameMajorMinorPatch()
		test.istrue(p.checkVersion("1.1.0", ">=1.1"))
	end

	function suite.pass_ge_sameMajorMinorLaterPatch()
		test.istrue(p.checkVersion("1.1.1", ">=1.1"))
	end

	function suite.pass_ge_laterMajorEarlierMinor()
		test.istrue(p.checkVersion("2.0.1", ">=1.1"))
	end

	function suite.pass_ge_sameMajorLaterMinor()
		test.istrue(p.checkVersion("1.2.1", ">=1.1"))
	end

	function suite.fail_ge_earlierMajor()
		test.isfalse(p.checkVersion("0.1.1", ">=1.1"))
	end

	function suite.fail_ge_earlierMinor()
		test.isfalse(p.checkVersion("1.0.1", ">=1.1"))
	end


--
-- Check ">" operator
--

	function suite.pass_gt_sameMajorMinorLaterPatch()
		test.istrue(p.checkVersion("1.1.1", ">1.1"))
	end

	function suite.pass_gt_laterMajor()
		test.istrue(p.checkVersion("2.0.1", ">1.1"))
	end

	function suite.pass_gt_laterMinor()
		test.istrue(p.checkVersion("1.2.1", ">1.1"))
	end

	function suite.fail_gt_sameMajorMinorPatch()
		test.isfalse(p.checkVersion("1.1.0", ">1.1"))
	end

	function suite.fail_gt_earlierMajor()
		test.isfalse(p.checkVersion("0.1.1", ">1.1"))
	end

	function suite.fail_gt_earlierMinor()
		test.isfalse(p.checkVersion("1.0.1", ">1.1"))
	end


--
-- Check multiple conditions
--

	function suite.pass_onMultipleConditions()
		test.istrue(p.checkVersion("1.2.0", ">=1.0 <2.0"))
	end

	function suite.fail_onMultipleConditions()
		test.isfalse(p.checkVersion("2.2.0", ">=1.0 <2.0"))
	end


--
-- If there is no version information, fails.
--

	function suite.fail_onNoVersion()
		test.isfalse(p.checkVersion(nil, "1.0"))
	end
