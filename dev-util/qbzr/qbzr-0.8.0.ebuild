# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/bzrtools/bzrtools-0.92.1.ebuild,v 1.1 2007/11/14 10:32:36 lucass Exp $

NEED_PYTHON=2.4

inherit distutils versionator

DESCRIPTION="qbzr is a useful collection of QT based utilities for bzr."
HOMEPAGE="http://bazaar-vcs.org/QBzr"
SRC_URI="https://launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE="syntax-highlighting"

DEPEND=">=x11-libs/qt-4.2.0
        >=dev-python/PyQt4-4.1.0
		>=dev-util/bzr-0.92
		syntax-highlighting?(dev-python/pygments)"

#DOCS="CREDITS NEWS.Shelf TODO.Shelf"

#S="${WORKDIR}/${P}"

PYTHON_MODNAME=bzrlib
