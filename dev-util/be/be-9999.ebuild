# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

#PYTHON_DEPEND="2:2.7"
#SUPPORT_PYTHON_ABIS="1"
#PYTHON_MODNAME="libbe"
#RESTRICT_PYTHON_ABIS="2.4 3.*"
#RESTRICT_PYTHON_ABIS="3.*"
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 eutils bash-completion-r1

DESCRIPTION="Bugs Everywhere is a 'distributed bugtracker' which complements distributed revision control systems"
HOMEPAGE="http://bugseverywhere.org/"

if [[ "${PV}" == "9999" ]] ; then
	inherit git-2
	EGIT_BRANCH="master"
	EGIT_REPO_URI="https://gitlab.com/bugseverywhere/bugseverywhere.git"
	SRC_URI=""
else
	SRC_URI="http://download.bugseverywhere.org/releases/${P}.tar.gz"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="bash-completion doc"

RDEPEND="dev-lang/python:3.4
	dev-python/cherrypy
	dev-python/jinja
	dev-python/pyyaml
	bash-completion? ( app-shells/bash-completion )"

DEPEND="${RDEPEND}
	dev-vcs/git
	dev-python/docutils
	doc? (
		dev-python/numpydoc
		dev-util/scons
	)"

src_unpack() {
	if [[ "${PV}" == "9999" ]] ; then
		git-2_src_unpack
	else
		unpack ${A}
	fi
	cd "${S}"
}

src_prepare() {
	distutils-r1_src_prepare
}

src_compile() {
	make libbe/_version.py || die "_version.py generation failed"
	emake RST2MAN="${EROOT}usr/bin/rst2man.py" doc/man/be.1 \
		|| die "be.1 generation failed"
	if use doc ; then
		make -C doc html
	fi
	distutils-r1_src_compile
}

src_install() {
	distutils-r1_src_install
	dodoc AUTHORS NEWS README || die "dodoc failed"
	if [[ "${PV}" != "9999" ]] ; then
		dodoc ChangeLog || die "dodoc failed"
	fi
	if use doc ; then
		dohtml -r doc/.build/html/*
	fi
	if use bash-completion ; then
		newbashcomp misc/completion/be.bash be
	fi
}
