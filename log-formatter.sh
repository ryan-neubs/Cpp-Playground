#!/bin/bash
###################################################################################
# This script is for formatting and coloring the log output of a script
# It is intended to be sourced by other scripts to provide a consistent log format
###################################################################################

# Only emit color codes when writing to a real terminal
if [[ -t 1 ]]; then
    _BLUE='\033[1;34m'
    _YELLOW='\033[1;33m'
    _RED='\033[1;31m'
    _GREEN='\033[1;32m'
    _MAGENTA='\033[1;35m'
    _CYAN='\033[1;36m'
    _RESET='\033[0m'
else
    _BLUE='' _YELLOW='' _RED='' _GREEN='' _MAGENTA='' _CYAN='' _RESET=''
fi

# Stderr gets its own TTY check (file descriptor 2)
if [[ -t 2 ]]; then
    _ERR_RED='\033[1;31m'
    _ERR_MAGENTA='\033[1;35m'
    _ERR_RESET='\033[0m'
else
    _ERR_RED='' _ERR_MAGENTA='' _ERR_RESET=''
fi

log_info()         { echo -e "${_BLUE}[INFO]:${_RESET} $1"; }
log_warning()      { echo -e "${_YELLOW}[WARNING]:${_RESET} $1"; }
log_error()        { echo -e "${_ERR_RED}[ERROR]:${_ERR_RESET} $1" >&2; }
log_success()      { echo -e "${_GREEN}[SUCCESS]:${_RESET} $1"; }
log_alert()        { echo -e "${_ERR_MAGENTA}[ALERT]:${_ERR_RESET} $1" >&2; }

# Use log_task_begin/end around blocks of work to get "...<task>...Done/Failed" output
log_task_begin()   { echo -en "${_BLUE}[TASK]:${_RESET} $1"; }
log_task_end()     { echo -e "${_GREEN}Done${_RESET}"; }
log_task_failed()  { echo -e "${_ERR_RED}Failed${_ERR_RESET}" >&2; }

prompt_input() {
    local prompt="${_CYAN}[INPUT]:${_RESET} $1"
    if [[ -n "$2" ]]; then
        read -rp $'\033[1;36m[INPUT]:\033[0m '"$1" "$2"
    else
        read -rp $'\033[1;36m[INPUT]:\033[0m '"$1"
    fi
}