# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A configuration wrapper around restic"
HOMEPAGE="https://github.com/boyle/resticw"
SRC_URI="https://github.com/boyle/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}
	app-backup/restic
	app-backup/redu
	sys-fs/ncdu"
BDEPEND=""

src_install() {
	BIN="/usr/bin/$PN"
	echo -e "#! /bin/sh\nexec $BIN all backup --quiet" > "${S}"/backup.cron
	echo -e "20 04 11 11 * $BIN all check --read-data --quiet # Nov 11 @ 4:20 (Rememberance Day)" > "${S}"/check.cron

	dobin ${PN}
	keepdir /etc/${PN}
	dodoc README.md LICENSE
	doman ${PN}.1

	exeinto /etc/cron.hourly
	newexe backup.cron ${PN}-backup

	exeinto /etc/cron.d
	newexe check.cron ${PN}-check
}
