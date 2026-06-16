# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION="7.2"
inherit cuda rocm
inherit cmake
inherit flag-o-matic go-module linux-info systemd toolchain-funcs

DESCRIPTION="Get up and running with large language models locally"
HOMEPAGE="https://ollama.com"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ollama/ollama.git"
else
	SRC_URI="
		https://github.com/ollama/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz
	"
	KEYWORDS="~amd64"
fi

LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0"
SLOT="0"

IUSE="cuda rocm vulkan"

# go build + llama.cpp FetchContent both fetch at build time
RESTRICT="network-sandbox mirror test"

COMMON_DEPEND="
	cuda? (
		dev-util/nvidia-cuda-toolkit:=
		x11-drivers/nvidia-drivers
	)
	rocm? (
		>=dev-util/hip-${ROCM_VERSION}:=
		>=sci-libs/hipBLAS-${ROCM_VERSION}:=
		>=sci-libs/rocBLAS-${ROCM_VERSION}:=
	)
	vulkan? (
		media-libs/vulkan-loader
	)
"
DEPEND="
	${COMMON_DEPEND}
	>=dev-lang/go-1.26.0
"
BDEPEND="
	>=dev-build/cmake-3.24
	dev-vcs/git
	vulkan? (
		dev-util/vulkan-headers
		media-libs/shaderc
	)
"
RDEPEND="
	${COMMON_DEPEND}
	!sci-ml/ollama-bin
	acct-group/${PN}
	>=acct-user/${PN}-3[cuda?]
"

pkg_setup() {
	if use rocm; then
		linux-info_pkg_setup
		if linux-info_get_any_version && linux_config_exists; then
			if ! linux_chkconfig_present HSA_AMD_SVM; then
				ewarn "To use ROCm/HIP, you need to have HSA_AMD_SVM option enabled in your kernel."
			fi
		fi
	fi
}

src_unpack() {
	if use rocm; then
		strip-unsupported-flags
		export CXXFLAGS="$(test-flags-HIPCXX "${CXXFLAGS}")"
	fi

	if [[ ${PV} == *9999* ]]; then
		git-r3_src_unpack
	else
		default
	fi

	cd "${S}" || die
	ego mod download
}

src_prepare() {
	cmake_src_prepare

	use cuda && cuda_src_prepare

	# Fix runtime library lookup for multilib.  Upstream hardcodes "lib"/"ollama"
	# in ml/path.go; rewrite to $(get_libdir) when it differs.
	if [[ "$(get_libdir)" != "lib" ]]; then
		sed -i \
			-e "s/\"lib\", \"ollama\"/\"$(get_libdir)\", \"ollama\"/g" \
			ml/path.go || die "libdir sed (path.go) failed"
	fi

	if use rocm; then
		# --hip-version gets appended to compile flags which isn't a known flag.
		# Disable -Werror's from go modules to fix rocm builds.
		find "${S}" -name "*.go" -exec sed -i "s/ -Werror / /g" {} + || die
	fi
}

src_configure() {
	# Map USE flags to llama-server GPU runner backends. CPU is always built
	# (GGML_CPU_ALL_VARIANTS, runtime-dispatched). cuda_v13 matches CUDA 13.x
	# (ollama's internal llama.cpp backend name); rocm_v7_2 is the only
	# ROCm backend valid on Linux (rocm_v7_1 is Windows-only).
	local backends=()
	use cuda && backends+=( cuda_v13 )
	use rocm && backends+=( rocm_v7_2 )
	use vulkan && backends+=( vulkan )
	local backend_list
	backend_list=$(IFS=';'; echo "${backends[*]}")

	local mycmakeargs=(
		-DOLLAMA_VERSION="${PVR}"
		-DOLLAMA_LIB_DIR="$(get_libdir)/ollama"
		-DOLLAMA_MLX_BACKENDS=""
		-DOLLAMA_LLAMA_BACKENDS="${backend_list}"
		-DGGML_CCACHE=OFF
	)

	if use cuda; then
		local -x CUDAHOSTCXX CUDAHOSTLD
		CUDAHOSTCXX="$(cuda_gccdir)"
		CUDAHOSTLD="$(tc-getCXX)"

		if [[ ! -v CUDAARCHS ]]; then
			local CUDAARCHS="all-major"
		fi

		mycmakeargs+=(
			-DCMAKE_CUDA_ARCHITECTURES="${CUDAARCHS}"
		)

		cuda_add_sandbox -w
		addpredict "/dev/char/"
	fi

	if use rocm; then
		mycmakeargs+=(
			-DCMAKE_HIP_ARCHITECTURES="$(get_amdgpu_flags)"
			-DCMAKE_HIP_PLATFORM="amd"
			-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		)

		local -x HIP_PATH="${ESYSROOT}/usr"
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	newinitd "${FILESDIR}/ollama.init" "${PN}"
	newconfd "${FILESDIR}/ollama.confd" "${PN}"

	systemd_dounit "${FILESDIR}/ollama.service"
}

pkg_preinst() {
	keepdir /var/log/ollama
	fperms 750 /var/log/ollama
	fowners "${PN}:${PN}" /var/log/ollama
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		einfo "Quick guide:"
		einfo "\tollama serve"
		einfo "\tollama run llama3:70b"
		einfo
		einfo "See available models at https://ollama.com/library"
	fi

	if use cuda; then
		einfo "When using cuda the user running ${PN} has to be in the video group or it won't detect devices."
		einfo "The ebuild ensures this for user ${PN} via acct-user/${PN}[cuda]"
	fi
}
