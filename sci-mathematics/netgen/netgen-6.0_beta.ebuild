# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

inherit autotools eutils flag-o-matic multilib versionator

MY_P=${P/_beta/-beta}
MY_PN=${PN}-mesher
MY_PV=$(get_version_component_range 1-2)
DESCRIPTION="NETGEN is an automatic 3d tetrahedral mesh generator"
HOMEPAGE="http://www.hpfem.jku.at/netgen/"
SRC_URI="mirror://sourceforge/project/${MY_PN}/${MY_PN}/${MY_PV}/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~x86"
IUSE="-ffmpeg jpeg -mpi opencascade"
SLOT="0"

DEPEND="dev-tcltk/tix
	dev-tcltk/togl:1.7
	virtual/opengl
	x11-libs/libXmu
	opencascade? ( >=sci-libs/opencascade-6.9.1 )
	ffmpeg? ( media-video/ffmpeg )
	jpeg? ( virtual/jpeg )
	mpi? ( virtual/mpi ) "
RDEPEND="${DEPEND}"
# Note, MPI has not be tested.

S=${WORKDIR}/${MY_P}

PATCHES="${FILESDIR}/${PN}-5.3-opencascade.patch
    ${FILESDIR}/${PN}-6.0-conf-togl.patch"

src_prepare()
{
    if declare -p PATCHES | grep -q "^declare -a "; then
        [[ -n ${PATCHES[@]} ]] && eapply "${PATCHES[@]}"
    else
        [[ -n ${PATCHES} ]] && eapply ${PATCHES}
    fi
	eautoreconf
	eapply_user
}

src_configure() {
	# This is not the most clever way to deal with these flags
	# but --disable-xxx does not seem to work correcly, so...
	local myconf="--with-togl=/usr/$(get_libdir)/Togl1.7"

	if use opencascade; then
		myconf="${myconf} --enable-occ --with-occ=$CASROOT"
		append-ldflags -L$CASROOT/lin/$(get_libdir)
	fi

	use mpi && myconf="${myconf} --enable-parallel"
	use ffmpeg && myconf="${myconf} --enable-ffmpeg"
	use jpeg && myconf="${myconf} --enable-jpeglib"

	append-cppflags -I/usr/include/togl-1.7

	econf \
		${myconf}

	# This would be the more elegant way:
# 	econf \
# 		$(use_enable opencascade occ) \
# 		$(use_with opencascade "occ=$CASROOT") \
# 		$(use_enable mpi parallel) \
# 		$(use_enable ffmpeg) \
# 		$(use_enable jpeg jpeglib)
}

src_install() {
	local NETGENDIR="/usr/share/netgen"

	echo -e "NETGENDIR=${NETGENDIR} \nLDPATH=/usr/$(get_libdir)/Togl1.7" > ./99netgen
	doenvd 99netgen

	emake DESTDIR="${D}" install
	mv "${D}"/usr/bin/{*.tcl,*.ocf} "${D}${NETGENDIR}"

	# Install icon and .desktop for menu entry
	doicon "${FILESDIR}"/${PN}.png
	domenu "${FILESDIR}"/${PN}.desktop
}

pkg_postinst() {
	elog "Please make sure to update your environment variables:"
	elog "env-update && source /etc/profile"
}
