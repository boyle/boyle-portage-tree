# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit perl-app

DESCRIPTION="Create PDF of selected pages with File/Save PDF"
HOMEPAGE="http://gscan2pdf.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="adf doc djvu gocr tesseract unpaper"

DEPEND="dev-lang/perl"

RDEPEND=">=dev-perl/gtk2-perl-1.140-r1
    dev-perl/Gtk2-ImageView
	dev-perl/PDF-API2
	dev-perl/Gtk2-Ex-Simple-List
	>=dev-perl/Locale-gettext-1.05
	dev-perl/config-general
	media-gfx/imagemagick
	media-gfx/sane-backends
	media-libs/tiff
	adf? ( media-gfx/sane-frontends )
	doc? ( dev-perl/Gtk2-Ex-PodViewer )
	unpaper? ( media-gfx/unpaper )
	x11-misc/xdg-utils
	djvu? ( app-text/djvu )
	gocr? ( app-text/gocr )
	tesseract? ( app-text/tesseract )"
	
src_install() {
	perl-module_src_install
	dodoc History
}

pkg_postinst() {
	ewarn "Thunderbird users can't use the Email to PDF feature"
	ewarn "because xdg-email doesn't support creating new emails"
	ewarn "with attachments in Thunderbird."
}

