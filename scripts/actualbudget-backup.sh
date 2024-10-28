#!/bin/bash

THIS_NAME="$(basename "${0}")"
THIS_PATH="$(readlink -e "${0}")"
THIS_DIR="$(dirname "${THIS_PATH}")"
DEST=${THIS_DIR}/../bin
DIR_ROOT="$(dirname "${THIS_DIR}")"

print_status() {
    echo
    echo -e "${bold}${green}$1${normal}"
    echo
}

print_status_red() {
    echo
    echo -e "${bold}${red}$1${normal}"
    echo
}

if test -t 1; then # if terminal
    ncolors=$(which tput > /dev/null && tput colors) # supports color
    if test -n "$ncolors" && test $ncolors -ge 8; then
        termcols=$(tput cols)
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi

myExit() {
  print_status_red "status check: [FAILED]"
  exit $1
}

ACTUAL_SERVER_URL=http://localhost:5006
ACTUAL_PASSWORD=admin
ACTUAL_SYNC_ID=b90ad0e2-efe1-41ce-b770-ea7262762a78

ACTUAL_TOKEN=$(curl -X POST -H "Content-Type: application/json" -d '{"loginMethod": "password", "password": "'${ACTUAL_PASSWORD}'"}' "${ACTUAL_SERVER_URL}/account/login" | jq -r .data.token)

ACTUAL_FILE_ID=$(curl -X GET -H "X-ACTUAL-TOKEN: ${ACTUAL_TOKEN}" "${ACTUAL_SERVER_URL}/sync/list-user-files" | jq -r '.data[] | select(.groupId=="'${ACTUAL_SYNC_ID}'") | .fileId')

curl -X GET -H "X-ACTUAL-TOKEN: ${ACTUAL_TOKEN}" -H "X-ACTUAL-FILE-ID: ${ACTUAL_FILE_ID}" "${ACTUAL_SERVER_URL}/sync/download-user-file" -o "/tmp/actualbudget_backup_$(date +%F_%H-%M-%S).zip"

exit 0