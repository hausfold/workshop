if [ -z "$UI_READY" ]; then
  declare -ga UI__TC_HEAD=() UI__TROWS=()
  ui_col()  { UI__TC_HEAD+=("${1-}"); }
  # No palette to name, so a per-row role is the text alone.
  ui_cell() { printf -v "$1" '%s' "$3"; }
  ui_trow() { local IFS=$'\t'; UI__TROWS+=("$*"); }
  ui_table_clear() { UI__TC_HEAD=(); UI__TROWS=(); }
  ui_table_data() { ui__plain_table "" "${1:-2}" "${2:-0}"; }
  ui_table()      { ui__plain_table 1 "${1:-2}" "${2:-0}"; }
  # Split on TAB keeping EMPTY fields — not `IFS=$'\t' read -ra`, which collapses
  # a run of tabs and shifts every cell after an empty one a column left. A
  # `dirty` column is empty on a clean repo, so that is the common row here.
  ui__plain_split() {
    local -n __sp="$1"
    local s="$2"$'\t'
    __sp=()
    while [ -n "$s" ]; do __sp+=("${s%%$'\t'*}"); s="${s#*$'\t'}"; done
  }
  # `local IFS` and never a save/restore pair: a caller that has `unset IFS`
  # makes the restore either abort under `set -u` or put back an EMPTY one,
  # which turns word splitting off for the rest of that caller's run.
  ui__plain_heads() { local IFS=$'\t'; printf -v "$1" '%s' "${UI__TC_HEAD[*]}"; }
  ui__plain_table() { # ui__plain_table <to-fd-2> <indent> <header>
    local err="$1" indent="$2" header="$3"
    local -a all=() cells=() cw=()
    local i n line pad head_row
    if [ "${#UI__TC_HEAD[@]}" -eq 0 ] || [ "${#UI__TROWS[@]}" -eq 0 ]; then
      ui_table_clear; return 0
    fi
    for i in "${!UI__TC_HEAD[@]}"; do cw+=("${#UI__TC_HEAD[$i]}"); done
    if [ "$header" = 1 ]; then ui__plain_heads head_row; all+=("$head_row"); fi
    all+=("${UI__TROWS[@]}")
    for n in "${!all[@]}"; do
      ui__plain_split cells "${all[$n]}"
      for i in "${!UI__TC_HEAD[@]}"; do
        [ "$i" -lt "${#cells[@]}" ] || continue
        [ "${#cells[$i]}" -gt "${cw[$i]}" ] && cw[i]="${#cells[$i]}"
      done
    done
    printf -v pad '%*s' "$indent" ''
    for n in "${!all[@]}"; do
      ui__plain_split cells "${all[$n]}"
      line="$pad"
      for i in "${!UI__TC_HEAD[@]}"; do
        local v=""; [ "$i" -lt "${#cells[@]}" ] && v="${cells[$i]}"
        # Never pad the last column: trailing spaces wrap a row that just fit.
        # Padded by CHARACTERS, not printf's bytes — `·` and `└` are one column
        # and two-or-three bytes, and %-*s on either is what sheared every
        # column to its right before this table existed.
        [ "$i" -lt $(( ${#UI__TC_HEAD[@]} - 1 )) ] \
          && printf -v v '%s%*s' "$v" $(( cw[i] - ${#v} > 0 ? cw[i] - ${#v} : 0 )) ''
        if [ "$i" -eq 0 ]; then line+="$v"; else line+=" $v"; fi
      done
      line="${line%"${line##*[! ]}"}"
      if [ -n "$err" ]; then printf '%s\n' "$line" >&2; else printf '%s\n' "$line"; fi
    done
    ui_table_clear
  }
fi

