# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{3,4,5,6} )

inherit python-r1 distutils-r1 eutils

DESCRIPTION="launch a Web browser for URLs contained in email messages"
HOMEPAGE="https://github.com/firecat53/urlscan"
SRC_URI="https://github.com/firecat53/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPLv2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="dev-python/urwid"
RDEPEND="${DEPEND}"
