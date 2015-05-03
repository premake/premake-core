#!/usr/bin/env bash
###################################################
# Generate a GNU makefile to build premake

usage()
{
	cat << EOF
$(basename "${0}") [ -h] [-e <embedded lua script file>] [-o <output directory>] [-t <target directory>]
	With
		-o --output
			Set Makefile and binary output path
			Default: ${defaultOutputDirectory}
		-e --scripts
			Embedded scripts file location
			If not set, look in default location src/host/scripts.c
			If scripts file does not exists, use embed.sh script to generate it
		-t --target
			Premake binary output directory
			Default: ${defaultTargetDirectory}
		-h --help
			This help
EOF
}

ns_mktemp()
{
		local key=
		if [ $# -gt 0 ]
		then
				key="${1}"
				shift
		else
				key="$(date +%s)"
		fi
		if [ "$(uname -s)" == "Darwin" ]
		then
				#Use key as a prefix
				mktemp -t "${key}"
		else
				#Use key as a suffix
				mktemp --suffix "${key}"
		fi
}

ns_relativepath()
{
	local from=
	if [ $# -gt 0 ]
	then
		from="${1}"
		shift
	fi
	local base=
	if [ $# -gt 0 ]
	then
		base="${1}"
		shift
	else
		base="."
	fi
	[ -r "${from}" ] || return 1
	[ -r "${base}" ] || return 2
	[ ! -d "${base}" ] && base="$(dirname "${base}")"  
	[ -d "${base}" ] || return 3
	from="$(ns_realpath "${from}")"
	base="$(ns_realpath "${base}")"
	c=0
	sub="${base}"
	newsub=""
	while [ "${from:0:${#sub}}" != "${sub}" ]
	do
		newsub="$(dirname "${sub}")"
		[ "${newsub}" == "${sub}" ] && return 4
		sub="${newsub}"
		c="$(expr ${c} + 1)"
	done
	res="."
	for ((i=0;${i}<${c};i++))
	do
		res="${res}/.."
	done
	res="${res}${from#${sub}}"
	res="${res#./}"
	echo "${res}"
}

ns_realpath()
{
	local inputPath=
	if [ $# -gt 0 ]
	then
		inputPath="${1}"
		shift
	fi
	local cwd="$(pwd)"
	[ -d "${inputPath}" ] && cd "${inputPath}" && inputPath="."
	while [ -h "${inputPath}" ] ; do inputPath="$(readlink "${inputPath}")"; done
	
	if [ -d "${inputPath}" ]
	then
		inputPath="$(cd -P "$(dirname "${inputPath}")" && pwd)"
	else
		inputPath="$(cd -P "$(dirname "${inputPath}")" && pwd)/$(basename "${inputPath}")"
	fi
	
	cd "${cwd}" 1>/dev/null 2>&1
	echo "${inputPath}"
}

scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
premakeRootPath="$(ns_realpath "${scriptPath}/..")"

kernel="$(uname -s)"

defaultEmbeddedScriptFilePath="${premakeRootPath}/src/host/scripts.c"
embeddedScriptFilePath="${defaultEmbeddedScriptFilePath}"
makefileName="Premake5.make"
defaultOutputDirectory="${premakeRootPath}"
outputDirectory="${defaultOutputDirectory}"
defaultTargetDirectory="${premakeRootPath}/bin/release"
targetDirectory="${defaultTargetDirectory}"

luaSourceDirectoryName="$(find "${premakeRootPath}/src/host" -mindepth 1 -maxdepth 1 -type d -name 'lua*' -exec basename "{}" \;)"

while [ ${#} -gt 0 ]
do
	case "${1}" in
		-o|--output)
			outputDirectory="${2}"
			shift
			
			if ! mkdir -p "${outputDirectory}"
			then 
				echo 'Invalid output directory' 1>&2
				usage
				exit 1
			fi
		;;
		-e|--scripts)
			embeddedScriptFilePath="${2}"
			if ! mkdir -p "$(dirname "${embeddedScriptFilePath}")"
			then 
				echo 'Invalid embedded scripts file directory' 1>&2
				usage
				exit 1
			fi
			shift
			
			embeddedScriptFilePath="$(ns_realpath "$(dirname "${embeddedScriptFilePath}")")/$(basename "${embeddedScriptFilePath}")"
		;;
		-t|--target)
			targetDirectory="${2}"
			shift
			
			if ! mkdir -p "${targetDirectory}"
			then 
				echo 'Invalid target directory' 1>&2
				usage
				exit 1
			fi
			
			targetDirectory="$(ns_realpath "${targetDirectory}")"
		;;
		-h|--help)
			usage
			exit 0
		;;
		-*)
			echo "Invalid option '${1}'" 1>&2
			usage
			exit 1
		;;
		*)
			echo "Invalid argument '${1}'" 1>&2
			usage
			exit 1
		;;
	esac
	
	shift
