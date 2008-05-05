# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Evolution E Plugin -- Remove Duplicate Emails"
HOMEPAGE="http://www.advogato.org/person/garnacho/diary.html"
SRC_URI="http://www.gnome.org/~carlosg/stuff/evolution/${P}.tar.gz"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE=""

RDEPEND="mail-client/evolution"

#src_compile {
#	econf || die "econf failed"
#	emake || die "emake failed"
#}

#src_install {
#	einstall || die "einstall failed"
#}
