# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Portable OpenCL Computing Language"
HOMEPAGE="http://portablecl.org"
SRC_URI="https://github.com/pocl/pocl/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="<sys-devel/llvm-11.0
		sys-devel/clang
		sys-apps/hwloc"
RDEPEND="${DEPEND}"
BDEPEND=""

PATCHES=("${FILESDIR}/vendor_opencl_libs_location.epatch")