done

####################
# Check requirements

####################
# Generate makefile

makefilePath="${outputDirectory}/${makefileName}"
premakeSourceFiles=("${embeddedScriptFilePath}")
unset premakeLinkFlags
premakeBuildFlags=(-Wall -Wextra -Os)
premakeDefines=(NDEBUG)

# Exclude files, relative to preamke root
premakeExcludeFiles=(\
	"src/host/${luaSourceDirectoryName}/src/lauxlib.c" \
	"src/host/${luaSourceDirectoryName}/src/lua.c" \
	"src/host/${luaSourceDirectoryName}/src/luac.c" \
	"src/host/${luaSourceDirectoryName}/src/print.c" \
)

if [ "${embeddedScriptFilePath}" != "${defaultEmbeddedScriptFilePath}" ]
then
	premakeExcludeFiles=("${premakeExcludeFiles[@]}" \
		"${defaultEmbeddedScriptFilePath#${premakeRootPath}/}"\
	)
fi

premakeIncludeDirectories=(\
	"${premakeRootPath}/src/host" \
	"${premakeRootPath}/src/host/${luaSourceDirectoryName}/src"\
)

if [ "${kernel}" = 'Darwin' ]
then
	premakeDefines=("${premakeDefines[@]}" LUA_USE_MACOSX)
	premakeLinkFlags=("${premakeLinkFlags[@]}" -framework CoreServices)
	premakeBuildFlags=("${premakeBuildFlags[@]}" -mmacosx-version-min=10.4)
elif [ "${kernel}" = 'Linux' ]
then
	premakeDefines=("${premakeDefines[@]}" LUA_USE_POSIX LUA_USE_DLOPEN)
	premakeLinkFlags=("${premakeLinkFlags[@]}" -rdynamic -ldl -lm)
# TODO bsd, hurd etc.
fi

# Create source file list
while read f
do
	r="${f#${premakeRootPath}/}"
	add=true
	
	# Do not add files marked as excluded
	for x in "${premakeExcludeFiles[@]}"
	do
		if [ "${r}" = "${x}" ]
		then
			add=false
			break
		fi
	done
	
	# Do not add files in etc directory of lua sources
	[ "${r}" = "${r#src/host/${luaSourceDirectoryName}/etc/}" ] || add=false
		
	${add} && 	premakeSourceFiles=("${premakeSourceFiles[@]}" "${f}")
	
done << EOF
$(find "${premakeRootPath}/src" \( -name '*.c' \))
EOF

# Writing makefile
cat > "${makefilePath}" << EOF
# premake

ifndef CC
	CC = cc
endif

PREMAKE_SRC := $(for f in "${premakeSourceFiles[@]}"; do
	echo -e "\t${f} \\"
done)

EMBEDDED_SCRIPTS_FILE := ${embeddedScriptFilePath}
TARGETDIR := ${targetDirectory}
TARGET := \$(TARGETDIR)/premake5

INCLUDES := $(for d in "${premakeIncludeDirectories[@]}"; do
	echo -e "\t-I'${d}' \\"
done)

DEFINES := $(for d in "${premakeDefines[@]}"; do
	echo -e "\t-D${d} \\"
done)

CFLAGS += \$(INCLUDES) \$(DEFINES)
CFLAGS += $(echo "${premakeBuildFlags[@]}")

LDFLAGS += ${premakeLinkFlags[@]}

.PHONY: all clean

all: \$(EMBEDDED_SCRIPTS_FILE) \$(TARGET)

\$(EMBEDDED_SCRIPTS_FILE): 
	@echo Create embedded script file
	@${scriptPath}/embed.sh -o "$(dirname "${embeddedScriptFilePath}")" -n "$(basename "${embeddedScriptFilePath}")"

\$(TARGETDIR): 
	@echo Create target directory
	@mkdir -p "\$(TARGETDIR)" 

\$(TARGET): \$(TARGETDIR) \$(PREMAKE_SRC)
	@echo Building premake5
	@\$(CC) \$(CFLAGS) -o "\$(TARGET)" \$(PREMAKE_SRC) \$(LDFLAGS)
	
clean:  
	@echo Cleaning premake5
	@rm -f "\$(TARGET)"	 
EOF
