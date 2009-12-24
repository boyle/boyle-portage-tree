# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils versionator rpm

#MY_PV=1.1.0-2
#MY_P=iscan-network-nt-${MY_PV}
DESCRIPTION="Network Scanner driver for iScan/Sane on Epson Workforce 610 and others"
HOMEPAGE="http://www.avasys.jp/lx-bin2/linux_e/spc/DL2.do"
SRC_URI="http://www.avasys.jp/iscan-network-nt-1.1.0-2.x86_64.rpm"

# $(replace_version_separator 3 '-')

LICENSE="AVASYS PUBLIC LICENSE"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="fetch mirror strip"
IUSE=""

DEPEND="media-gfx/iscan"
RDEPEND=""


RDEPEND="x86? (
		x11-libs/pango )
	amd64? (
		app-emulation/emul-linux-x86-gtklibs
	)
	"
DEPEND=""

S="${WORKDIR}"

src_unpack() {
	rpm_src_unpack ${A}
}

src_install() {
	cd usr/share/doc/iscan-network-nt-1.1.0
	dodoc README NEWS AVASYSPL.en.txt || die

	cd ../../.. 
	dodir /usr
	mv $(get_libdir) "${D}/usr/" || die
}
