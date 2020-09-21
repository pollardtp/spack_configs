#!/bin/bash -e
[ "${BASH_SOURCE[0]}" ] && SCRIPT_NAME="${BASH_SOURCE[0]}" || SCRIPT_NAME=$0
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_NAME")" && pwd -P)"

cmake_ver="3.18.0"
cmake_sha256="83b4ffcb9482a73961521d2bafe4a16df0168f03f56e6624c419c461e5317e29"
source "${SCRIPT_DIR}"/common_vars.sh
source "${SCRIPT_DIR}"/tool_kit.sh
source "${SCRIPT_DIR}"/signal_trap.sh
source "${INSTALLDIR}"/toolchain.conf
source "${INSTALLDIR}"/toolchain.env

[ -f "${BUILDDIR}/setup_cmake" ] && rm "${BUILDDIR}/setup_cmake"

! [ -d "${BUILDDIR}" ] && mkdir -p "${BUILDDIR}"
cd "${BUILDDIR}"

case "$with_cmake" in
    __INSTALL__)
        echo "==================== Installing CMake ===================="
        pkg_install_dir="${INSTALLDIR}/cmake-${cmake_ver}"
        install_lock_file="$pkg_install_dir/install_successful"
        if verify_checksums "${install_lock_file}" ; then
            echo "cmake-${cmake_ver} is already installed, skipping it."
        else
            if [ -f cmake-${cmake_ver}.tar.gz ] ; then
                echo "cmake-${cmake_ver}.tar.gz is found"
            else
                download_pkg ${DOWNLOADER_FLAGS} ${cmake_sha256} \
                             https://github.com/Kitware/CMake/releases/download/v${cmake_ver}/cmake-${cmake_ver}.tar.gz
            fi
            echo "Installing from scratch into ${pkg_install_dir}"
            [ -d cmake-${cmake_ver} ] && rm -rf cmake-${cmake_ver}
            tar -xzf cmake-${cmake_ver}.tar.gz
            cd cmake-${cmake_ver}
            # on ARCHER (cray system), ccmake cannot compile without
            # -ldl, but was not sure how to link -ldl in the CMake
            # bootstrap scripts. As GUI are not really needed, we just
            # disable it here
            if [ "$ENABLE_CRAY" = "__TRUE__" ] ; then
                cp CMakeLists.txt CMakeLists.txt.orig
                sed -i 's/option(BUILD_CursesDialog "Build the CMake Curses Dialog ccmake" ON)/option(BUILD_CursesDialog "Build the CMake Curses Dialog ccmake" OFF)/g' CMakeLists.txt
            fi
            ./bootstrap --prefix="${pkg_install_dir}" --parallel="${NPROCS}" -- -DCMAKE_USE_OPENSSL=OFF > configure.log 2>&1
            make -j $NPROCS >  make.log 2>&1
            make install > install.log 2>&1
            cd ..
            write_checksums "${install_lock_file}" "${SCRIPT_DIR}/$(basename ${SCRIPT_NAME})"
        fi
        ;;
    __SYSTEM__)
        echo "==================== Finding CMake from system paths ===================="
        check_command cmake "cmake"
        ;;
    __DONTUSE__)
        ;;
    *)
        echo "==================== Linking CMake to user paths ===================="
        pkg_install_dir="$with_cmake"
        check_dir "${with_cmake}/bin"
        ;;
esac
if [ "$with_cmake" != "__DONTUSE__" ] ; then
    if [ "$with_cmake" != "__SYSTEM__" ] ; then
        cat <<EOF > "${BUILDDIR}/setup_cmake"
prepend_path PATH "$pkg_install_dir/bin"
EOF
        cat "${BUILDDIR}/setup_cmake" >> $SETUPFILE
    fi
fi

# update toolchain environment
load "${BUILDDIR}/setup_cmake"
export -p > "${INSTALLDIR}/toolchain.env"

cd "${ROOTDIR}"
report_timing "cmake"
