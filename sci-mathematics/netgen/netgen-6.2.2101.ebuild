# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="8"

inherit git-r3 cmake

DESCRIPTION="NETGEN is an automatic 3D tetrahedral mesh generator"
HOMEPAGE="https://ngsolve.org/"
EGIT_REPO_URI="https://github.com/NGSolve/netgen.git"
EGIT_COMMIT="v${PV}"

LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~x86"
IUSE="gui python mpi opencascade jpeg ffmpeg numa"
SLOT="0"

DEPEND="
	sys-libs/zlib
	media-libs/libglvnd
	>=dev-lang/tcl-8.5
	>=dev-lang/tk-8.5
	media-libs/freetype
	mpi? ( virtual/mpi )
	opencascade? ( >=sci-libs/opencascade-7.4.0 )
	jpeg? ( virtual/jpeg )
	ffmpeg? ( media-video/ffmpeg )"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare()
{
	sed -i "s|\${TK_INCLUDE_PATH}/tk-private|/usr/lib64/tk8.6/include|g" ng/Togl2.1/CMakeLists.txt
	echo "include(GNUInstallDirs)" >> CMakeLists.txt
	eapply_user
	cmake_src_prepare
}

CMAKE_WARN_UNUSED_CLI=yes
src_configure() {
	mycmakeargs=( )
	mycmakeargs+=( -DUSE_GUI=$(usex gui) )
	mycmakeargs+=( -DUSE_PYTHON=$(usex python) )
	mycmakeargs+=( -DUSE_MPI=$(usex mpi) )
	mycmakeargs+=( -DUSE_OCC=$(usex opencascade) )
	mycmakeargs+=( -DUSE_MPEG=$(usex ffmpeg) )
	mycmakeargs+=( -DUSE_JPEG=$(usex jpeg) )
	mycmakeargs+=( -DUSE_NUMA=$(usex numa) )

	cmake_src_configure
}

src_install() {
	cmake_src_install
	mv ${D}/usr/lib ${D}/usr/lib64
}
