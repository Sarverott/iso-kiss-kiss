#!/usr/bin/env bash

# ==============================================================================
# ISO-KISS-KISS: Integrity Verification Bootstrapper
# Generates multi-algorithm checksums for ISO images in a automated workflow.
# ==============================================================================

set -euo pipefail

# --- Konfiguracja i Kolory ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Funkcje obliczające sumy kontrolne ---

calc_md5() {
    local file="$1"
    if command -v md5sum &> /dev/null; then
        md5sum "$file"
    elif command -v md5 &> /dev/null; then
        echo "$(md5 -q "$file")  $file"
    else
        echo -e "${RED}[ERR] No MD5 binary found${NC}" >&2
        return 1
    fi
}

calc_sha1() {
    local file="$1"
    if command -v sha1sum &> /dev/null; then
        sha1sum "$file"
    else
        shasum -a 1 "$file"
    fi
}

calc_sha256() {
    local file="$1"
    if command -v sha256sum &> /dev/null; then
        sha256sum "$file"
    else
        shasum -a 256 "$file"
    fi
}

calc_sha512() {
    local file="$1"
    if command -v sha512sum &> /dev/null; then
        sha512sum "$file"
    else
        shasum -a 512 "$file"
    fi
}

# --- Główna procedura przetwarzania ---
process_iso() {
    local iso_path="$1"
    local base_dir
    base_dir=$(dirname "$iso_path")
    local filename
    filename=$(basename "$iso_path")
    
    echo -e "${BLUE}[*] Processing: $filename...${NC}"
    
    # Przechodzimy do katalogu z plikiem, aby ścieżki w plikach sum były relatywne
    cd "$base_dir"

    # Generowanie plików sum kontrolnych obok pliku źródłowego
    calc_md5 "$filename" > "${filename}.md5"
    calc_sha1 "$filename" > "${filename}.sha1"
    calc_sha256 "$filename" > "${filename}.sha256"
    calc_sha512 "$filename" > "${filename}.sha512"
    
    # Zbiorczy manifest w formacie ISO-KISS-KISS
    local manifest="CHECKSUMS.txt"
    {
        echo "=========================================================================="
        echo "ISO-KISS-KISS INTEGRITY MANIFEST | Generated: $(date -u)"
        echo "File: $filename"
        echo "=========================================================================="
        echo "MD5:    $(cat "${filename}.md5" | awk '{print $1}')"
        echo "SHA1:   $(cat "${filename}.sha1" | awk '{print $1}')"
        echo "SHA256: $(cat "${filename}.sha256" | awk '{print $1}')"
        echo "SHA512: $(cat "${filename}.sha512" | awk '{print $1}')"
        echo -e "\n"
    } >> "$manifest"

    echo -e "${GREEN}[+] Checksums created successfully for $filename!${NC}"
    cd - > /dev/null
}

# --- Wybór celu ---
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}[ERR] Target directory '$TARGET_DIR' does not exist.${NC}"
    exit 1
fi

# Szukamy wszystkich plików .iso w podanej lokalizacji
found_any=false
while IFS= read -r -d '' file; do
    process_iso "$file"
    found_any=true
done < <(find "$TARGET_DIR" -type f -name "*.iso" -print0)

if [ "$found_any" = false ]; then
    echo -e "${RED}[!] No .iso files found in '$TARGET_DIR'.${NC}"
fi
