RBENV_TEST_DIR="${BATS_TMPDIR}/rbenv"
export RBENV_ROOT="${RBENV_TEST_DIR}/root"
export HOME="${RBENV_TEST_DIR}/home"

unset RBENV_VERSION
unset RBENV_DIR

export PATH="${RBENV_TEST_DIR}/bin:$PATH"
export PATH="${BATS_TEST_DIRNAME}/../libexec:$PATH"
export PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
export PATH="${RBENV_ROOT}/shims:$PATH"

teardown() {
  rm -rf "$RBENV_TEST_DIR"
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed "s:${RBENV_TEST_DIR}:TEST_DIR:" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
  elif [ "$#" -gt 0 ]; then
    assert_output_lines "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status"
  elif [ "$#" -gt 0 ]; then
    assert_output_lines "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_output() {
  assert_equal "$1" "$output"
}

# compares lines with leading whitespace trimmed
assert_output_lines() {
  local -a expected
  IFS=$'\n' expected=($1)
  for (( i=0; i < ${#expected[@]}; i++ )); do
    local wants="${expected[$i]}"
    local got="${lines[$i]}"
    assert_equal \
      "${wants#"${wants%%[![:space:]]*}"}" \
      "${got#"${got%%[![:space:]]*}"}"
  done
  assert_equal "${expected[$i]}" "${lines[$i]}"
}

assert_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    assert_equal "$2" "${lines[$1]}"
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then return 0; fi
    done
    flunk "expected line \`$1'"
  fi
}

refute_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    local num_lines="${#lines[@]}"
    if [ "$1" -lt "$num_lines" ]; then
      flunk "output has $num_lines lines"
    fi
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then
        flunk "expected to not find line \`$line'"
      fi
    done
  fi
}

assert() {
  if ! "$@"; then
    flunk "failed: $@"
  fi
}
