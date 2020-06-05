umask 022
touch ChangeLog
autoreconf -fiv

./configure --prefix=$PREFIX
cd libpam
make
make install
mkdir $PREFIX/include/security
mv $PREFIX/include/*pam* $PREFIX/include/security
cd ..
