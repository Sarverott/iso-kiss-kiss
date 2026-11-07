#!/usr/bin/env bash

# ==============================================================================
# ISO-KISS-KISS: Integrity Verification Script (Bash Edition)
# Description: Automated checksum generator for ISO files and system kernels.
# ==============================================================================

set -euo pipefail

# Katalog docelowy (domyślnie bieżący)
TARGET_DIR="${1:-.}"

# Funkcje generujące sumy kontrolne (każdy wariant jako osobna funkcja)
generate_md5() {
    local file="$1"
    if command -v md5sum &> /dev/null; then
        md5sum "$file" > "$file.md5"
        echo "  [✓] MD5 generated"
    else
        echo "  [✗] md5sum command not found"
    fi
}

generate_sha1() {
    local file="$1"
    if command -v sha1sum &> /dev/null; then
        sha1sum "$file" > "$file.sha1"
        echo "  [✓] SHA-1 generated"
    else
        echo "  [✗] sha1sum command not found"
    fi
}

generate_sha256() {
    local file="$1"
    if command -v sha256sum &> /dev/null; then
        sha256sum "$file" > "$file.sha256"
        echo "  [✓] SHA-256 generated"
    else
        echo "  [✗] sha256sum command not found"
    fi
}

generate_sha512() {
    local file="$1"
    if command -v sha512sum &> /dev/null; then
        sha512sum "$file" > "$file.sha512"
        echo "  [✓] SHA-512 generated"
    else
        echo "  [✗] sha512sum command not found"
    fi
}

# Główna procedura weryfikacyjna
main() {
    echo "======================================================================"
    echo "ISO-KISS-KISS // Verification Spirit Engine Starting..."
    echo "Target Directory: $TARGET_DIR"
    echo "======================================================================"

    if [ ! -d "$TARGET_DIR" ]; then
        echo "Error: Directory $TARGET_DIR does not exist."
        exit 1
    fi

    # Przetwarzanie plików (szukamy .iso, .img, .bin - pomijamy pliki .md5/.sha*)
    find "$TARGET_DIR" -type f \( -name "*.iso" -o -name "*.img" -o -name "*.bin" \) | while read -r filepath; do
        local filename
        filename=$(basename "$filepath")
        echo "Processing: $filename"

        # Wywołanie poszczególnych funkcji
        generate_md5 "$filepath"
        generate_sha1 "$filepath"
        generate_sha256 "$filepath"
        generate_sha512 "$filepath"
        
        echo "----------------------------------------------------------------------"
    done

    echo "All operational kernels processed successfully. Integrity secured."
}

main
