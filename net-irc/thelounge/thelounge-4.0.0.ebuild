# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

#inherit git-r3
inherit npmv1 user


DESCRIPTION="The self-hosted web IRC client"
HOMEPAGE="https://thelounge.chat/"
#SRC_URI="https://github.com/${PN}/${PN}/releases/download/${PV}/${P}.tar.gz"
NPM_GITHUP_MOD="${PN}/${PN}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/package"
NPM_PKG_DIRS="public client defaults src .thelounge_home"
NPM_DEFAULT_OPTS="-E --no-optional --production --unsafe-perm"
NPM_BINS="index.js => thelounge"

RESTRICT=network-sandbox
# OR fetch all deps in src_unpack()

src_configure() {
	echo "/etc/thelounge" > "${S}/.thelounge_home"

	mkdir ${S}/openrc
cat > ${S}/openrc/${PN} <<EOF
#!/sbin/openrc-run
command=/usr/bin/${PN}
command_args="start"
pidfile=/var/run/${PN}.pid
command_background=true
command_user="${PN}:${PN}"
stop() {
	killall -u ${PN} > /dev/null
}
EOF
}

src_install() {
	insinto /etc/thelounge
	keepdir /etc/thelounge/packages
	keepdir /etc/thelounge/users
	doins defaults/config.js
	doinitd openrc/${PN}
	fowners -R ${PN}:${PN} /etc/${PN}

	npmv1_src_install

	fperms +x ${NPM_PACKAGEDIR}/index.js
}

pkg_preinst() {
	enewuser ${PN}
	enewgroup ${PN}
}
