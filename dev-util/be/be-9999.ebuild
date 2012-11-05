# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

RESTRICT_PYTHON_ABIS="3.*"

EGIT_REPO_URI="git://gitorious.org/be/be"

inherit distutils git-2

DESCRIPTION="Bugs Everywhere is a 'distributed bugtracker', designed to complement distributed revision control systems."
HOMEPAGE="http://bugseverywhere.org/"
SRC_URI=""

LICENSE="GPL2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} dev-python/pyyaml"

