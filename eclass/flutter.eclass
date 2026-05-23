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
			if [[ ${item} == *@git+* ]]; then
				# Parse git dep: name@version@git+url@commit@path@ref
				local gname="${item%%@*}"
				local grest="${item#*@}"
				local gversion="${grest%%@git+*}"
				local ggrest="${item#*@git+}"
				local gurl="${ggrest%%@*}"
				ggrest="${ggrest#*@}"
				local gcommit="${ggrest%%@*}"

				# Generate archive URL (GitHub only)
				if [[ ${gurl} == https://github.com/* ]]; then
					local owner_repo="${gurl#https://github.com/}"
					owner_repo="${owner_repo%.git}"
					url="https://github.com/${owner_repo}/archive/${gcommit}.tar.gz"
					url+=" -> flutter-pub-git-${gname}-${gversion}.tar.gz"
					FLUTTER_PUB_URIS+="${url} "
				else
					einfo "Warning: git dep ${gname} is not from GitHub, skipping SRC_URI"
				fi
			else
				# Format: name@version (similar to cargo CRATES)
				pkg=${item%%@*}
				version=${item##*@}
				# Skip packages with version 0.0.0 - they're bundled with Flutter SDK
				[[ ${version} == "0.0.0" || -z ${version} ]] && continue
				url="https://pub.dev/api/archives/${pkg}-${version}.tar.gz"
				url+=" -> flutter-pub-${pkg}-${version}.tar.gz"
				FLUTTER_PUB_URIS+="${url} "
			fi
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
	mkdir -p "${PUB_CACHE}/hosted-hashes/pub.dev"

	# Extract dart packages to pub cache based on FLUTTER_PUB_DEPS
	# Use newline IFS to handle multiline FLUTTER_PUB_DEPS
	local IFS=$'\n'
	local pkg version filename
	for item in $(echo "${FLUTTER_PUB_DEPS}"); do
		# Strip leading/trailing whitespace
		item=${item## }
		item=${item%% }
		item=${item##	}
		item=${item%%	}
		[[ -z "${item}" ]] && continue
		# Skip git dependencies (handled in second loop below)
		[[ ${item} == *@git+* ]] && continue
		pkg=${item%%@*}
		version=${item##*@}
		# Skip packages with version 0.0.0 - bundled with Flutter SDK
		[[ ${version} == "0.0.0" || -z ${version} ]] && continue
		# Determine the filename in DISTDIR (prefixed + full version including build suffix)
		filename="flutter-pub-${pkg}-${version}.tar.gz"

		einfo "Checking for ${filename}"
		if [[ -f "${DISTDIR}/${filename}" ]]; then
			# Extract to versioned subdirectory - Flutter expects pkg-version structure
			local extractDir="${PUB_CACHE}/hosted/pub.dev/${pkg}-${version}"
			einfo "Extracting ${filename} to ${extractDir}"
			mkdir -p "${extractDir}"
			tar -x -C "${extractDir}" -f "${DISTDIR}/${filename}" || \
				die "Failed to extract ${filename}"

			# Pub reads version from pubspec.yaml, but pub.dev build suffixes
			# (+3, +4, etc.) are only in the lockfile/URL, not in the package's
			# own pubspec.yaml. Without the suffix, version resolution fails.
			if [[ ${version} == *+* ]]; then
				sed -i "s/^version: .*/version: ${version}/" "${extractDir}/pubspec.yaml" || \
					die "Failed to set version ${version} in ${extractDir}/pubspec.yaml"
			fi
		else
			die "Missing expected package: ${filename}"
		fi
	done

	# Handle git dependencies: extract from archive and convert to path dep
	local IFS=$'\n'
	for item in $(echo "${FLUTTER_PUB_DEPS}"); do
		item=${item## }
		item=${item%% }
		item=${item##	}
		item=${item%%	}
		[[ -z "${item}" ]] && continue
		[[ ${item} != *@git+* ]] && continue

		# Parse: name@version@git+url@commit@path@ref
		local name="${item%%@*}"
		local rest="${item#*@}"
		local version="${rest%%@git+*}"
		local grest="${item#*@git+}"
		local gurl="${grest%%@*}"
		grest="${grest#*@}"
		local commit="${grest%%@*}"
		grest="${grest#*@}"
		local subpath="${grest%%@*}"
		local gitref="${grest#*@}"

		# Archive filename in DISTDIR
		filename="flutter-pub-git-${name}-${version}.tar.gz"
		local extractDir="${PUB_CACHE}/hosted/pub.dev/${name}-${version}"

		if [[ -f "${DISTDIR}/${filename}" ]]; then
			einfo "Extracting git dep ${name} from ${filename}"
			local tmpExtract="${WORKDIR}/.git-dep-extract-${name}"
			rm -rf "${tmpExtract}"
			mkdir -p "${tmpExtract}"
			tar -x -C "${tmpExtract}" -f "${DISTDIR}/${filename}" || \
				die "Failed to extract ${filename}"

			# Find the subpackage directory
			local archiveDir=$(ls "${tmpExtract}")
			local pkgDir="${tmpExtract}/${archiveDir}/${subpath}"
			if [[ ! -d "${pkgDir}" ]]; then
				die "Subpath ${subpath} not found in ${filename}"
			fi

			# Copy to pub cache as hosted-style entry
			mkdir -p "${extractDir}"
			cp -r "${pkgDir}/." "${extractDir}/" || \
				die "Failed to copy ${name} to pub cache"

			# Rewrite version in pubspec.yaml (handles build suffixes)
			if [[ ${version} == *+* ]]; then
				sed -i "s/^version: .*/version: ${version}/" "${extractDir}/pubspec.yaml" || \
					die "Failed to set version ${version} in ${extractDir}/pubspec.yaml"
			fi

			# Patch pubspec.yaml - replace git dep with path dep
			einfo "Patching pubspec.yaml for ${name}"
			awk -v pkg="${name}" -v pkpath="../.pub-cache/hosted/pub.dev/${name}-${version}" '
				index($0, "  " pkg ":") == 1 {
					print "  " pkg ":"
					print "    path: " pkpath
					skip = 1
					next
				}
				skip && /^[^ ]/ { skip = 0 }
				skip && /^  [a-z_]/ { skip = 0 }
				skip { next }
				{ print }
			' "${S}/pubspec.yaml" > "${S}/pubspec.yaml.tmp" && \
				mv "${S}/pubspec.yaml.tmp" "${S}/pubspec.yaml" || \
				die "Failed to patch pubspec.yaml for ${name}"

			# Patch pubspec.lock - replace git entry with path entry
			einfo "Patching pubspec.lock for ${name}"
			awk -v pkg="${name}" -v pkpath="../.pub-cache/hosted/pub.dev/${name}-${version}" -v ver="${version}" '
				index($0, "  " pkg ":") == 1 {
					print "  " pkg ":"
					print "    dependency: \"direct main\""
					print "    description:"
					print "      path: \"" pkpath "\""
					print "      relative: true"
					print "    source: path"
					print "    version: \"" ver "\""
					skip = 1
					next
				}
				skip && /^[^ ]/ { skip = 0 }
				skip && /^  [a-z_]/ { skip = 0 }
				skip { next }
				{ print }
			' "${S}/pubspec.lock" > "${S}/pubspec.lock.tmp" && \
				mv "${S}/pubspec.lock.tmp" "${S}/pubspec.lock" || \
				die "Failed to patch pubspec.lock for ${name}"

			# Clean up temp extraction
			rm -rf "${tmpExtract}"
		else
			die "Missing expected git archive: ${filename}"
		fi
	done
}

# @FUNCTION: flutter_prepare_tools
# @DESCRIPTION:
# Creates a minimal .dart_tool/package_config.json for flutter_tools to prevent
# the Flutter tool from trying to resolve its own dependencies from pub.dev
# (which would fail without network access). flutter_tools runs as a pre-compiled
# Dart snapshot, so it does not need resolved packages at runtime.
#
# Must be called after dependencies are resolved (after dart pub get).
flutter_prepare_tools() {
	debug-print-function ${FUNCNAME} "$@"

	local tools_dir="${WORKDIR}/flutter/packages/flutter_tools"
	local pc_dir="${tools_dir}/.dart_tool"
	mkdir -p "${pc_dir}"

	cat > "${pc_dir}/package_config.json" <<-EOF || die "Failed to create flutter_tools package_config"
	{
	  "configVersion": 2,
	  "packages": [
	    {
	      "name": "flutter_tools",
	      "rootUri": "file://${tools_dir}",
	      "packageUri": "lib/"
	    }
	  ],
	  "generated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
	  "generator": "pub"
	}
	EOF
}

# @FUNCTION: flutter_setup_plugin_symlinks
# @DESCRIPTION:
# Creates plugin symlinks required by the Flutter Linux build system. These are
# normally created by regeneratePlatformSpecificTooling during flutter pub get,
# but we skip that step with --no-pub. Reads generated_plugins.cmake to find
# which plugins need symlinks and creates them pointing to the pub cache.
flutter_setup_plugin_symlinks() {
	debug-print-function ${FUNCNAME} "$@"

	local ephemeral="${S}/linux/flutter/ephemeral"
	local plugins_cmake="${S}/linux/flutter/generated_plugins.cmake"

	if [[ ! -f "${plugins_cmake}" ]]; then
		die "generated_plugins.cmake not found at ${plugins_cmake}"
	fi

	mkdir -p "${ephemeral}/.plugin_symlinks"

	# Extract FLUTTER_PLUGIN_LIST entries from CMake
	local plugins
	plugins=$(sed -n '/^list(APPEND FLUTTER_PLUGIN_LIST/,/^)$/p' "${plugins_cmake}" | \
		grep '^\s' | sed 's/^[[:space:]]*//')

	for plugin in ${plugins}; do
		local plugin_dir=$(find "${PUB_CACHE}/hosted/pub.dev" -maxdepth 1 \
			-name "${plugin}-*" -type d 2>/dev/null | head -1)
		if [[ -n "${plugin_dir}" ]]; then
			ln -sf "${plugin_dir}" "${ephemeral}/.plugin_symlinks/${plugin}" || \
				die "Failed to create symlink for ${plugin}"
		else
			die "Plugin ${plugin} not found in pub cache"
		fi
	done
}

# Automatically generate FLUTTER_PUB_URIS from FLUTTER_PUB_DEPS
_flutter_set_pub_uris

fi
