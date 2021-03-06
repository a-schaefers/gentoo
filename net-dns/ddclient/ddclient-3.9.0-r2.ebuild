# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd user

DESCRIPTION="Perl client used to update dynamic DNS entries"
HOMEPAGE="https://sourceforge.net/projects/ddclient/"
SRC_URI="mirror://sourceforge/ddclient/${P}.tar.gz"

KEYWORDS="~alpha amd64 arm ~hppa ia64 ~mips ppc ppc64 ~sparc x86"
LICENSE="GPL-2+"
SLOT="0"
IUSE="examples iproute2"

RDEPEND="
	dev-lang/perl
	dev-perl/Data-Validate-IP
	dev-perl/Digest-SHA1
	dev-perl/IO-Socket-INET6
	dev-perl/IO-Socket-SSL
	virtual/perl-Digest-SHA
	virtual/perl-JSON-PP
	iproute2? ( sys-apps/iproute2 )
"

pkg_setup() {
	enewgroup ddclient
	enewuser ddclient -1 -1 -1 ddclient
}

src_prepare() {
	# Remove PID setting, to reliably setup the environment for the init script
	sed -e '/^pid/d' -i sample-etc_ddclient.conf || die

	# Remove windows executable
	if use examples; then
		rm sample-etc_dhcpc_dhcpcd-eth0.exe || die
	fi

	# Use sys-apps/iproute2 instead of sys-apps/net-tools
	use iproute2 && eapply "${FILESDIR}"/${P}-use_iproute2.patch

	default
}

src_install() {
	dobin ddclient

	insinto /etc/ddclient
	insopts -m 0600 -o ddclient -g ddclient
	newins sample-etc_ddclient.conf ddclient.conf

	newinitd "${FILESDIR}"/ddclient.initd-r6 ddclient
	systemd_newunit "${FILESDIR}"/ddclient.service-r1 ddclient.service
	systemd_newtmpfilesd "${FILESDIR}"/ddclient.tmpfiles ddclient.conf

	dodoc Change* README* RELEASENOTE TODO UPGRADE

	if use examples; then
		docinto examples
		dodoc sample-*
	fi
}
