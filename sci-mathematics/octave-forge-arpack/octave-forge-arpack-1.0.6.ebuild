# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit octave-forge

DESCRIPTION="Arpack for Octave"
HOMEPAGE="http://octave.sourceforge.net/arpack/index.html"
SRC_URI="mirror://sourceforge/octave/${OCT_PKG}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND="${DEPEND}
		 >=sci-libs/arpack-96-r2"

