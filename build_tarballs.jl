using BinaryBuilder

# Collection of sources required to build libcalceph
sources = [
    "https://www.imcce.fr/content/medias/recherche/equipes/asd/calceph/calceph-3.4.2.tar.gz" =>
    "4bb95979ed77f431c6845b11b7bc49819836e47a8b9ceceff18309683f580c5b",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd calceph-3.4.2/
if [[ ${target} == i686-w64* ]] || [[ ${target} == x86_64-w64* ]]; then
    echo 'LT_INIT([win32-dll])' >> configure.ac
    sed -i '/^libcalceph_la_LDFLAGS/ s/$/ -no-undefined/' src/Makefile.am
fi
autoreconf -fi
./configure --prefix=$prefix --host=$target --enable-fortran=no --enable-python=no --disable-static
make -j${nproc}
make install
"""

# Build on all default platforms
platforms = supported_platforms()

# No dependencies
dependencies = []

products = prefix -> [
    LibraryProduct(prefix, "libcalceph", :libcalceph)
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "libcalceph", v"3.4.2", sources, script, platforms, products, dependencies)
