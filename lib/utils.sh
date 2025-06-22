#!/usr/bin/env bash
# Utility functions for Bun buildpack

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
  echo -e "${BLUE}       $*${NC}"
}

log_warning() {
  echo -e "${YELLOW}       WARNING: $*${NC}"
}

log_error() {
  echo -e "${RED}       ERROR: $*${NC}" >&2
}

log_success() {
  echo -e "${GREEN}       $*${NC}"
}

# Print header with arrow
header() {
  echo "-----> $*"
}

# Indent output
indent() {
  sed -u 's/^/       /'
}

# Get CPU architecture for the current platform
get_cpu_architecture() {
  local arch
  arch=$(uname -m)

  case "$arch" in
    x86_64|amd64)
      echo "x64"
      ;;
    aarch64|arm64)
      echo "aarch64"
      ;;
    *)
      log_error "Unsupported architecture: $arch"
      exit 1
      ;;
  esac
}

# Get OS type
get_os_type() {
  local os
  os=$(uname -s)

  case "$os" in
    Linux)
      echo "linux"
      ;;
    Darwin)
      echo "darwin"
      ;;
    *)
      log_error "Unsupported OS: $os"
      exit 1
      ;;
  esac
}

# Check if we need baseline build (for older CPUs)
needs_baseline_build() {
  local cpu_flags="/proc/cpuinfo"

  # Only relevant for Linux x64
  if [[ "$(get_os_type)" != "linux" ]] || [[ "$(get_cpu_architecture)" != "x64" ]]; then
    echo "false"
    return
  fi

  # Check if we have the required CPU features for the optimized build
  if [ -f "$cpu_flags" ]; then
    if grep -q "avx2" "$cpu_flags" && grep -q "avx" "$cpu_flags"; then
      echo "false"  # We can use the optimized build
    else
      echo "true"   # We need the baseline build
    fi
  else
    # If we can't determine, use baseline to be safe
    echo "true"
  fi
}

# Check if we need musl build (for Alpine/musl-based containers)
needs_musl_build() {
  # Check if we're on a musl-based system
  if [ -f "/etc/alpine-release" ]; then
    echo "true"
    return
  fi

  # Check ldd version to see if it's musl
  if command -v ldd >/dev/null 2>&1; then
    if ldd --version 2>&1 | grep -q "musl"; then
      echo "true"
      return
    fi
  fi

  # Check if musl is in the libc
  if [ -f "/lib/libc.musl-x86_64.so.1" ] || [ -f "/lib/ld-musl-x86_64.so.1" ]; then
    echo "true"
    return
  fi

  echo "false"
}

# Generate Bun download URL based on version and platform
generate_bun_download_url() {
  local version="$1"
  local os_type arch baseline musl

  os_type=$(get_os_type)
  arch=$(get_cpu_architecture)
  baseline=$(needs_baseline_build)
  musl=$(needs_musl_build)

  # Ensure version starts with 'v' if it doesn't already
  if [[ ! "$version" =~ ^v ]]; then
    version="v${version}"
  fi

  # Build the filename
  local filename="bun-${os_type}-${arch}"

  # Add musl suffix if needed (only for Linux)
  if [[ "$os_type" == "linux" && "$musl" == "true" ]]; then
    filename="${filename}-musl"
  fi

  # Add baseline suffix if needed
  if [[ "$baseline" == "true" ]]; then
    filename="${filename}-baseline"
  fi

  filename="${filename}.zip"

  # Generate the full URL
  echo "https://github.com/oven-sh/bun/releases/download/bun-${version}/${filename}"
}

# Verify downloaded file integrity (if SHASUMS are available)
verify_download_integrity() {
  local file_path="$1"
  local version="$2"

  # Download SHASUMS file
  local shasums_url="https://github.com/oven-sh/bun/releases/download/bun-${version}/SHASUMS256.txt"
  local shasums_file="/tmp/SHASUMS256.txt"

  if curl -fsSL "$shasums_url" -o "$shasums_file" 2>/dev/null; then
    local filename=$(basename "$file_path")
    local expected_sha=$(grep "$filename" "$shasums_file" 2>/dev/null | cut -d' ' -f1)

    if [ -n "$expected_sha" ]; then
      local actual_sha
      if command -v sha256sum >/dev/null 2>&1; then
        actual_sha=$(sha256sum "$file_path" | cut -d' ' -f1)
      elif command -v shasum >/dev/null 2>&1; then
        actual_sha=$(shasum -a 256 "$file_path" | cut -d' ' -f1)
      else
        log_warning "No SHA256 utility found, skipping integrity check"
        rm -f "$shasums_file"
        return 0
      fi

      if [ "$expected_sha" = "$actual_sha" ]; then
        log_success "Download integrity verified"
        rm -f "$shasums_file"
        return 0
      else
        log_error "Download integrity check failed!"
        log_error "Expected: $expected_sha"
        log_error "Actual:   $actual_sha"
        rm -f "$shasums_file"
        return 1
      fi
    else
      log_warning "Could not find SHA256 for $filename in SHASUMS file"
    fi
    rm -f "$shasums_file"
  else
    log_warning "Could not download SHASUMS file for verification"
  fi

  return 0
}

