# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )

inherit cmake flag-o-matic fortran-2 python-r1 toolchain-funcs

DESCRIPTION="A three-dimensional finite element mesh generator"
HOMEPAGE="http://www.geuz.org/gmsh/"
SRC_URI="http://www.geuz.org/gmsh/src/${P}-source.tgz"

LICENSE="GPL-3 free-noncomm"
SLOT="0"
KEYWORDS="~amd64 ~x86"
## cgns is not compiling ATM, maybe fix cgns lib first
IUSE="blas cgns examples jpeg med metis mpi netgen opencascade petsc png python X zlib"

REQUIRED_USE="
	med? ( mpi )
	${PYTHON_REQUIRED_USE}"

RDEPEND="
	virtual/fortran
	X? ( x11-libs/fltk:1 )
	blas? ( virtual/blas virtual/lapack sci-libs/fftw:3.0 )
	cgns? ( sci-libs/cgnslib )
	jpeg? ( virtual/jpeg:0 )
	med? ( sci-libs/med[mpi] )
	opencascade? ( sci-libs/opencascade[tbb] )
	png? ( media-libs/libpng:0 )
	petsc? ( sci-mathematics/petsc )
	zlib? ( sys-libs/zlib )
	mpi? ( virtual/mpi[cxx] )
	${PYTHON_DEPS}"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	python? ( dev-lang/swig:0 )
	"

S=${WORKDIR}/${P}-source

pkg_setup() {
	fortran-2_pkg_setup
}

src_configure() {
	local mycmakeargs=( )

	use blas && \
		mycmakeargs+=(-DCMAKE_Fortran_COMPILER=$(tc-getF77))

	mycmakeargs+=(
		-DENABLE_BLAS_LAPACK="$(usex blas)"
		-DENABLE_CGNS="$(usex cgns)"
		-DENABLE_FLTK="$(usex X)"
		-DENABLE_GRAPHICS="$(usex X)"
		-DENABLE_MED="$(usex med)"
		-DENABLE_MPI="$(usex mpi)"
		-DENABLE_METIS="$(usex metis)"
		-DENABLE_NETGEN="$(usex netgen)"
		-DENABLE_OCC="$(usex opencascade)"
		-DENABLE_OCC_CAF="$(usex opencascade)"
		-DENABLE_OCC_TBB="$(usex opencascade)"
		-DENABLE_PETSC="$(usex petsc)"
		-DENABLE_WRAP_PYTHON="$(usex python)"
		-DENABLE_OPENMP="yes"
		-DENABLE_BUILD_SHARED="yes")

	local occ_lib=$(dirname $(ldconfig -p |grep libTKCAF.so\$ | sed 's| /usr/||'| cut -f2 -d\>))
	sed -i "s|\(find_library(OCC.*\)|\1 ${occ_lib}|" ${S}/CMakeLists.txt
	sed -i "s|\(find_path(OCC.*\)|\1 ${occ_lib/$(get_libdir)/include}|" ${S}/CMakeLists.txt

	cmake_src_configure mycmakeargs
}

src_compile() {
	cmake_src_compile

	cd ${S}/utils/pypi/gmsh
	python_foreach_impl run_in_build_dir default

	cd ${S}/utils/pypi/gmsh-dev
	python_foreach_impl run_in_build_dir default
}

src_install() {
	cmake_src_install

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r demos tutorial
	fi

	if use python ; then
		python_foreach_impl python_domodule "${S}/api/gmsh.py"
	fi
}
