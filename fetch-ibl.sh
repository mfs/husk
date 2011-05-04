#!/bin/bash

# Copyright (C) 2010 Phillip Smith
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Part of this script is based on the 'iptables-apply' script written
# by Martin F. Krafft <madduck@madduck.net> and distributed under the
# Artistic Licence 2.0

function usage() {
	echo "$0 ibl-list-name"
}

# Used as the base uri for fetching iblocklist lists
URI_BASE='http://list.iblocklist.com/?list=bt_%s'
LIB_DIR='/var/lib/husk'

if [ $EUID -ne 0 ] ; then
	echo "You are using a non-privileged account"
	exit 1
fi

trap "rm -f $TFILE; rm -f $CFILE;" EXIT 1 2 3 4 5 6 7 8 10 11 12 13 14 15

# Check we've got all our dependencies
export PATH='/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'
for ebin in wget gzip mktemp mv awk ; do
	[[ -z "$(which $ebin 2>/dev/null)" ]] && { echo "Could not locate '$ebin'" >&2; exit 1; }
done
CFILE=$(mktemp -t fetch-ibl.XXX)

# Make sure we have cmd line arg of list to fetch
fetch_list="$1"
[[ -z "$fetch_list" ]] && { usage; exit 1; }

# Attempt to fetch the list...
ibl_uri="$(printf $URI_BASE $fetch_list)"
wget -q -O $CFILE $ibl_uri || { echo "wget failed"; exit 1; }

# ...and decompress it into our lib dir
TFILE="${CFILE}.txt"
gzip -dfq --stdout $CFILE > $TFILE || exit 1

# Clean the file up
DST_FILE="$LIBDIR/${fetch_list}.txt"
[[ -e "${DST_FILE}" ]] && mv -f ${DST_FILE} ${DST_FILE}.old
awk -F: '{ if (NF == 2) print $2 }' $TFILE > $DST_FILE || exit 1
head $DST_FILE

exit 0
