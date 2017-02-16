#!/bin/bash
# Pack update.zip

LOCALS=("ALL" "ES" "ID" "IN" "IT" "KZ" "MM" "MY" "PH" "PK" "RU" "SG" "TH" "UA" "VN")
CUSTOM_GMS_APK="custom/gms/apk/"

UPDATE="update"
ZIP=".zip"

PRE_DIC="custom"
PRE_FILE=".pre.config"
PRE_KEY="Pre No:"

function pack() {
    dest=${1}
    origin=${2}
    apk_dir=${3}
    locals=${4}
    
    # make destination directory if not exist
    parent="${dest}/$(get_date_time)/"
    src="${parent}src/"
    mkdir -p -- "${src}"
    echo "create source directory ${src}. DONE"

    # copy origin files into destination directory
    copy_recurive ${origin} ${src}
    echo "copy other configuration files. DONE"

    # copy preinstalled apks into ${src}custom/gms/apk/
    if ! test -d "${src}${CUSTOM_GMS_APK}"
    then
        mkdir -p -- "${src}${CUSTOM_GMS_APK}"
        echo "create apk directory. DONE"
    fi

    find ${apk_dir} -name "*.apk" -print0 | while IFS= read -r -d '' apk
    do
        cp ${apk} "${src}${CUSTOM_GMS_APK}"
        echo "copy ${apk} to ${src}${CUSTOM_GMS_APK}. DONE"
    done

    # check locals
    if [ ! -z ${locals} ]
    then
        # split locals to an array
        IFS=',' read -r -a lc_array <<< "${locals}"
        local count=${#lc_array[@]}
        if [ ${count} -le 0 ]
        then
            compress ${src} "${parent}${UPDATE}_NU${ZIP}"
            return
        fi

        local file="${src}${PRE_DIC}/${PRE_FILE}"

        if [ ! -d ${src}${PRE_DIC} ]
        then
            mkdir -p -- "${src}${PRE_DIC}"
        fi

        # touch .pre.config file into ${src}/${PRE_DIC}
        for lc in ${lc_array[@]}
        do
            if [ ! -z ${lc} ]
            then
                # write pre no of the local into ${PRE_FILE}
                echo "${PRE_KEY}${lc}" > "${src}${PRE_DIC}/${PRE_FILE}"
                compress ${src} "${parent}${UPDATE}_${lc}${ZIP}"
            fi
        done
    else
        compress ${src} "${parent}${UPDATE}_NU${ZIP}"
    fi

    # remove ${src}
    rm -rf ${src}
}

function get_date_time() {
    echo "$(date +"%Y")$(date +"%m")$(date +"%d")$(date +"%H")$(date +"%M")$(date +"%S")"
}

function copy_recurive() {
    find "${1}" -mindepth 1 -maxdepth 1 -exec cp -rf {} "${2}" \;
}

function compress() {
    cd ${1}
    zip -r "${2}" .
    echo "Compress ${1} to ${2}. DONE"
    cd -
}

function print_local_menu() {
    echo
    echo "Local menu... pick one or more(split with '|':IN|IT|RU):"
    local i=0
    local choice
    for choice in ${LOCALS[@]}
    do
        echo "    $i. $choice"
        i=$(($i+1))
    done
    echo
}

function get_all_locals() {
    local locals=${LOCALS[1]}
    local index=2
    while [[ $index -lt ${#LOCALS[@]} ]]
    do
        locals="${locals}|${LOCALS[$index]}"
        index=`expr $index + 1`
    done
    echo ${locals}
}

function main() {
    local dest_answer=$1
    dest_answer=${dest_answer%/}
    echo "destination: ${dest_answer}"

    if [ -z ${dest_answer} ]
    then
        echo 
        echo "Empty destination path. STOP"
        return 1
    elif ! test -d ${dest_answer}
    then
        echo
        echo "Invalid directory: ${dest_answer}. STOP"
        return 1
    fi

    origin_answer=$2
    echo "config path: ${origin_answer}"

    if [ -z ${origin_answer} ]
    then
        echo
        echo "Empty config path. STOP"
        return 1
    elif ! test -d ${origin_answer} 
    then
        echo
        echo "Invalid directory: ${origin_answer}. STOP"
        return 1
    fi

    # read target directory
    local apk_dir=$3
    echo "apk directory: ${apk_dir}"

    if [ -z ${apk_dir} ]
    then
        echo
        echo "Empty directory path. STOP"
        return 1
    elif ! test -d ${apk_dir}
    then
        echo
        echo "Invalid directory. STOP"
        return 1
    fi

    # Read local value
    local lc_answer=$4

    pack ${dest_answer} ${origin_answer} ${apk_dir} ${lc_answer}
}

main $@
