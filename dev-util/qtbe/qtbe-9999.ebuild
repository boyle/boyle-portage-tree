# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
RESTRICT_PYTHON_ABIS="3.*"

inherit distutils eutils bash-completion-r1

DESCRIPTION="Qt Bugs Everywhere (qtbe) is a graphical user interface for the bug tracking system Bugs Everywhere (BE)."
HOMEPAGE="http://github.com/nsmgr8/qtbe"

if [[ "${PV}" == "9999" ]] ; then
  inherit git-2
  EGIT_BRANCH="master"
  EGIT_REPO_URI="git://github.com/nsmgr8/${PN}.git"
  SRC_URI=""
else
  # e.g.   https://github.com/nsmgr8/qtbe/archive/0.2.zip
  SRC_URI="https://github.com/nsmgr8/${PN}/archive/${PV}.zip"
fi

LICENSE="GPL2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-python/pyside dev-util/be"

RDEPEND="${DEPEND}"
