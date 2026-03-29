# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FLUTTER_VERSION="3.41.6"

# Flutter/Dart dependencies from pub.dev.
# These are fetched via SRC_URI to ensure they are recorded in Manifest for offline builds.
# To update this list:
#   1. Temporarily add --no-offline to src_prepare() and run: ebuild ./goguma-0.9.1.ebuild clean prepare
#   2. Extract packages from ${WORKDIR}/goguma-0.9.1/pubspec.lock using:
#      python3 -c "import yaml; data=yaml.safe_load(open('pubspec.lock'));
#         [print(f'{pkg}@{info[\"version\"]}') for pkg,info in
#         sorted(data['packages'].items()) if info['version'] != '0.0.0']"
#   3. Update FLUTTER_PUB_DEPS below with the new list (use name@version format)
#   4. Run: ebuild ./goguma-0.9.1.ebuild manifest
FLUTTER_PUB_DEPS="
	_flutterfire_internals@1.3.65
	app_links@7.0.0
	app_links_linux@1.0.3
	app_links_platform_interface@2.0.2
	app_links_web@1.0.4
	args@2.7.0
	async@2.13.0
	audioplayers@6.5.1
	audioplayers_android@5.2.1
	audioplayers_darwin@6.3.0
	audioplayers_linux@4.2.1
	audioplayers_platform_interface@7.1.1
	audioplayers_web@5.1.1
	audioplayers_windows@4.2.1
	boolean_selector@2.1.2
	characters@1.4.1
	clock@1.1.2
	collection@1.19.1
	connectivity_plus@7.0.0
	connectivity_plus_platform_interface@2.0.1
	cross_file@0.3.5+1
	crypto@3.0.7
	csslib@1.0.2
	dbus@0.7.11
	dynamic_color@1.8.1
	fake_async@1.3.3
	ffi@2.1.5
	file@7.0.1
	file_selector@1.1.0
	file_selector_android@0.5.2+4
	file_selector_ios@0.5.3+5
	file_selector_linux@0.9.4
	file_selector_macos@0.9.5
	file_selector_platform_interface@2.7.0
	file_selector_web@0.9.4+2
	file_selector_windows@0.9.3+5
	firebase_core@4.3.0
	firebase_core_platform_interface@6.0.2
	firebase_core_web@3.3.1
	firebase_messaging@16.1.0
	firebase_messaging_platform_interface@4.7.5
	firebase_messaging_web@4.1.1
	fixnum@1.1.1
	flutter_apns_only@1.6.0
	flutter_background@1.3.0+1
	flutter_lints@6.0.0
	flutter_local_notifications@19.5.0
	flutter_local_notifications_linux@6.0.0
	flutter_local_notifications_platform_interface@9.1.0
	flutter_local_notifications_windows@1.0.3
	flutter_plugin_android_lifecycle@2.0.33
	geoclue@0.1.1
	geolocator@14.0.2
	geolocator_android@5.0.2
	geolocator_apple@2.3.13
	geolocator_linux@0.2.3
	geolocator_platform_interface@4.2.6
	geolocator_web@4.1.3
	geolocator_windows@0.2.5
	gsettings@0.2.8
	gtk@2.1.0
	hex@0.2.0
	html@0.15.6
	http@1.6.0
	http_parser@4.1.2
	image_picker@1.2.1
	image_picker_android@0.8.13+10
	image_picker_for_web@3.1.1
	image_picker_ios@0.8.13+3
	image_picker_linux@0.2.2
	image_picker_macos@0.2.2+1
	image_picker_platform_interface@2.11.1
	image_picker_windows@0.2.2
	json_annotation@4.9.0
	leak_tracker@11.0.2
	leak_tracker_flutter_testing@3.0.10
	leak_tracker_testing@3.0.2
	linkify@5.0.0
	lints@6.0.0
	matcher@0.12.19
	material_color_utilities@0.13.0
	meta@1.17.0
	mime@2.0.0
	nested@1.0.0
	nm@0.5.0
	package_info_plus@8.3.1
	package_info_plus_platform_interface@3.2.1
	path@1.9.1
	path_provider@2.1.5
	path_provider_android@2.2.22
	path_provider_foundation@2.5.1
	path_provider_linux@2.2.1
	path_provider_platform_interface@2.1.2
	path_provider_windows@2.3.0
	petitparser@7.0.1
	platform@3.1.6
	plugin_platform_interface@2.1.8
	provider@6.1.5+1
	record@6.1.2
	record_android@1.4.5
	record_ios@1.1.5
	record_linux@1.2.1
	record_macos@1.1.2
	record_platform_interface@1.4.0
	record_web@1.2.2
	record_windows@1.0.7
	screen_retriever@0.2.0
	screen_retriever_linux@0.2.0
	screen_retriever_macos@0.2.0
	screen_retriever_platform_interface@0.2.0
	screen_retriever_windows@0.2.0
	scrollable_positioned_list@0.3.8+1
	sentry@9.9.2
	share_handler@0.0.25
	share_handler_android@0.0.11
	share_handler_ios@0.0.15
	share_handler_platform_interface@0.0.6
	share_plus@12.0.1
	share_plus_platform_interface@6.1.0
	shared_preferences@2.5.4
	shared_preferences_android@2.4.18
	shared_preferences_foundation@2.5.6
	shared_preferences_linux@2.4.1
	shared_preferences_platform_interface@2.4.1
	shared_preferences_web@2.4.3
	shared_preferences_windows@2.4.1
	source_span@1.10.1
	sqflite@2.4.2
	sqflite_android@2.4.2+2
	sqflite_common@2.5.6
	sqflite_common_ffi@2.3.7+1
	sqflite_darwin@2.4.2
	sqflite_platform_interface@2.4.0
	sqlite3@2.9.4
	stack_trace@1.12.1
	stream_channel@2.1.4
	string_scanner@1.4.1
	synchronized@3.4.0
	term_glyph@1.2.2
	test_api@0.7.10
	timezone@0.10.1
	typed_data@1.4.0
	unicode_emojis@0.5.1
	unifiedpush@6.2.0
	unifiedpush_android@3.4.1
	unifiedpush_linux@1.0.0
	unifiedpush_platform_interface@4.0.0
	unifiedpush_storage_interface@1.0.0
	url_launcher@6.3.2
	url_launcher_android@6.3.28
	url_launcher_ios@6.3.6
	url_launcher_linux@3.2.2
	url_launcher_macos@3.2.5
	url_launcher_platform_interface@2.3.2
	url_launcher_web@2.4.1
	url_launcher_windows@3.1.5
	uuid@4.5.2
	vector_math@2.2.0
	vm_service@15.0.2
	web@1.1.1
	webcrypto@0.6.0
	webpush_encryption@1.0.1
	win32@5.15.0
	window_manager@0.5.1
	workmanager@0.9.0+3
	workmanager_android@0.9.0+2
	workmanager_apple@0.9.1+2
	workmanager_platform_interface@0.9.1+1
	xdg_directories@1.1.0
	xml@6.6.1
"

inherit desktop flutter

DESCRIPTION="An IRC client for mobile devices"
HOMEPAGE="https://goguma.im https://codeberg.org/emersion/goguma"
SRC_URI="
	https://codeberg.org/emersion/goguma/releases/download/v${PV}/goguma-${PV}.tar.gz
	https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
	${FLUTTER_PUB_URIS}
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
	unpack ${P}.tar.gz
	unpack flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

	flutter_src_unpack
}

src_prepare() {
	default

	export PUB_CACHE="${WORKDIR}/.pub-cache"

	"${WORKDIR}/flutter/bin/flutter" config --no-analytics || die
	"${WORKDIR}/flutter/bin/flutter" precache --linux || die

	cd "${S}"
	# Use --offline to avoid network access; packages are already in PUB_CACHE
	"${WORKDIR}/flutter/bin/flutter" pub get --offline || die
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
