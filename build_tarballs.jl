using BinaryBuilder

# Collection of sources required to build libcalceph
sources = [
    "https://www.imcce.fr/content/medias/recherche/equipes/asd/calceph/calceph-3.3.0.tar.gz" =>
    "be0ee7e838cbd60bb4a90834a1deb4e657d2d83f8dfe7f34774dc41a7c1cb1b4",
]

￼# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd calceph-3.3.0/
if [[ ${target} == i686-w64* ]] || [[ ${target} == x86_64-w64* ]]; then
    echo 'LT_INIT([win32-dll])' >> configure.ac
    sed -i '/^libcalceph_la_LDFLAGS/ s/$/ -no-undefined/' src/Makefile.am
fi
autoreconf -fi
./configure --prefix=/ --host=$target --enable-fortran=no --enable-python=no --disable-static
make
make install

"""

# We attempt to build for all defined platforms
platforms = [
    BinaryProvider.Linux(:i686, :glibc),
    BinaryProvider.Linux(:x86_64, :glibc),
    BinaryProvider.Linux(:aarch64, :glibc),
    BinaryProvider.Linux(:armv7l, :glibc),
    BinaryProvider.Linux(:powerpc64le, :glibc),
    BinaryProvider.MacOS(),
    BinaryProvider.Windows(:i686),
    BinaryProvider.Windows(:x86_64)
]

products(prefix) = [
    LibraryProduct(prefix,"libcalceph",:libcalceph)
]

dependencies = [￼]

build_tarballs(ARGS, "libcalceph", sources, script, platforms, products, dependencies)
