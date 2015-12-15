# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils user

DESCRIPTION="Open source workload management, an LSF fork"
HOMEPAGE="http://openlava.org"

if [[ "${PV}" == "9999" ]] ; then
	inherit git-2
	EGIT_BRANCH="master"
	EGIT_REPO_URI="https://github.com/openlava/openlava.git"
	SRC_URI=""
else
	SRC_URI="http://www.openlava.org/tarball/${P}.tar.gz"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"

RDEPEND=""
DEPEND="${RDEPEND}
        dev-vcs/git
		app-admin/logrotate
		dev-tcltk/tcllib"

src_unpack() {
	if [[ "${PV}" == "9999" ]] ; then
		git-2_src_unpack
	else
		unpack ${A}
	fi
	cd "${S}"
}

src_prepare() {
	epatch "${FILESDIR}/${P}-make.patch"
	cp "${FILESDIR}/${PN}.openrc" config/
	chmod +x config/${PN}.openrc
}

src_configure() {
	V=/var/tmp/openlava
	econf --sharedstatedir=${V}/shared \
		  --localstatedir=${V}/local
}

src_install() {
	einstall
	# config
	echo "export LSF_ENVDIR=/etc/openlava" > config/openlava.envd
    newenvd config/openlava.envd 99openlava
	newinitd config/openlava.openrc openlava
	insinto /etc/openlava
	HN=$(hostname)
	sed -i "s/^Administrators *=.*/Administrators = root/" config/lsf.cluster.openlava || die "oops"
	sed -i "s/^# yourhost.*/$HN       !   !   1   -   -/" config/lsf.cluster.openlava  || die "oops"
    doins $d config/ls[bf].{hosts,params,queues,users,cluster.openlava,conf,shared,task}
    dodir /var/log/openlava
    dodir /var/lib/openlava/logdir/info
#    fowners openlava:openlava /var/{lib,log}/openlava /var/lib/openlava/logdir /var/lib/openlava/logdir/info /usr/sbin/{lim,res,sbatchd,mbatchd}
#	fperms  770               /var/{lib,log}/openlava /var/lib/openlava/logdir /var/lib/openlava/logdir/info /usr/sbin/{lim,res,sbatchd,mbatchd}

	# TODO logrotate

	elog "Configure and launch the OpenLava master node"
	elog "$ env-update && source /etc/profile"
	elog "$ vim /etc/openlava/*"
	elog "$ rc-update add openlava default"
	elog "$ /etc/init.d/openlava start"
	elog "$ /etc/init.d/openlava check"
#	die "debug"
}

pkg_setup() {
	enewgroup openlava
	# enewuser <user> [uid] [shell] [homedir] [groups] [params]
	enewuser openlava  -1     -1      -1      openlava    --system
}
