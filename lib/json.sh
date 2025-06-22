#!/usr/bin/env bash
# JSON parsing utilities for Bun buildpack

# Check if jq is available, if not provide basic fallback
if ! command -v jq >/dev/null 2>&1; then
  echo "Warning: jq not available, using basic JSON parsing fallbacks" >&2
fi

# Read a JSON value from a file
read_json() {
  local file="$1"
  local key="$2"

  if [ ! -f "$file" ]; then
    echo ""
    return 1
  fi

  if command -v jq >/dev/null 2>&1; then
    # Use jq if available
    jq -r "$key // empty" "$file" 2>/dev/null || echo ""
  else
    # Basic fallback for simple key extraction
    grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$file" 2>/dev/null | \
    sed 's/.*"[^"]*"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | \
    head -1
  fi
}

# Check if a JSON file has a specific key
json_has_key() {
  local file="$1"
  local key="$2"

  if [ ! -f "$file" ]; then
    echo "false"
    return 1
  fi

  if command -v jq >/dev/null 2>&1; then
    jq -e "has(\"$key\")" "$file" >/dev/null 2>&1 && echo "true" || echo "false"
  else
    # Basic fallback
    if grep -q "\"$key\"" "$file" 2>/dev/null; then
      echo "true"
    else
      echo "false"
    fi
  fi
}

# Check if package.json has a specific script
has_script() {
  local file="$1"
  local script_name="$2"

  if [ ! -f "$file" ]; then
    echo "false"
    return 1
  fi

  if command -v jq >/dev/null 2>&1; then
    jq -e ".scripts.\"$script_name\"" "$file" >/dev/null 2>&1 && echo "true" || echo "false"
  else
    # Basic fallback - look for script in scripts section
    if grep -A 20 '"scripts"' "$file" 2>/dev/null | grep -q "\"$script_name\""; then
      echo "true"
    else
      echo "false"
    fi
  fi
}

# Get the value of a script from package.json
get_script() {
  local file="$1"
  local script_name="$2"

  if [ ! -f "$file" ]; then
    echo ""
    return 1
  fi

  if command -v jq >/dev/null 2>&1; then
    jq -r ".scripts.\"$script_name\" // empty" "$file" 2>/dev/null
  else
    # Basic fallback
    grep -A 20 '"scripts"' "$file" 2>/dev/null | \
    grep "\"$script_name\"" | \
    sed 's/.*"[^"]*"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | \
    head -1
  fi
}

# Check if JSON file is valid
is_valid_json() {
  local file="$1"

  if [ ! -f "$file" ]; then
    echo "false"
    return 1
  fi

  if command -v jq >/dev/null 2>&1; then
    jq empty "$file" >/dev/null 2>&1 && echo "true" || echo "false"
  else
    # Basic validation - check for balanced braces
    local content=$(cat "$file" 2>/dev/null)
    if [[ "$content" =~ ^\{.*\}$ ]] || [[ "$content" =~ ^\[.*\]$ ]]; then
      echo "true"
    else
      echo "false"
    fi
  fi
}

# Get Bun version from package.json engines
get_bun_version_from_engines() {
  local file="$1"

  if [ ! -f "$file" ]; then
    echo ""
    return 1
  fi

  if command -v jq >/dev/null 2>&1; then
    jq -r ".engines.bun // empty" "$file" 2>/dev/null
  else
    # Basic fallback
    grep -A 10 '"engines"' "$file" 2>/dev/null | \
    grep '"bun"' | \
    sed 's/.*"bun"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | \
    head -1
  fi
}

# Get packageManager from package.json
get_package_manager() {
  local file="$1"

  if [ ! -f "$file" ]; then
    echo ""
    return 1
  fi

  if command -v jq >/dev/null 2>&1; then
    jq -r ".packageManager // empty" "$file" 2>/dev/null
  else
    # Basic fallback
    grep '"packageManager"' "$file" 2>/dev/null | \
    sed 's/.*"packageManager"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | \
    head -1
  fi
}

# Extract Bun version from packageManager field (e.g., "bun@1.2.17")
extract_bun_version_from_package_manager() {
  local package_manager="$1"

  if [[ "$package_manager" =~ ^bun@(.+)$ ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    echo ""
  fi
}

# Check if package.json has workspaces
has_workspaces() {
  local file="$1"

  if [ ! -f "$file" ]; then
    echo "false"
    return 1
  fi

  if command -v jq >/dev/null 2>&1; then
    jq -e ".workspaces" "$file" >/dev/null 2>&1 && echo "true" || echo "false"
  else
    # Basic fallback
    if grep -q '"workspaces"' "$file" 2>/dev/null; then
      echo "true"
    else
      echo "false"
    fi
  fi
}

# Get the name field from package.json
get_package_name() {
  local file="$1"

  if [ ! -f "$file" ]; then
    echo ""
    return 1
  fi

  read_json "$file" ".name"
}

# Get the version field from package.json
get_package_version() {
  local file="$1"

  if [ ! -f "$file" ]; then
    echo ""
    return 1
  fi

  read_json "$file" ".version"
}

# Check if package.json has dependencies
has_dependencies() {
  local file="$1"

  if [ ! -f "$file" ]; then
    echo "false"
    return 1
  fi

  if command -v jq >/dev/null 2>&1; then
    local deps=$(jq -e ".dependencies // {} | keys | length" "$file" 2>/dev/null)
    local dev_deps=$(jq -e ".devDependencies // {} | keys | length" "$file" 2>/dev/null)

    if [[ "$deps" -gt 0 ]] || [[ "$dev_deps" -gt 0 ]]; then
      echo "true"
    else
      echo "false"
    fi
  else
    # Basic fallback
    if grep -q '"dependencies"' "$file" 2>/dev/null || grep -q '"devDependencies"' "$file" 2>/dev/null; then
      echo "true"
    else
      echo "false"
    fi
  fi
}
