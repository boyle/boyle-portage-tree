# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Heavy OpenCL GPU stress tester"
HOMEPAGE="http://clgpustress.nativeboinc.org"
SRC_URI="https://github.com/matszpk/${PN}/archive/${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	|| (
		media-libs/mesa[opencl]
		dev-libs/rocm-opencl-runtime
		dev-libs/pocl
	)
	dev-cpp/clhpp
"
RDEPEND="${DEPEND}"
BDEPEND=""
IUSE=""

PATCHES=("${FILESDIR}/cl2-hpp.patch")

src_compile() {
	if false; then
		eerror "The GUI build is broken due to official cl2.hpp updates. This is unmaintained code."
		emake
	else
		emake gpustress-cli
	fi
}

src_install() {
	einstalldocs
	exeinto /usr/bin
	newexe gpustress-cli clgpustress
}
