#
# bash completion for hpc-workspace
#
# Copyright(c) 2020      Christoph Niethammer
#
#
# Note: Currently only the ws_find command takes a provided filesystems into
#       account when completing workspace names.
#
#
# bash completion for hpc-workspace is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# bash completion for hpc-workspaceis is distributed in the hope that it will
# be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# bash completion for hpc-workspace.  If not, see <http://www.gnu.org/licenses/>.
#



function _ws_filesystem_list() {
    local file_systems="$(ws_list -l | tail -n +2 | cut -f 1 -d ' ')"
    printf "%s" "$file_systems"
}

function _ws_workspace_list() {
    local file_system="$1"
    if [ "$file_system" != "" ] ; then
        ws_names="$(ws_list -F "$file_system" -s 2>/dev/null)"
    else
        ws_names="$(ws_list -s)"
    fi
    printf "%s" "$ws_names"
}

# ws_find completion
function _complete_ws_find() {
    case "${COMP_WORDS[$COMP_CWORD]}" in
        -*)
            [[ "$COMP_CWORD" != "1" ]] && return
            COMPREPLY=($(compgen -W "-F --filesystem -h -l --list" -- "${COMP_WORDS[$COMP_CWORD]}"))
            ;;
        *)
            if [[ "${COMP_WORDS[1]}" == "-F" || "${COMP_WORDS[1]}" == "--filesystem" ]] ; then
                file_system="${COMP_WORDS[2]}"
            fi
            case "${COMP_WORDS[$COMP_CWORD - 1]}" in
                -F|--filesystem)
                    local file_systems="$(_ws_filesystem_list)"
                    COMPREPLY=($(compgen -W "$file_systems" -- "${COMP_WORDS[$COMP_CWORD]}"))
                    ;;
                *)
                    [[ ! ("$COMP_CWORD" == "1" || ("$file_system" != "" && "$COMP_CWORD" == "3")) ]] && return
                    local ws_names=$(_ws_workspace_list "$file_system")
                    COMPREPLY=($(compgen -W "$ws_names" -- "${COMP_WORDS[$COMP_CWORD]}"))
                    ;;
            esac
    esac
}
complete -F _complete_ws_find ws_find


# ws_list completion
function _complete_ws_list() {
    case "${COMP_WORDS[$COMP_CWORD - 1]}" in
        -F|--filesystem)
            local file_systems="$(_ws_filesystem_list)"
            COMPREPLY=($(compgen -W "$file_systems" -- "${COMP_WORDS[$COMP_CWORD]}"))
            ;;
        *)
            COMPREPLY=($(compgen -W "-a -C -F --filesystem -g -h -l -N -r -R -s -t -v" -- "${COMP_WORDS[$COMP_CWORD]}"))
            ;;
    esac
}
complete -F _complete_ws_list ws_list


# ws_extend completion with available workspace names
function _complete_ws_extend() {
    COMPREPLY=($(compgen -W "$(ws_list -s)" -- "${COMP_WORDS[$COMP_CWORD]}"))
}
complete -F _complete_ws_extend ws_extend


# ws_release completion with available workspace names
function _complete_ws_release() {
    COMPREPLY=($(compgen -W "$(ws_list -s)" -- "${COMP_WORDS[$COMP_CWORD]}"))
}
complete -F _complete_ws_release ws_release

