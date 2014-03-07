# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
#inherit toolchain-funcs

DESCRIPTION="TaskSpooler is a comfortable way of running batch jobs"
HOMEPAGE="http://vicerveza.homeunix.net/~viric/soft/ts/"
SRC_URI="http://vicerveza.homeunix.net/~viric/soft/ts/ts-${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}
	S=$(dirname ${S})/ts-${PV}
	sed -i \
		-e 's|CFLAGS=|CFLAGS+=|' \
		-e 's|-g -O0||' \
		${S}/Makefile || die "sed failed"
}

src_compile() {
	#emake CC=$(tc-getCC) || die "emake failed"
	emake || die "emake failed"
}

src_install() {
	exeinto /usr/bin
	doexe ts
	doman ts.1
	dodoc Changelog OBJECTIVES PORTABILITY PROTOCOL README TRICKS
}

src_test() {
	PATH="${D}/usr/bin:${PATH}" ./testbench.sh || die "tests failed"
}
