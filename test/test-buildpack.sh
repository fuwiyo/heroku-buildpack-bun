#!/usr/bin/env bash
# Test script for Heroku Bun Buildpack

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BP_DIR="$(dirname "$SCRIPT_DIR")"
TEST_DIR="$SCRIPT_DIR"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[PASS]${NC} $*"
}

log_error() {
  echo -e "${RED}[FAIL]${NC} $*"
}

log_warning() {
  echo -e "${YELLOW}[WARN]${NC} $*"
}

# Test function wrapper
run_test() {
  local test_name="$1"
  local test_func="$2"

  echo
  echo "======================================"
  echo "Running test: $test_name"
  echo "======================================"

  TESTS_RUN=$((TESTS_RUN + 1))

  if $test_func; then
    log_success "$test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    log_error "$test_name"
    return 1
  fi
}

# Test buildpack structure
test_buildpack_structure() {
  log_info "Checking buildpack structure..."

  # Check required files
  local required_files=(
    "bin/detect"
    "bin/compile"
    "bin/release"
    "lib/json.sh"
    "lib/utils.sh"
    "README.md"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$BP_DIR/$file" ]; then
      log_error "Missing required file: $file"
      return 1
    fi

    if [ ! -x "$BP_DIR/$file" ] && [[ "$file" == bin/* ]]; then
      log_error "File not executable: $file"
      return 1
    fi
  done

  log_info "All required files present and executable"
  return 0
}

# Test detect script
test_detect_script() {
  log_info "Testing detect script..."

  local temp_dir=$(mktemp -d)

  # Test 1: Should detect bun.lock (text-based lockfile)
  mkdir -p "$temp_dir/test1"
  touch "$temp_dir/test1/bun.lock"

  if ! "$BP_DIR/bin/detect" "$temp_dir/test1" >/dev/null 2>&1; then
    log_error "Failed to detect project with bun.lock"
    rm -rf "$temp_dir"
    return 1
  fi

  # Test 1b: Should detect bun.lockb (binary lockfile)
  mkdir -p "$temp_dir/test1b"
  touch "$temp_dir/test1b/bun.lockb"

  if ! "$BP_DIR/bin/detect" "$temp_dir/test1b" >/dev/null 2>&1; then
    log_error "Failed to detect project with bun.lockb"
    rm -rf "$temp_dir"
    return 1
  fi

  # Test 2: Should detect packageManager in package.json
  mkdir -p "$temp_dir/test2"
  cat > "$temp_dir/test2/package.json" << EOF
{
  "name": "test",
  "packageManager": "bun@1.2.17"
}
EOF

  if ! "$BP_DIR/bin/detect" "$temp_dir/test2" >/dev/null 2>&1; then
    log_error "Failed to detect project with packageManager"
    rm -rf "$temp_dir"
    return 1
  fi

  # Test 3: Should detect engines.bun in package.json
  mkdir -p "$temp_dir/test3"
  cat > "$temp_dir/test3/package.json" << EOF
{
  "name": "test",
  "engines": {
    "bun": "^1.2.0"
  }
}
EOF

  if ! "$BP_DIR/bin/detect" "$temp_dir/test3" >/dev/null 2>&1; then
    log_error "Failed to detect project with engines.bun"
    rm -rf "$temp_dir"
    return 1
  fi

  # Test 4: Should detect .bun-version file
  mkdir -p "$temp_dir/test4"
  echo "1.2.17" > "$temp_dir/test4/.bun-version"

  if ! "$BP_DIR/bin/detect" "$temp_dir/test4" >/dev/null 2>&1; then
    log_error "Failed to detect project with .bun-version"
    rm -rf "$temp_dir"
    return 1
  fi

  # Test 5: Should NOT detect regular Node.js project
  mkdir -p "$temp_dir/test5"
  cat > "$temp_dir/test5/package.json" << EOF
{
  "name": "test",
  "scripts": {
    "start": "node index.js"
  }
}
EOF
  touch "$temp_dir/test5/package-lock.json"

  if "$BP_DIR/bin/detect" "$temp_dir/test5" >/dev/null 2>&1; then
    log_error "Incorrectly detected Node.js project as Bun project"
    rm -rf "$temp_dir"
    return 1
  fi

  rm -rf "$temp_dir"
  log_info "Detect script tests passed"
  return 0
}

# Test JSON utilities
test_json_utilities() {
  log_info "Testing JSON utilities..."

  local temp_dir=$(mktemp -d)

  # Create test package.json
  cat > "$temp_dir/package.json" << EOF
{
  "name": "test-package",
  "version": "1.0.0",
  "scripts": {
    "start": "bun run index.ts",
    "build": "bun build index.ts",
    "test": "bun test"
  },
  "engines": {
    "bun": "^1.2.0"
  },
  "packageManager": "bun@1.2.17",
  "workspaces": ["packages/*"]
}
EOF

  source "$BP_DIR/lib/json.sh"

  # Test reading values
  local name=$(read_json "$temp_dir/package.json" ".name")
  if [ "$name" != "test-package" ]; then
    log_error "Failed to read package name: got '$name', expected 'test-package'"
    rm -rf "$temp_dir"
    return 1
  fi

  # Test script detection
  local has_build=$(has_script "$temp_dir/package.json" "build")
  if [ "$has_build" != "true" ]; then
    log_error "Failed to detect build script"
    rm -rf "$temp_dir"
    return 1
  fi

  local has_deploy=$(has_script "$temp_dir/package.json" "deploy")
  if [ "$has_deploy" != "false" ]; then
    log_error "Incorrectly detected non-existent deploy script"
    rm -rf "$temp_dir"
    return 1
  fi

  # Test engine version extraction
  local bun_version=$(get_bun_version_from_engines "$temp_dir/package.json")
  if [ "$bun_version" != "^1.2.0" ]; then
    log_error "Failed to extract Bun version from engines: got '$bun_version'"
    rm -rf "$temp_dir"
    return 1
  fi

  # Test packageManager extraction
  local package_manager=$(get_package_manager "$temp_dir/package.json")
  if [ "$package_manager" != "bun@1.2.17" ]; then
    log_error "Failed to extract packageManager: got '$package_manager'"
    rm -rf "$temp_dir"
    return 1
  fi

  local extracted_version=$(extract_bun_version_from_package_manager "$package_manager")
  if [ "$extracted_version" != "1.2.17" ]; then
    log_error "Failed to extract version from packageManager: got '$extracted_version'"
    rm -rf "$temp_dir"
    return 1
  fi

  # Test workspace detection
  local has_workspaces=$(has_workspaces "$temp_dir/package.json")
  if [ "$has_workspaces" != "true" ]; then
    log_error "Failed to detect workspaces"
    rm -rf "$temp_dir"
    return 1
  fi

  rm -rf "$temp_dir"
  log_info "JSON utilities tests passed"
  return 0
}

# Test utility functions
test_utility_functions() {
  log_info "Testing utility functions..."

  source "$BP_DIR/lib/utils.sh"

  # Test architecture detection
  local arch=$(get_cpu_architecture)
  if [ -z "$arch" ]; then
    log_error "Failed to detect CPU architecture"
    return 1
  fi
  log_info "Detected architecture: $arch"

  # Test OS detection
  local os=$(get_os_type)
  if [ -z "$os" ]; then
    log_error "Failed to detect OS type"
    return 1
  fi
  log_info "Detected OS: $os"

  # Test version normalization
  local version1=$(normalize_version "v1.2.17")
  if [ "$version1" != "1.2.17" ]; then
    log_error "Failed to normalize version with 'v' prefix: got '$version1'"
    return 1
  fi

  local version2=$(normalize_version "1.2.17")
  if [ "$version2" != "1.2.17" ]; then
    log_error "Failed to normalize version without prefix: got '$version2'"
    return 1
  fi

  # Test version validation
  local valid1=$(is_valid_version "1.2.17")
  if [ "$valid1" != "true" ]; then
    log_error "Failed to validate correct version format"
    return 1
  fi

  local valid2=$(is_valid_version "not-a-version")
  if [ "$valid2" != "false" ]; then
    log_error "Failed to reject invalid version format"
    return 1
  fi

  # Test URL generation
  local url=$(generate_bun_download_url "1.2.17")
  if [[ ! "$url" =~ ^https://github\.com/oven-sh/bun/releases/download/bun-v1\.2\.17/bun- ]]; then
    log_error "Generated invalid download URL: $url"
    return 1
  fi
  log_info "Generated URL: $url"

  log_info "Utility functions tests passed"
  return 0
}

# Test release script
test_release_script() {
  log_info "Testing release script..."

  local temp_dir=$(mktemp -d)

  # Test release output
  local output=$("$BP_DIR/bin/release" "$temp_dir")

  if [[ ! "$output" =~ "web: bun start" ]]; then
    log_error "Release script doesn't contain expected default process type"
    rm -rf "$temp_dir"
    return 1
  fi

  if [[ ! "$output" =~ "---" ]]; then
    log_error "Release script doesn't contain YAML header"
    rm -rf "$temp_dir"
    return 1
  fi

  rm -rf "$temp_dir"
  log_info "Release script test passed"
  return 0
}

# Test basic app fixture
test_basic_app_fixture() {
  log_info "Testing basic app fixture..."

  local fixture_dir="$TEST_DIR/fixtures/basic-app"

  if [ ! -d "$fixture_dir" ]; then
    log_error "Basic app fixture directory not found"
    return 1
  fi

  if [ ! -f "$fixture_dir/package.json" ]; then
    log_error "Basic app fixture missing package.json"
    return 1
  fi

  if [ ! -f "$fixture_dir/index.ts" ]; then
    log_error "Basic app fixture missing index.ts"
    return 1
  fi

  # Test that the fixture is detected as a Bun project
  if ! "$BP_DIR/bin/detect" "$fixture_dir" >/dev/null 2>&1; then
    log_error "Basic app fixture not detected as Bun project"
    return 1
  fi

  # Validate package.json
  source "$BP_DIR/lib/json.sh"
  if [ "$(is_valid_json "$fixture_dir/package.json")" != "true" ]; then
    log_error "Basic app fixture has invalid package.json"
    return 1
  fi

  log_info "Basic app fixture test passed"
  return 0
}

# Test compile script (basic validation only - doesn't actually download Bun)
test_compile_script_validation() {
  log_info "Testing compile script validation..."

  # Test that compile script exists and is executable
  if [ ! -x "$BP_DIR/bin/compile" ]; then
    log_error "Compile script is not executable"
    return 1
  fi

  # Test that it fails gracefully with no arguments
  if "$BP_DIR/bin/compile" >/dev/null 2>&1; then
    log_error "Compile script should fail when called without arguments"
    return 1
  fi

  log_info "Compile script validation passed"
  return 0
}

# Main test runner
main() {
  echo "========================================"
  echo "    Heroku Bun Buildpack Test Suite"
  echo "========================================"
  echo

  log_info "Starting buildpack tests..."

  # Run all tests
  run_test "Buildpack Structure" test_buildpack_structure
  run_test "Detect Script" test_detect_script
  run_test "JSON Utilities" test_json_utilities
  run_test "Utility Functions" test_utility_functions
  run_test "Release Script" test_release_script
  run_test "Basic App Fixture" test_basic_app_fixture
  run_test "Compile Script Validation" test_compile_script_validation

  echo
  echo "========================================"
  echo "           Test Results"
  echo "========================================"
  echo

  if [ "$TESTS_PASSED" -eq "$TESTS_RUN" ]; then
    log_success "All tests passed! ($TESTS_PASSED/$TESTS_RUN)"
    echo
    log_info "✅ Your Bun buildpack is ready to use!"
    echo
    echo "To use this buildpack:"
    echo "  1. Push to a Git repository"
    echo "  2. Set as buildpack: heroku buildpacks:set <your-repo-url>"
    echo "  3. Deploy your Bun app!"
    exit 0
  else
    local failed=$((TESTS_RUN - TESTS_PASSED))
    log_error "$failed out of $TESTS_RUN tests failed"
    echo
    log_error "❌ Please fix the issues above before using the buildpack"
    exit 1
  fi
}

# Run tests
main "$@"
