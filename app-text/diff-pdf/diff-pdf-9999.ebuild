# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="A simple tool for visually comparing two PDF files"
HOMEPAGE="http://vslavik.github.io/diff-pdf"
SRC_URI=""
EGIT_REPO_URI="https://github.com/vslavik/diff-pdf.git"
#EGIT_COMMIT="" # commit hash

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
   >=x11-libs/wxGTK-3.0
   >=x11-libs/cairo-1.4
   >=app-text/poppler-0.10
"
RDEPEND="${DEPEND}"

src_configure() {
	./bootstrap || die "bootstrap failed"
	econf
}
