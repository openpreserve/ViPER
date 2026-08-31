#!/bin/bash
# Assert the bundled tools actually work before the image is published.
#
# Runs as a Packer provisioner after Ansible and before cleanup. A release build
# spends hours uploading multi-gigabyte artifacts, so a broken tool needs to fail
# the build here rather than be discovered by a user after the download.
#
# GUI launchers are checked for resolvable targets rather than executed, because
# starting a Swing application on a headless build would hang.

set -uo pipefail

failures=0

pass() { echo "  ok    $1"; }
fail() { echo "  FAIL  $1"; failures=$((failures + 1)); }

# Runs a CLI tool and accepts whatever exit status it chooses for a help or version
# flag. What we care about is that the launcher resolved and the JVM found its jar,
# so we fail on "command not found" and on the classic missing-jar stack traces.
check_runs() {
  local label="$1"
  shift
  local output status
  output=$("$@" 2>&1)
  status=$?

  if [ "${status}" -eq 127 ]; then
    fail "${label}: command not found"
    return
  fi
  if printf '%s' "${output}" | grep -qE 'Unable to access jarfile|ClassNotFoundException|NoClassDefFoundError|No such file or directory'; then
    fail "${label}: launcher ran but could not load its application"
    printf '%s\n' "${output}" | head -5 | sed 's/^/          /'
    return
  fi
  pass "${label}"
}

check_resolves() {
  local label="$1" path="$2"
  if [ ! -e "${path}" ]; then
    fail "${label}: ${path} is missing"
  elif [ ! -x "${path}" ]; then
    fail "${label}: ${path} is not executable"
  elif ! readlink -e "${path}" >/dev/null; then
    fail "${label}: ${path} is a dangling symlink"
  else
    pass "${label}"
  fi
}

check_exists() {
  local label="$1" path="$2"
  if [ -e "${path}" ]; then
    pass "${label}"
  else
    fail "${label}: ${path} is missing"
  fi
}

echo "==> Java runtime"
check_runs "java" java -version

echo "==> Command line tools"
check_runs "jhove" /usr/local/bin/jhove -h
check_runs "verapdf" /usr/local/bin/verapdf --version

echo "==> GUI launchers resolve"
check_resolves "jhove-gui" /usr/local/bin/jhove-gui
check_resolves "droid-gui" /usr/local/bin/droid-gui
check_resolves "tika-gui" /usr/local/bin/tika-gui
check_resolves "verapdf-gui" /usr/local/bin/verapdf-gui

echo "==> Desktop entries"
for tool in jhove droid tika verapdf; do
  check_exists "${tool}.desktop" "/usr/share/applications/${tool}.desktop"
done
for tool in org.gnome.Evince gimp org.inkscape.Inkscape mediainfo-gui mediaconch-gui fr.handbrake.ghb; do
  check_exists "${tool}.desktop" "/usr/share/applications/${tool}.desktop"
done

echo "==> Tool manifest"
check_exists "manifest" /usr/local/share/viper/manifest.json

# The viper account is the only way to root on the shipped appliance: the build
# account is locked during cleanup and root has no password. That rests on Debian
# shipping nullok in common-auth, so prove it here rather than discover it after
# the image is published. -k clears any cached credentials so the password path is
# genuinely exercised.
echo "==> Administrative access"
if sudo -u viper -- sh -c 'echo "" | sudo -S -k true' >/dev/null 2>&1; then
  pass "viper can obtain root via sudo"
else
  fail "viper cannot obtain root: the appliance would ship with no admin path"
fi

echo
if [ "${failures}" -gt 0 ]; then
  echo "Smoke test FAILED with ${failures} problem(s). Not publishing this image."
  exit 1
fi
echo "Smoke test passed."
