# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

FLUTTER_VERSION="3.41.6"

DESCRIPTION="An IRC client for mobile devices"
HOMEPAGE="https://goguma.im https://codeberg.org/emersion/goguma"
SRC_URI="
	https://codeberg.org/emersion/goguma/releases/download/v${PV}/goguma-${PV}.tar.gz
	https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
"
S="${WORKDIR}/goguma-${PV}"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-libs/glib:2
	media-libs/fontconfig
	media-libs/harfbuzz
	media-libs/libepoxy
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-libs/pango
"

BDEPEND="app-arch/xz-utils dev-util/patchelf"

PATCHES=(
	"${FILESDIR}/disable-titlebar.patch"
)

RESTRICT="strip"

QA_PREBUILT="usr/lib/goguma/* usr/lib/goguma/lib/*"

src_unpack() {
	default

	tar -xf "${DISTDIR}/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
		-C "${WORKDIR}" || die "Failed to extract Flutter SDK"
}

src_prepare() {
	default

	export PUB_CACHE="${WORKDIR}/.pub-cache"
	mkdir -p "${PUB_CACHE}"

	"${WORKDIR}/flutter/bin/flutter" config --no-analytics || die
	"${WORKDIR}/flutter/bin/flutter" precache --linux || die

	cd "${S}"
	"${WORKDIR}/flutter/bin/flutter" pub get || die
}

src_compile() {
	cd "${S}"

	export PATH="${WORKDIR}/flutter/bin:${PATH}"
	export PUB_CACHE="${WORKDIR}/.pub-cache"

	"${WORKDIR}/flutter/bin/flutter" build linux --release || die
}

src_install() {
	insinto /usr/lib/goguma
	doins -r "${S}/build/linux/x64/release/bundle/"*

	patchelf --remove-rpath "${ED}"/usr/lib/goguma/lib/*.so || die "Failed to remove rpaths"

	dosym ../lib/goguma/goguma /usr/bin/goguma

	local resdir="${S}/android/app/src/main/res"
	if [[ -d "${resdir}" ]]; then
		newmenu "${FILESDIR}/goguma.desktop" fr.emersion.goguma.desktop

		for size in 48x48 72x72 96x96 192x192; do
			if [[ -f "${resdir}/mipmap-${size}/ic_launcher.png" ]]; then
				newicon -s "${size}" "${resdir}/mipmap-${size}/ic_launcher.png" goguma
			fi
		done
	fi
}
