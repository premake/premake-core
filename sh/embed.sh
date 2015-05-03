#!/usr/bin/env bash
###################################################
# Generate embedded lua scripts file 
# like the premake 'embed' action

usage()
{
	cat << EOF
$(basename "${0}") [ -h] [-o <output directory>]
	With
		-o --output
			Set embedded scripts file output directory
			Default: ${defaultOutputDirectory}
		-n --name
			Set embedded scripts file name
			Default: ${defaultPremakeEmbeddedScriptFile}
		-h --help
			This help
EOF
}

# Create a temporary file
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

# Get real absolute path of a file or directory
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

# Replace file content inplace using sed
ns_sed_inplace()
{
	local inplaceOptionForm=
	if [ -z "${__ns_sed_inplace_inplaceOptionForm}" ]
	then
		if [ "$(uname -s)" = 'Darwin' ]
		then
			if [ "$(which sed 2>/dev/null)" = '/usr/bin/sed' ]
			then
				inplaceOptionForm='arg'			
			fi 
		fi
		
		if [ -z "${inplaceOptionForm}" ]
		then
			# Attempt to guess it from help
			if sed --helo 2>&1 | grep -q '\-i\[SUFFIX\]'
			then
				inplaceOptionForm='nested'
			elif sed --helo 2>&1 | grep -q '\-i extension'
			then
				inplaceOptionForm='arg'
			else
				inplaceOptionForm='noarg'
			fi
		fi
	else
		inplaceOptionForm="${__ns_sed_inplace_inplaceOptionForm}"
	fi
	
	# Store for later use
	__ns_sed_inplace_inplaceOptionForm="${inplaceOptionForm}"
	
	if [ "${inplaceOptionForm}" = 'nested' ]
	then
		sed -i'' "${@}"
	elif [ "${inplaceOptionForm}" = 'arg' ]
	then
		sed -i '' "${@}"
	else
		sed -i "${@}"
	fi
}

# Output files listed in manifests
# Use lua if available, otherwise, parse file manually
manifest_filelist()
{
	local manifestPath="${1}"
	if which lua 1>/dev/null 2>&1
	then
		lua -e 'for _, f in ipairs(dofile("'${manifestPath}'")) do print(f) end'
	else
		# We assume that all manifests respect the same formatting policy
		# * A single "return {}" instruction
		# * One file per line
		# * Use double quotes 
		sed -n 's,[[:space:]]"\(.*\.lua\)".*,\1,p' "${manifestPath}"
	fi
}

