using BinaryBuilder

# Collection of sources required to build libcalceph
sources = [
    "https://www.imcce.fr/content/medias/recherche/equipes/asd/calceph/calceph-3.1.0.tar.gz" =>
    "aaf43641205af6b2d7633eead72d6948e43b77424a56bc1493462d601509be85",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd calceph-3.1.0/
if [[ ${target} == i686-w64* ]] || [[ ${target} == x86_64-w64* ]]; then
    echo 'LT_INIT([win32-dll])' >> configure.ac
    sed -i '/^libcalceph_la_LDFLAGS/ s/$/ -no-undefined/' src/Makefile.am
fi
autoreconf -fi
./configure --prefix=/ --host=$target --enable-fortran=no --enable-python=no --disable-static
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    # Windows
    Windows(:i686),
    Windows(:x86_64),

    # Hello linux my old friend
    Linux(:i686, :glibc),
    Linux(:x86_64, :glibc),
    Linux(:aarch64, :glibc),
    Linux(:armv7l, :glibc),
    Linux(:powerpc64le, :glibc),

    # Add some musl love
    Linux(:i686, :musl),
    Linux(:x86_64, :musl),

    # The BSD's
    FreeBSD(:x86_64),
    MacOS()
]

products = prefix -> [
    LibraryProduct(prefix, "libcalceph", :libcalceph)
]

# Dependencies that must be installed before this package can be built
dependencies = []

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "libcalceph", sources, script, platforms, products, dependencies)
