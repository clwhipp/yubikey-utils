#!/usr/bin/env bash

set -euo pipefail

# === Configuration ===
YUBIKEY_SLOT=2                     # YubiKey HMAC-SHA1 slot
CHAL_HASH_ALGO=sha1sum            # Hashing for challenge (must match enrollment)
KEYSLOT_OPTION=""                 # Optional: set a specific keyslot to add into

# === Functions ===

usage() {
    echo "Usage: $0 <command> <device>"
    echo
    echo "Commands:"
    echo "  enroll      Add YubiKey-derived password to LUKS keyslot"
    echo "  unenroll    Remove YubiKey-derived password from LUKS keyslot"
    echo "  unlock      Output the YubiKey-derived password"
    echo "  status      Check if derived password matches a keyslot"
    echo
    echo "Example:"
    echo "  $0 enroll /dev/sdX1"
    exit 1
}

get_luks_uuid() {
    local device="$1"
    cryptsetup luksUUID "$device"
}

generate_challenge_response() {
    local challenge="$1"
    local hashed
    hashed=$(echo -n "$challenge" | $CHAL_HASH_ALGO | awk '{print $1}')
    ykchalresp -$YUBIKEY_SLOT "$hashed"
}

enroll() {
    local device="$1"
    echo "🔑 Enter existing LUKS passphrase to authenticate:"
    read -rs EXISTING_PASSPHRASE

    local uuid
    uuid=$(get_luks_uuid "$device")
    echo "🧩 Using LUKS UUID as challenge: $uuid"

    local new_pass
    new_pass=$(generate_challenge_response "$uuid")

    echo -e "$EXISTING_PASSPHRASE\n$new_pass" | cryptsetup luksAddKey "$device" $KEYSLOT_OPTION
    echo "✅ Enrolled YubiKey-derived password into LUKS device $device"
}

unenroll() {
    local device="$1"
    local uuid
    uuid=$(get_luks_uuid "$device")

    echo "🧩 Using LUKS UUID as challenge: $uuid"
    local yk_pass
    yk_pass=$(generate_challenge_response "$uuid")

    echo "$yk_pass" | cryptsetup luksKillSlot "$device" -
    echo "✅ Removed YubiKey-derived password from LUKS device $device"
}

unlock() {
    local device="$1"
    local uuid
    uuid=$(get_luks_uuid "$device")

    local yk_pass
    yk_pass=$(generate_challenge_response "$uuid")
    echo "$yk_pass"
}

status() {
    local device="$1"
    local uuid
    uuid=$(get_luks_uuid "$device")

    local yk_pass
    yk_pass=$(generate_challenge_response "$uuid")

    if echo "$yk_pass" | cryptsetup open --test-passphrase "$device" --key-file=- 2>/dev/null; then
        echo "✅ YubiKey-derived password matches a keyslot on $device"
    else
        echo "❌ YubiKey-derived password does not match any keyslot on $device"
    fi
}

# === Entry Point ===

COMMAND="${1:-}"
DEVICE="${2:-}"

if [[ -z "$COMMAND" || -z "$DEVICE" ]]; then
    usage
fi

if ! cryptsetup isLuks "$DEVICE"; then
    echo "❌ $DEVICE is not a valid LUKS device."
    exit 1
fi

case "$COMMAND" in
    enroll) enroll "$DEVICE" ;;
    unenroll) unenroll "$DEVICE" ;;
    unlock) unlock "$DEVICE" ;;
    status) status "$DEVICE" ;;
    *) usage ;;
esac
