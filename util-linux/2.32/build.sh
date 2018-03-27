#!/bin/sh

set -e

n=`expr $CPU_COUNT / 4 \| 1`

./configure --prefix="$PREFIX" \
            --enable-libuuid \
            --enable-libuuid-force-uuidd \
            --disable-libblkid \
            --disable-libmount \
            --disable-libsmartcols \
            --disable-libfdisk \
            --disable-mount \
            --disable-losetup \
            --disable-zramctl \
            --disable-fsck \
            --disable-partx \
            --disable-uuidd \
            --disable-mountpoint \
            --disable-fallocate \
            --disable-unshare \
            --disable-nsenter \
            --disable-setpriv \
            --disable-eject \
            --disable-agetty \
            --disable-cramfs \
            --disable-bfs \
            --disable-minix \
            --disable-fdformat \
            --disable-hwclock \
            --disable-lslogins \
            --disable-wdctl \
            --disable-cal \
            --disable-logger \
            --disable-switch_root \
            --disable-pivot_root \
            --disable-lsmem \
            --disable-chmem \
            --disable-ipcrm \
            --disable-ipcs \
            --disable-rfkill \
            --disable-tunelp \
            --disable-kill \
            --disable-last \
            --disable-utmpdump \
            --disable-line \
            --disable-mesg \
            --disable-raw \
            --disable-rename \
            --disable-vipw \
            --disable-newgrp \
            --disable-chsh-only-listed \
            --disable-login \
            --disable-nologin \
            --disable-sulogin \
            --disable-su \
            --disable-runuser \
            --disable-ul \
            --disable-more \
            --disable-pg \
            --disable-setterm \
            --disable-schedutils \
            --disable-wall \
            --disable-bash-completion \
            --disable-pylibmount \
            --disable-pg-bell \
            --disable-use-tty-group \
            --disable-makeinstall-chown \
            --disable-makeinstall-setuid \
            --disable-colors-default \
            --without-python

make -j $n
make install
