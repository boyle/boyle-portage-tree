# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_4 python3_5 python3_6 )

#inherit distutils-r1 cmake-utils eutils
inherit cmake-utils eutils python-single-r1

DESCRIPTION="Mesh generation component of FEniCS"
HOMEPAGE="https://bitbucket.org/fenics-project/mshr/"
SRC_URI="https://bitbucket.org/fenics-project/mshr/downloads/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	${PYTHON_DEPS}
    dev-libs/gmp
	dev-libs/mpfr
	dev-cpp/eigen
	dev-libs/boost
    ~sci-mathematics/dolfin-${PV}[${PYTHON_USEDEP}]
"
#	=sci-mathematics/cgal-4.9
#	=   ???         /tetgen-1.5.0
# TODO CGAL and tetgen are bundled... unbundle 'em

RDEPEND="${DEPEND}"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
   sed -i -e 's/\<lib\>/lib64/g' CMakeLists.txt || die "sed borked"
   eapply_user
}

src_configure() {
        local mycmakeargs=(
                "-DDOLFIN_DIR=/usr/share/cmake"
        )

        export CMAKE_BUILD_TYPE="Release"
        cmake-utils_src_configure
}
