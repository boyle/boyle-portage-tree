# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/bluez/bluez-4.39-r2.ebuild,v 1.4 2009/10/11 16:18:14 maekke Exp $

EAPI="2"

inherit autotools multilib eutils

DESCRIPTION="Bluetooth Tools and System Daemons for Linux"
HOMEPAGE="http://www.bluez.org"
SRC_URI="mirror://kernel/linux/bluetooth/${P}.tar.gz"
LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="alsa caps +consolekit cups debug gstreamer old-daemons pcmcia test-programs usb"

CDEPEND="alsa? ( media-libs/alsa-lib )
	caps? ( >=sys-libs/libcap-ng-0.6.2 )
	cups? ( net-print/cups )
	gstreamer? (
		>=media-libs/gstreamer-0.10
		>=media-libs/gst-plugins-base-0.10
	)
	usb? ( dev-libs/libusb )
	sys-fs/udev
	dev-libs/glib
	sys-apps/dbus
	media-libs/libsndfile
	>=dev-libs/libnl-1.1
	!net-wireless/bluez-libs
	!net-wireless/bluez-utils"
DEPEND="${CDEPEND}
	dev-util/pkgconfig
	sys-devel/bison
	sys-devel/flex"
RDEPEND="${CDEPEND}
	consolekit? ( sys-auth/pambase[consolekit] )
	test-programs? (
		dev-python/dbus-python
		dev-python/pygobject
	)"

src_prepare() {
	if ! use consolekit; then
		# No consolekit for at_console etc, so we grant plugdev the rights
		epatch	"${FILESDIR}/bluez-plugdev.patch"
	fi

	if use cups; then
		epatch "${FILESDIR}"/4.50-cups-location.patch
		eautoreconf
	fi
}

src_configure() {
	econf \
		$(use_enable caps capng) \
		--enable-network \
		--enable-serial \
		--enable-input \
		--enable-audio \
		--enable-service \
		$(use_enable gstreamer) \
		$(use_enable alsa) \
		$(use_enable usb) \
		--enable-netlink \
		--enable-tools \
		--enable-bccmd \
		$(use_enable pcmcia) \
		--enable-hid2hci \
		--enable-dfutool \
		$(use_enable old-daemons hidd) \
		$(use_enable old-daemons pand) \
		$(use_enable old-daemons dund) \
		$(use_enable cups) \
		$(use_enable test-programs test) \
		--enable-udevrules \
		--enable-configfiles \
		$(use_enable debug) \
		--localstatedir=/var
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog README || die

	# don't install useless .la files
	find "${D}" -type f -name '*.la' -delete || die "failed to remove .la files"

	if use test-programs ; then
		cd "${S}/test"
		dobin simple-agent simple-service monitor-bluetooth
		newbin list-devices list-bluetooth-devices
		for b in apitest hsmicro hsplay test-* ; do
			newbin "${b}" "bluez-${b}"
		done
		insinto /usr/share/doc/${PF}/test-services
		doins service-*
		cd "${S}"
	fi

	if use old-daemons; then
		newconfd "${FILESDIR}/4.18/conf.d-hidd" hidd || die
		newinitd "${FILESDIR}/4.18/init.d-hidd" hidd || die
	fi

	## TODO: use group uucp in new udev rules?

	insinto /etc/bluetooth
	doins \
		input/input.conf \
		audio/audio.conf \
		network/network.conf \
		serial/serial.conf \
		|| die
}

pkg_postinst() {
	udevadm control --reload-rules && udevadm trigger --subsystem-match=bluetooth

	elog "To use dial up networking you must install net-dialup/ppp."
	elog
	elog "For a password agent, there are for example net-wireless/bluez-gnome"
	elog "and net-wireless/gnome-bluetooth:2 for GNOME; for KDE4 instead you can"
	elog "install net-wireless/kbluetooth."
	elog
	elog "If you want to use rfcomm as a normal user, you need to add the user"
	elog "to the uucp group."
	elog
	elog "Use the old-daemons use flag to get the old daemons like hidd"
	elog "installed. Please note that the init script doesn't stop the old"
	elog "daemons after you update it so it's recommended to run:"
	elog "  /etc/init.d/bluetooth stop"
	elog "before updating your configuration files or you can manually kill"
	elog "the extra daemons you previously enabled in /etc/conf.d/bluetooth."
	elog
	if use old-daemons; then
		elog "The hidd init script was installed because you have the old-daemons"
		elog "use flag on. It is not started by default via udev so please add it"
		elog "to the required runleves using rc-update <runlevel> add hidd. If"
		elog "you need init scripts for the other daemons, please file requests"
		elog "to https://bugs.gentoo.org."
	else
		elog "The bluetooth service should be started automatically by udev"
		elog "when the required hardware is inserted next time."
	fi
}
