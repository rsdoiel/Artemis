#!/bin/sh

USAGE() {
    if [ "$1" ]; then
        EXIT_CODE="$1"
    else
        EXIT_CODE="0"
    fi
    cat <<EOT
USAGE: ${APP_NAME} [os=OBNC_TARGET_OS] [arch=OBNC_TARGET_ARCH] \\
                [prefix=OBNC_PREFIX] [libdir=OBNC_LIBDIR]

${APP_NAME} generates cfg.Mod which provides the defaults used in
Config.Mod. ${APP_NAME} will guess the defaults based on
what is gleaned from the environment or use the values
provided on the command line.

EOT
    exit "$EXIT_CODE"
}

#
# Scan the environment and pick some default values for
# OBNC_TARGET_OS, OBNC_TARGET_HOST, OBNC_PREFIX, OBNC_LIBDIR
#
APP_NAME="$(basename "$0")"
VERSION="$(cat VERSION)"
for ARG in "$@"; do 
    case "${ARG}" in
    -h* | --help | help )
        USAGE 0
        ;;
    os=*)
        OBNC_TARGET_OS="${ARG#os=}"
        echo "OBNC_TARGET_OS is ${OBNC_TARGET_OS}"
        ;;
    arch=*)
        OBNC_TARGET_ARCH="${ARG#arch=}"
        echo "OBNC_TARGET_ARCH is ${OBNC_TARGET_ARCH}"
        ;;
    prefix=*)
        OBNC_PREFIX="${ARG#prefix=}"
        echo "OBNC_PREFIX is ${OBNC_PREFIX}"
        ;;
    libdir=*)
        OBNC_LIBDIR="${ARG#libdir=}"
        echo "OBNC_LIBDIR is ${OBNC_LIBDIR}"
        ;;
    *)
        echo ""
        echo "ERROR: Unsupported option '${ARG}'"
        echo ""
        USAGE 1
        ;;
    esac
done

if [ "${OBNC_TARGET_OS}" = "" ]; then
    OBNC_TARGET_OS=$(uname)
fi
if [ "${OBNC_TARGET_ARCH}" = "" ]; then
    OBNC_TARGET_ARCH="$(uname -m)"
fi
if [ "${OBNC_PREFIX}" = "" ]; then
    OBNC_PREFIX="/usr/local"
fi
if [ "${OBNC_LIBDIR}" = "" ]; then
    OBNC_LIBDIR="${OBNC_PREFIX}/lib" 
fi

#
# Generate cfg.Mod
#
cat <<CFG > cfg.Mod
(** cfg is generated by mkcfg.sh and imported by Config.Mod *)
MODULE cfg;

VAR
  (** Default values assigned in Config.Mod *)
  version*, os*, arch* : ARRAY 24 OF CHAR;
  prefix*, libDir* : ARRAY 2024 OF CHAR;

BEGIN version := "${VERSION}"; 
  prefix := "${OBNC_PREFIX}";
  libDir := "${OBNC_LIBDIR}"; 
  os := "${OBNC_TARGET_OS}";
  arch := "${OBNC_TARGET_ARCH}";
END cfg.

CFG