# Download and extract Bun
download_and_extract_bun() {
  local version="$1"
  local install_dir="$2"
  local cache_dir="$3"

  local download_url
  download_url=$(generate_bun_download_url "$version")

  local filename=$(basename "$download_url")
  local cache_file="${cache_dir}/${filename}"
  local extract_dir="${cache_dir}/bun-extract"

  header "Downloading Bun $version"
  log_info "URL: $download_url"

  # Create cache directory if it doesn't exist
  mkdir -p "$cache_dir"

  # Download with retries
  local max_retries=3
  local retry=0

  while [ $retry -lt $max_retries ]; do
    if curl -fsSL --retry 3 --retry-connrefused "$download_url" -o "$cache_file"; then
      break
    else
      retry=$((retry + 1))
      if [ $retry -lt $max_retries ]; then
        log_warning "Download failed, retrying ($retry/$max_retries)..."
        sleep 2
      else
        log_error "Failed to download Bun after $max_retries attempts"
        return 1
      fi
    fi
  done

  # Verify download integrity
  if ! verify_download_integrity "$cache_file" "$version"; then
    log_error "Download verification failed"
    return 1
  fi

  header "Extracting Bun"

  # Clean and create extract directory
  rm -rf "$extract_dir"
  mkdir -p "$extract_dir"

  # Extract the zip file
  if command -v unzip >/dev/null 2>&1; then
    unzip -q "$cache_file" -d "$extract_dir"
  else
    log_error "unzip command not found. Please install unzip."
    return 1
  fi

  # Find the bun binary and move it to install directory
  local bun_binary
  bun_binary=$(find "$extract_dir" -name "bun" -type f | head -1)

  if [ -z "$bun_binary" ]; then
    log_error "Could not find bun binary in extracted files"
    return 1
  fi

  # Create install directory and copy binary
  mkdir -p "$install_dir"
  cp "$bun_binary" "$install_dir/bun"
  chmod +x "$install_dir/bun"

  # Clean up
  rm -rf "$extract_dir"

  log_success "Bun $version installed successfully"
  return 0
}

# Get the latest Bun version from GitHub API
get_latest_bun_version() {
  local api_url="https://api.github.com/repos/oven-sh/bun/releases/latest"

  if command -v curl >/dev/null 2>&1; then
    # Try to get version from GitHub API
    local latest_version
    latest_version=$(curl -fsSL "$api_url" 2>/dev/null | grep '"tag_name"' | sed 's/.*"tag_name": *"bun-v*\([^"]*\)".*/\1/' | head -1)

    if [ -n "$latest_version" ]; then
      echo "$latest_version"
      return 0
    fi
  fi

  # Fallback to a known stable version
  echo "1.2.17"
}

# Normalize version string (remove 'v' prefix, handle latest)
normalize_version() {
  local version="$1"

  if [ -z "$version" ] || [ "$version" = "latest" ]; then
    get_latest_bun_version
    return
  fi

  # Remove 'v' prefix if present
  version=${version#v}

  echo "$version"
}

# Check if a version string is valid
is_valid_version() {
  local version="$1"

  # Basic version pattern check (e.g., 1.2.3, 1.2.3-beta.1)
  if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$ ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# Create .profile.d script for runtime environment
create_profile_script() {
  local profile_dir="$1"
  local bun_install_dir="$2"

  mkdir -p "$profile_dir"

  cat > "$profile_dir/bun.sh" << EOF
# Add Bun to PATH
export PATH="\$HOME/.heroku/bin:\$PATH"

# Set Bun environment variables
export BUN_INSTALL="\$HOME/.heroku"
export BUN_INSTALL_BIN="\$BUN_INSTALL/bin"

# Ensure Bun cache directory exists
if [ ! -d "\$HOME/.bun" ]; then
  mkdir -p "\$HOME/.bun"
fi
EOF

  log_success "Created runtime profile script"
}

# Export environment variables for subsequent buildpacks
export_env_vars() {
  local export_file="$1"
  local bun_install_dir="$2"

  cat > "$export_file" << EOF
export PATH="$bun_install_dir:\$PATH"
export BUN_INSTALL="$(dirname "$bun_install_dir")"
export BUN_INSTALL_BIN="$bun_install_dir"
EOF

  log_success "Exported environment variables for subsequent buildpacks"
}

# Check available disk space
check_disk_space() {
  local required_mb="$1"
  local path="$2"

  if command -v df >/dev/null 2>&1; then
    local available_kb
    available_kb=$(df "$path" | awk 'NR==2 {print $4}')
    local available_mb=$((available_kb / 1024))

    if [ "$available_mb" -lt "$required_mb" ]; then
      log_error "Insufficient disk space. Required: ${required_mb}MB, Available: ${available_mb}MB"
      return 1
    fi
  fi

  return 0
}

# Measure and display timing
time_measure() {
  local start_time="$1"
  local end_time
  end_time=$(date +%s)
  local duration=$((end_time - start_time))

  if [ "$duration" -gt 60 ]; then
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    echo "${minutes}m ${seconds}s"
  else
    echo "${duration}s"
  fi
}
