# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit toolchain-funcs

HOMEPAGE="http://unpaper.berlios.de"
SRC_URI="http://download.berlios.de/unpaper/${P/./_}.tgz"
DESCRIPTION="Post-processing tool for scanned book pages"

SLOT="0"

LICENSE="GPL-2"
KEYWORDS="~x86"
S=${WORKDIR}

IUSE=""
DEPEND=""

src_compile() {
	$(tc-getCC ) ${CFLAGS} -lm -O3 -funroll-all-loops -fomit-frame-pointer -ftree-vectorize -o ${PN} src/${PN}.c \
		|| die "compile failed"
}

src_install() {
	dobin ${WORKDIR}/${PN}
}

