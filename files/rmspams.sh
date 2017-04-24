#!/bin/ksh
#
# Copyright (c) 2017 Wesley MOUEDINE ASSABY <milo974@gmail.com>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

set -e

# ------------------------------------------------------------------------------
# DO NOT EDIT THIS FILE!!! 
# User defined variables: overrides are read from /etc/rmspams.conf
# ------------------------------------------------------------------------------

MAILDIR_PATH=/var/mailserver/mail
WHITE_LIST=/etc/mail/whitesmtp

# ------------------------------------------------------------------------------
# End of user defined variables
# ------------------------------------------------------------------------------

err()
{
  echo "${1}" >&2 && return "${2:-1}"
}

usage()
{
  err "Usage: ${0##*/} [-dnv] email"
}

parse_config_file()
{
  local _var _value

  if [[ -f ${_CONFIG} ]]; then
    while IFS="=" read -r -- _var _value ; do
      [[ ${_var} == "MAILDIR_PATH" ]] && MAILDIR_PATH=${_value}
      [[ ${_var} == "WHITE_LIST" ]] && WHITE_LIST=${_value}
    done < "${_CONFIG}"
  fi
  readonly MAILDIR_PATH WHITE_LIST
}

check_white_list_perm()
{
  if [[ -f ${WHITE_LIST} ]]; then
    if [[ $(stat -f "%SMp%SLp" "${WHITE_LIST}") != "------" ]]; then
      err "Unsecure permissions on ${WHITE_LIST}; please run:\ndoas chmod 0600 ${WHITE_LIST}"
    fi
  else
    err "${WHITE_LIST} missing"
  fi
}

check_packet_filter()
{
  PF_TABLE=blacksmtp
  PF_TABLE_FILE=/var/db/rmspams/blacksmtp

  /sbin/pfctl -qt ${PF_TABLE} -T add
  if [[ ! -f ${PF_TABLE_FILE} ]]; then
    mkdir -p /var/db/rmspams
    touch ${PF_TABLE_FILE}
    chmod 0600 ${PF_TABLE_FILE}
  fi

  local _nbf _nbt

  _nbf=$( (wc -l) < ${PF_TABLE_FILE} )
  _nbt=$(/sbin/pfctl -qt${PF_TABLE} -Tshow | wc -l)

  (("${_nbf}" != "${_nbt}")) && err "Inconsistency between table and file"
}

build_full_dir()
{
  local _domainf _userf _spamf

  _domainf=${_EMAIL#*@}
  _userf=${_EMAIL%@*}
  _spamf=".Spam/cur"

  if [[ ${MAILDIR_PATH} == "/" ]]; then
    _FULL_DIR="/${_domainf}/${_userf}/${_spamf}"
  else
    _FULL_DIR="${MAILDIR_PATH}/${_domainf}/${_userf}/${_spamf}"
  fi

  [[ ! -d ${_FULL_DIR} ]] && err "${_FULL_DIR} doesn't exist"
  [ "$(find "${_FULL_DIR}" -mindepth 1)" ] || exit 0
}

fetchip()
{
  _IP=$(sed -En "/^Received: from.*\[/{ s/.*\[//; s/\].*//p; q; }" "${1}")
  _REST=$((_REST-1))
}

resolveip()
{
  local _private
  _private="(^192\.168)|(^10\.)|(^172\.1[6-9])|(^172\.2[0-9])|(^172\.3[0-1])|(^local$)"

  if (echo "${_IP}" | grep -Eq "${_private}"); then
    _NAME='private.'
  else
    _NAME=$(nslookup -query=a "$1" | sed -n '/name/{ s/.*\=[[:blank:]]//p; }')
  fi

  [[ -z ${_NAME} ]] && _NAME='unknown.' 

  verbose "${_IP} = ${_NAME} -- remaining: ${_REST} \c"

  if (! echo "${_NAME}" | grep -Eq "(^private)|(^localhost)|(^unknown)\.$"); then
    check_white_list
  else
    verbose "(r)"
    removeitem
  fi
}

find_ip_in_table()
{
  if [[ -f ${_F} ]]; then
    if (/sbin/pfctl -qt"${PF_TABLE}" -Ttest "${_IP}"); then
      verbose "(b)"
      removeitem
    else
      add_to_pf
    fi
  fi
}

check_white_list()
{
  local _whitedns _findw

  if [[ ! -s ${WHITE_LIST} ]]; then
    find_ip_in_table
  else
    while read -r -- _whitedns ; do
    if (echo ${_NAME} | grep -q "${_whitedns}\.$"); then
      verbose "(w)"
      removeitem
      readonly _findw=1
      break
    fi
  done < "${WHITE_LIST}"
  [[ -z ${_findw} ]] && find_ip_in_table
  fi
}

add_to_pf()
{
  verbose "(a)"
  if [ ! "${_REMOVE}" ]; then
    echo "${_IP}" >> ${PF_TABLE_FILE}
    /sbin/pfctl -qt ${PF_TABLE} -T add "${_IP}"
    removeitem
  fi
}

verbose()
{
  [[ -n ${_VERBOSE} ]] && echo "${1}"
}

removeitem()
{
  [[ ! -n ${_REMOVE} ]] && rm -f "${_F}"
}

while getopts :dnv opt; do
  case ${opt} in
  d) set -x;;
  n) readonly _REMOVE=0;;
  v) readonly _VERBOSE=0;;
  *) usage;;
  esac
done
shift $((OPTIND - 1))
(($# != 1)) && usage

readonly _EMAIL=$1 _CONFIG=/etc/mail/rmspams.conf

(! echo "${_EMAIL}" | grep -q '^[a-zA-Z0-9._%+-]*@[a-zA-Z0-9]*[\.[a-zA-Z0-9-]*]*[a-zA-Z0-9]$') \
  && err "${0##*/}: bad recipient address"

(($(id -u) != 0)) && err "${0##*/}: need root privileges"

parse_config_file
check_white_list_perm
check_packet_filter
build_full_dir

_REST=$(find "${_FULL_DIR}" -maxdepth 1 -type f | wc -l)

for _F in ${_FULL_DIR}/* ; do
  fetchip "${_F}"
  resolveip "${_IP}"
done

exit 0