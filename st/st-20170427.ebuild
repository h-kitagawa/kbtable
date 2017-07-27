# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils multilib savedconfig toolchain-funcs

DESCRIPTION="simple terminal implementation for X"
HOMEPAGE="http://st.suckless.org/"
SRC_URI="http://git.suckless.org/st/snapshot/st-5a10aca702bf7bc9094cb4abaea6c59558740d29.tar.gz"

LICENSE="MIT-with-advertising"
SLOT="0"
KEYWORDS="amd64 hppa x86"
IUSE="savedconfig"

RDEPEND="
	>=sys-libs/ncurses-6.0:0=
	media-libs/fontconfig
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXft
"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig
	x11-proto/xextproto
	x11-proto/xproto
"

src_prepare() {
	eapply_user

	sed -e '/^CFLAGS/s:[[:space:]]-O[^[:space:]]*[[:space:]]: :' \
		-e '/^X11INC/{s:/usr/X11R6/include:/usr/include/X11:}' \
		-e "/^X11LIB/{s:/usr/X11R6/lib:/usr/$(get_libdir)/X11:}" \
		-i config.mk || die
	sed -e '/@echo/!s:@::' \
		-e '/tic/d' \
		-i Makefile || die
	tc-export CC

	restore_config config.h
	epatch "${FILESDIR}/st-bufflen-5a10aca.diff" #added
	epatch "${FILESDIR}/st-scrollback-20170329-149c0d3.diff" #added
	epatch "${FILESDIR}/st-scrollback-mouse-20170427-5a10aca.diff" #added
	epatch "${FILESDIR}/st-scrollback-mouse-altscreen-20170427-5a10aca.diff" #added
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}"/usr install

	dodoc TODO

	make_desktop_entry ${PN} simpleterm utilities-terminal 'System;TerminalEmulator;' ''

	save_config config.h
}

src_unpack() {
    if [ "${A}" != "" ]; then
        unpack ${A}
    fi
    mv "${WORKDIR}/st-5a10aca702bf7bc9094cb4abaea6c59558740d29" "${WORKDIR}/${P}"
}

