# Internal variable for checking if prompt is opened
spaceship_prompt_opened="$SPACESHIP_PROMPT_FIRST_PREFIX_SHOW"

# Draw prompt section (bold is used as default)
# USAGE:
#   spaceship::section <color> [prefix] <content> [suffix]
spaceship::section() {
  local color prefix content suffix prefix_color suffix_color
  [[ -n $1 ]] && color="%F{$1}"         || color="%f"
  [[ -n $2 ]] && prefix="$2"            || prefix=""
  [[ -n $3 ]] && content="$3"           || content=""
  [[ -n $4 ]] && suffix="$4"            || suffix=""
  [[ -n $5 ]] && prefix_color="%F{$5}"  || prefix_color="%f"
  [[ -n $6 ]] && suffix_color="%F{$6}"  || suffix_color="%f"

  [[ -z $3 && -z $4 ]] && content=$2 prefix=''

  echo -n "%{%B%}" # set bold
  if [[ $spaceship_prompt_opened == true ]] && [[ $SPACESHIP_PROMPT_PREFIXES_SHOW == true ]]; then
    echo -n "%{%B$prefix_color%}" # set color
    echo -n "$prefix"
    echo -n "%{%b%f%}"     # unset color
  fi
  spaceship_prompt_opened=true
  echo -n "%{%b%}" # unset bold

  echo -n "%{%B$color%}" # set color
  echo -n "$content"     # section content
  echo -n "%{%b%f%}"     # unset color

  echo -n "%{%B%}" # reset bold, if it was diabled before
  if [[ $SPACESHIP_PROMPT_SUFFIXES_SHOW == true ]]; then
    echo -n "%{%B$suffix_color%}" # set color
    echo -n "$suffix"
    echo -n "%{%b%f%}"     # unset color
  fi
  echo -n "%{%b%}" # unset bold
}

# Asynchronously load all prompt sections
# USAGE:
#   spaceship::async_load_prompt [section...]
spaceship::async_load_prompt() {
  # Treat the first argument as list of prompt sections
  # Load sections asynchronously if they provide such API.
  for section in $@; do
    if spaceship::defined "spaceship_async_job_load_$section"; then
      "spaceship_async_job_load_$section"
    fi
  done
}

# Compose whole prompt from sections
# USAGE:
#   spaceship::compose_prompt [section...]
spaceship::compose_prompt() {
  # Option EXTENDED_GLOB is set locally to force filename generation on
  # argument to conditions, i.e. allow usage of explicit glob qualifier (#q).
  # See the description of filename generation in
  # http://zsh.sourceforge.net/Doc/Release/Conditional-Expressions.html
  setopt EXTENDED_GLOB LOCAL_OPTIONS

  # Treat the first argument as list of prompt sections
  # Compose whole prompt from diferent parts
  # If section is a defined function then invoke it
  # Otherwise render the 'not found' section
  for section in $@; do
    if spaceship::defined "spaceship_$section"; then
      spaceship_$section
    else
      spaceship::section 'red' "'$section' not found"
    fi
  done
}