# Append lua script content to embedded lua scripts file
append_script()
{
	local file="${1}"
	# * Remove tabs, CR, inline comments and blank lines
	# * Escape backslashes and double quotes
	# * Escape end of lines
	
	local tmp=$(ns_mktemp)
	cp -pr "${file}" "${tmp}"
	
	# Strip block comments 
	perl -0777 -i -pe 's,--\[\[.*?\]\],,sg' "${tmp}"
	# Strip single line comments 		
	perl -i -pe 's,^[ \t]*--.*,,g' "${tmp}"
	# Strip tabs & CR
	perl -i -pe 's,[\r\t],,g' "${tmp}"
	# Strip whitespace lines
	perl -i -pe 's,^[ \t]*$,,g' "${tmp}"
	ns_sed_inplace "/^$/d" "${tmp}"
	# Escape backslashes and double quotes
	perl -i -pe 's,([\\"]),\\\1,g' "${tmp}"
	# Escape LN
	perl -i -pe 's,\n,\\n,g' "${tmp}"

	local content="$(cat "${tmp}")"
	
	local read=0
	local first=true
	
	if [ -z "${maxLineLength}" ] || [ ${maxLineLength} -le 0 ]
	then
		echo -ne '\t"'
		echo -n "${content}"
		echo  '",' 
	else
		# Split into ${maxLineLength} chunks
		while true
		do
			local sub="${content:0:$(expr ${maxLineLength} + 1)}"
			local len=${#sub}
			
			while [ "${sub:$(expr ${len} - 1)}" = '\' ]
			do
				len=$(expr ${len} - 1)
				sub="${content:0:${len}}"
			done
			
			[ ${len} -eq 0 ] && break
			
			${first} || echo ''
			echo -ne '\t"'
			echo -n "${sub}"
			echo -n '"'
			
			first=false		
			read=$(expr ${read} + ${len})
			content="${content:${len}}"
		done
	fi
	
	echo ','
	
	rm -f "${tmp}"
}

scriptFilePath="$(ns_realpath "${0}")"
scriptPath="$(dirname "${scriptFilePath}")"
premakeRootPath="$(ns_realpath "${scriptPath}/..")"
defaultOutputDirectory="${premakeRootPath}/src/host"
outputDirectory="${defaultOutputDirectory}"
maxLineLength=4096
defaultPremakeEmbeddedScriptFile='scripts.c'
premakeEmbeddedScriptFile="${defaultPremakeEmbeddedScriptFile}"

####################
# Parse command line
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
		-n|--name)
			premakeEmbeddedScriptFile="${2}"
			shift
			
			if [ -z "${premakeEmbeddedScriptFile}" ]
			then
				echo 'Invalid output output script name' 1>&2
				usage
				exit 1
			fi
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
for x in sed perl
do
	if ! which ${x} 1>/dev/null 2>&1
	then
		echo "${x} is required to create embedded script file" 1>&2
		exit 1
	fi
done

####################
# Generate scripts.c
premakeEmbeddedScriptFilePath="${outputDirectory}/${premakeEmbeddedScriptFile}"

unset premakeManifestFilePaths
while read f
do
	premakeManifestFilePaths=("${premakeManifestFilePaths[@]}" "${f#${premakeRootPath}/}")
done << EOF
$(find "${premakeRootPath}" -name '_manifest.lua' | sort)
EOF

cat > "${premakeEmbeddedScriptFilePath}" << EOF
/* Premake's Lua scripts, as static data buffers for release mode builds */
/* DO NOT EDIT - this file is autogenerated - see BUILD.txt */
/* To regenerate this file, run: premake5 embed */

#include "premake.h"

const char* builtin_scripts_index[] = {
EOF

unset builtinScriptPaths
for m in "${premakeManifestFilePaths[@]}"
do
	manifestPath="${premakeRootPath}/${m}"
	manifestDirectory="$(dirname "${manifestPath}")"
	manifestBaseDirectory="$(dirname "${manifestDirectory}")"
	
	while read f
	do
		builtinScriptPath="${manifestDirectory}/${f}"
		builtinScriptPaths=("${builtinScriptPaths[@]}" "${builtinScriptPath}")
		builtinScriptPath="${builtinScriptPath#${manifestBaseDirectory}/}"
		echo -e "\t\"${builtinScriptPath}\"," >> "${premakeEmbeddedScriptFilePath}"
	done << EOF 
$(manifest_filelist "${manifestPath}")
EOF
done
	
# Manually added files
for f in \
	"src/_premake_main.lua" \
	"src/_manifest.lua" \
	"src/_modules.lua"
do
	builtinScriptPath="${premakeRootPath}/${f}"
	builtinScriptPaths=("${builtinScriptPaths[@]}" "${builtinScriptPath}")
	echo -e "\t\"${f}\"," >> "${premakeEmbeddedScriptFilePath}"
done

cat >> "${premakeEmbeddedScriptFilePath}" << EOF
	NULL
};

const char* builtin_scripts[] = {
EOF

for f in "${builtinScriptPaths[@]}"
do
	append_script "${f}" >> "${premakeEmbeddedScriptFilePath}"
done

cat >> "${premakeEmbeddedScriptFilePath}" << EOF
	NULL
};
EOF
