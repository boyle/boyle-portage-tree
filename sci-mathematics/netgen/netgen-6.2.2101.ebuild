# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="7"

inherit git-r3 cmake

DESCRIPTION="NETGEN is an automatic 3D tetrahedral mesh generator"
HOMEPAGE="https://ngsolve.org/"
EGIT_REPO_URI="https://github.com/NGSolve/netgen.git"
EGIT_COMMIT="v${PV}"

LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~x86"
IUSE="gui python mpi opencascade jpeg ffmpeg numa"
SLOT="0"

#   dev-tcltk/tix
#	dev-tcltk/togl:1.7
#	x11-libs/libXmu
#	virtual/opengl
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

#S=${WORKDIR}/${MY_P}

#PATCHES="${FILESDIR}/${PN}-5.3-opencascade.patch
#    ${FILESDIR}/${PN}-6.0-conf-togl.patch"

src_prepare()
{
	sed -i "s|\${TK_INCLUDE_PATH}/tk-private|/usr/lib64/tk8.6/include|g" ng/Togl2.1/CMakeLists.txt
	echo "include(GNUInstallDirs)" >> CMakeLists.txt
	eapply_user
	cmake_src_prepare
}
#    if declare -p PATCHES | grep -q "^declare -a "; then
#        [[ -n ${PATCHES[@]} ]] && eapply "${PATCHES[@]}"
#    else
#        [[ -n ${PATCHES} ]] && eapply ${PATCHES}
#    fi
#	eautoreconf
#	eapply_user
#}

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

	#mycmakeargs+=( "-DNG_INSTALL_DIR_LIB_DEFAULT=lib64" )

	cmake_src_configure
}

#src_configure() {
#	# This is not the most clever way to deal with these flags
#	# but --disable-xxx does not seem to work correcly, so...
#	local myconf="--with-togl=/usr/$(get_libdir)/Togl1.7"
#
#	if use opencascade; then
#		myconf="${myconf} --enable-occ --with-occ=$CASROOT"
#		append-ldflags -L$CASROOT/lin/$(get_libdir)
#	fi
#
#	use mpi && myconf="${myconf} --enable-parallel"
#	use ffmpeg && myconf="${myconf} --enable-ffmpeg"
#	use jpeg && myconf="${myconf} --enable-jpeglib"
#
#	append-cppflags -I/usr/include/togl-1.7
#
#	econf \
#		${myconf}
#
#	# This would be the more elegant way:
## 	econf \
## 		$(use_enable opencascade occ) \
## 		$(use_with opencascade "occ=$CASROOT") \
## 		$(use_enable mpi parallel) \
## 		$(use_enable ffmpeg) \
## 		$(use_enable jpeg jpeglib)
#}

src_install() {
	cmake_src_install
	mv ${D}/usr/lib ${D}/usr/lib64
}
#src_install() {
#	local NETGENDIR="/usr/share/netgen"
#
#	echo -e "NETGENDIR=${NETGENDIR} \nLDPATH=/usr/$(get_libdir)/Togl1.7" > ./99netgen
#	doenvd 99netgen
#
#	emake DESTDIR="${D}" install
#	mv "${D}"/usr/bin/{*.tcl,*.ocf} "${D}${NETGENDIR}"
#
#	# Install icon and .desktop for menu entry
#	doicon "${FILESDIR}"/${PN}.png
#	domenu "${FILESDIR}"/${PN}.desktop
#}

#pkg_postinst() {
#	elog "Please make sure to update your environment variables:"
#	elog "env-update && source /etc/profile"
#}
