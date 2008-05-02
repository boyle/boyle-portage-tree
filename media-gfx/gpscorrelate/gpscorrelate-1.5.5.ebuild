# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Correlates GPS data with EXIF tags"
HOMEPAGE="http://freefoote.dview.net/linux/"
SRC_URI="http://freefoote.dview.net/linux/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"
DEPEND="dev-libs/libxml2 media-gfx/exiv2 x11-libs/gtk+"

src_install() {
	dobin gpscorrelate gpscorrelate-gui || die "Failed to install binary"
	if use doc; then
		dodoc doc/*
	fi
}

