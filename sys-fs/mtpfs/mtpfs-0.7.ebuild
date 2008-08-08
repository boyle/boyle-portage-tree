# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/sshfs-fuse/sshfs-fuse-1.9.ebuild,v 1.6 2008/03/16 14:28:48 fmccor Exp $

inherit eutils

DESCRIPTION="Fuse-filesystem for mtp devices."
SRC_URI="http://www.adebenham.com/${PN}/${P}.tar.gz"
HOMEPAGE="http://www.adebenham.com/mtpfs/"
LICENSE="GPL-2"
DEPEND=">=sys-fs/fuse-2.2
        >=dev-libs/glib-2.6
		>=media-libs/libmtp-0.0.9"
KEYWORDS="amd64 ~hppa ppc ppc64 sparc x86 ~x86-fbsd"
SLOT="0"
IUSE="debug"

src_compile() {
	cd ${P}.orig
	# To enable debugging info use the --enable-debug option when running
	# ./configure
	use debug && local debugconf="--enable-debug"
	econf $debugconf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	cd ${P}.orig
	dobin ${PN} || die "dobin failed"
	dodoc README NEWS ChangeLog AUTHORS || die "dodoc failed"

	einfo "To mount a device run: mtpfs <mount_point>"
	einfo "To umount do: fusermount -u <mount_point>"
	einfo "Check mtp device permissions if you can only do this as root."
}
