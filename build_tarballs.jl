using BinaryBuilder

# These are the platforms built inside the wizard
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


# If the user passed in a platform (or a few, comma-separated) on the
# command-line, use that instead of our default platforms
if length(ARGS) > 0
    platforms = platform_key.(split(ARGS[1], ","))
end
info("Building for $(join(triplet.(platforms), ", "))")

# Collection of sources required to build libcalceph
sources = [
    "https://www.imcce.fr/content/medias/recherche/equipes/asd/calceph/calceph-3.1.0.tar.gz" =>
    "aaf43641205af6b2d7633eead72d6948e43b77424a56bc1493462d601509be85",
]

script = raw"""
cd $WORKSPACE/srcdir
cd calceph-3.0.0/
if [[ ${target} == i686-w64* ]] || [[ ${target} == x86_64-w64* ]]; then
    echo 'LT_INIT([win32-dll])' >> configure.ac
    sed -i '/^libcalceph_la_LDFLAGS/ s/$/ -no-undefined/' src/Makefile.am
fi
autoreconf -fi
./configure --prefix=/ --host=$target --enable-fortran=no --enable-python=no --disable-static
make
make install

"""

products = prefix -> [
    LibraryProduct(prefix,"libcalceph")
]


# Build the given platforms using the given sources
hashes = autobuild(pwd(), "libcalceph", platforms, sources, script, products)

if !isempty(get(ENV,"TRAVIS_TAG",""))
    print_buildjl(pwd(), products, hashes,
        "https://github.com/JuliaAstro/CALCEPHBuilder/releases/download/$(ENV["TRAVIS_TAG"])")
end
