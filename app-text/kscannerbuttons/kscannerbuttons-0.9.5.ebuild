# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="a daemon plus a KDE application for monitoring your scanner buttons"
HOMEPAGE="http://jice.free.fr/"
SRC_URI="http://jice.free.fr/KScannerButtons/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND=">=kde-base/kommander-3.5.5
	>=kde-base/ksystraycmd-3.5.5
	>=media-gfx/sane-backends-1.0.18-r2"

S=${WORKDIR}/KScannerButtons

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-build.patch
	sed -i \
		-e '/^PREFIX =/s:=.*:=/usr:' \
		Makefile || die

	rm -f src/sanebuttonsd.c
	emake clean
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	dodoc Changelog README
}

