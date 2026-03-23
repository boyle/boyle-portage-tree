# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo

DESCRIPTION="ncdu for your restic repo"
HOMEPAGE="https://github.com/drdo/redu"
SRC_URI="
	https://github.com/drdo/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="app-backup/restic"

QA_FLAGS_IGNORED="/usr/bin/${PN}"

src_install() {
	cargo_src_install
}
