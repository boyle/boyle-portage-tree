# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: flutter.eclass
# @MAINTAINER: boyle@gentoo.org
# @BLURB: common functions and variables for flutter builds

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

if [[ -z ${_FLUTTER_ECLASS} ]]; then
_FLUTTER_ECLASS=1

# @ECLASS_VARIABLE: FLUTTER_PUB_DEPS
# @DEFAULT_UNSET
# @PRE_INHERIT
# @DESCRIPTION:
# Bash string containing all flutter/dart packages from pub.dev that are to be downloaded.
# It is used by flutter_pub_uris. Typically generated from pubspec.lock.
#
# Example:
# @CODE
# FLUTTER_PUB_DEPS="
#   app_links@7.0.0
#   async@2.13.0
# "
FLUTTER_PUB_DEPS=${FLUTTER_PUB_DEPS:-}

# @VARIABLE: FLUTTER_PUB_URIS
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# List of URIs to put in SRC_URI created from FLUTTER_PUB_DEPS variable.
# This is automatically set when the eclass is inherited.

# @FUNCTION: _flutter_set_pub_uris
# @USAGE: [<packages>]
# @INTERNAL
# @DESCRIPTION:
# Generates the URIs to put in SRC_URI to help fetch dart/flutter dependencies.
# Constructs a list of package URLs from its arguments.
# If no arguments are provided, it uses the FLUTTER_PUB_DEPS variable.
# The value is set as FLUTTER_PUB_URIS.
_flutter_set_pub_uris() {
	local packages=${1:-${FLUTTER_PUB_DEPS}}

	FLUTTER_PUB_URIS=
	local pkg version url filename
	for item in ${packages}; do
		# Format: name@version (similar to cargo CRATES)
		pkg=${item%%@*}
		version=${item##*@}
		# Skip packages with version 0.0.0 - they're bundled with Flutter SDK
		[[ ${version} == "0.0.0" || -z ${version} ]] && continue
		# Strip build suffix (+something) from version for pub.dev URL
		local version_stripped=${version%%+*}
		# Use -> to rename the downloaded file to avoid conflicts in DISTDIR
		# Only needed when version differs from stripped version
		if [[ ${version} == ${version_stripped} ]]; then
			url="https://pub.dev/api/archives/${pkg}-${version}.tar.gz"
		else
			url="https://pub.dev/api/archives/${pkg}-${version_stripped}.tar.gz -> ${pkg}-${version}.tar.gz"
		fi
		FLUTTER_PUB_URIS+="${url} "
	done
}

# @FUNCTION: flutter_pub_uris
# @USAGE: [<packages>]
# @DESCRIPTION:
# Generates and sets FLUTTER_PUB_URIS variable from FLUTTER_PUB_DEPS or arguments.
# Call this in the ebuild to generate the URI list for SRC_URI.
#
# Example:
# @CODE
# inherit flutter
# FLUTTER_PUB_DEPS="
#   app_links@7.0.0
#   async@2.13.0
# "
# SRC_URI="
#   ${FLUTTER_PUB_URIS}
#   ..."
flutter_pub_uris() {
	_flutter_set_pub_uris "$@"
}

# @FUNCTION: flutter_src_unpack
# @DESCRIPTION:
# Unpacks dart packages from DISTDIR to the pub cache.
# Uses FLUTTER_PUB_DEPS to determine which packages to extract.
flutter_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	export PUB_CACHE="${WORKDIR}/.pub-cache"
	mkdir -p "${PUB_CACHE}/hosted/pub.dev"

	# Extract dart packages to pub cache based on FLUTTER_PUB_DEPS
	# Use newline IFS to handle multiline FLUTTER_PUB_DEPS
	local IFS=$'\n'
	local pkg version version_stripped filename
	for item in $(echo "${FLUTTER_PUB_DEPS}"); do
		# Strip leading/trailing whitespace
		item=${item## }
		item=${item%% }
		item=${item##	}
		item=${item%%	}
		[[ -z "${item}" ]] && continue
		pkg=${item%%@*}
		version=${item##*@}
		# Skip packages with version 0.0.0
		[[ ${version} == "0.0.0" || -z ${version} ]] && continue
		# Strip build suffix (+something) for filename
		version_stripped=${version%%+*}
		# Determine the filename in DISTDIR
		filename="${pkg}-${version}.tar.gz"
		
		einfo "Checking for ${filename}"
		if [[ -f "${DISTDIR}/${filename}" ]]; then
			einfo "Extracting ${filename} to pub cache"
			tar -x -C "${PUB_CACHE}/hosted/pub.dev" -f "${DISTDIR}/${filename}" || \
				die "Failed to extract ${filename}"
		else
			die "Missing expected package: ${filename}"
		fi
	done
}

# Automatically generate FLUTTER_PUB_URIS from FLUTTER_PUB_DEPS
_flutter_set_pub_uris

fi
