#!/bin/bash
# Pack update.zip

DIST="/home/kangweodai/Vivam/CustomPackage/"
PACKAGES=("GameLoft" "GameLoft_Yandex")
DEFAULT_PACKAGE="GameLoft"
LOCALS=("ALL" "ES" "ID" "IN" "IT" "KZ" "MM" "MY" "PH" "PK" "RU" "SG" "TH" "UA" "VN")
CUSTOM_GMS_APK="custom/gms/apk/"
ORIGIN="/home/kangweodai/Vivam/Projects/CustomPackage/origin"

UPDATE="update"
ZIP=".zip"

PRE_DIC="custom"
PRE_FILE=".pre.config"
PRE_KEY="Pre No:"

function pack() {
    apk_dir=${1}
    package=${2}
    locals=${3}

    # make distination directory if not exist
    parent="${DIST}${package}/$(get_date_time)/"
    src="${parent}src/"
    mkdir -p -- "${src}"
    echo "create source directory ${src}. DONE"

    # copy origin files into distination directory
    copy_recurive ${ORIGIN} ${src}
    echo "copy other configuration files. DONE"

    # copy apk_dir into ${src}custom/gms/apk/
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

    # compress src directory into update.zip without preinstalled no.
    compress ${src} "${parent}${UPDATE}${ZIP}"

    # check locals
    if [ ! -z ${locals} ]
    then
        local file="${src}${PRE_DIC}/${PRE_FILE}"

        if [ ! -d ${src}${PRE_DIC} ]
        then
            mkdir -p -- "${src}${PRE_DIC}"
        fi
        # touch .pre.config file into ${src}/${PRE_DIC}
        touch "${file}"

        # split locals to an array
        IFS='|' read -r -a lc_array <<< "${locals}"
        for lc in ${lc_array[@]}
        do
            if [ ! -z ${lc} ]
            then
                # write pre no of the local into ${PRE_FILE}
                echo "${PRE_KEY}${lc}" > "${src}${PRE_DIC}/${PRE_FILE}"
                compress ${src} "${parent}${UPDATE}_${lc}${ZIP}"
            fi
        done
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

function print_package_menu() {
    echo
    echo "Package menu... pick one:"
    local i=1
    local choice
    for choice in ${PACKAGES[@]}
    do
        echo "    $i. $choice"
        i=$(($i+1))
    done
    echo
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
    # Read target directory
    local apk_dir=
    echo -n "Input full directory path with target apk_dir: "
    read apk_dir

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

    # Read package value
    local pkg_answer

    print_package_menu
    echo -n "Which would you like? [${DEFAULT_PACKAGE}] "
    read pkg_answer

    local pkg_selection=
    if [ -z "${pkg_answer}" ]
    then
        pkg_selection=${DEFAULT_PACKAGE}
    elif (echo -n $pkg_answer | grep -q -e "^[12]$")
    then
        if [ $pkg_answer -le ${#PACKAGES[@]} ]
        then
            pkg_selection=${PACKAGES[$(($pkg_answer-1))]}
        fi
    else
        for pkg in ${PACKAGES[@]}
        do
            if [ "${pkg_answer}" == "${pkg}" ]
            then
                pkg_selection=${pkg_answer}
                break
            fi
        done
    fi

    if [ -z ${pkg_selection} ]
    then
        echo
        echo "Invalid package: $pkg_answer. STOP"
        return 1
    fi

    echo
    echo "You choose package ${pkg_selection}"

    # Read local value
    local lc_answer

    print_local_menu
    echo -n "Which would you like? [NULL] "
    read lc_answer

    local lc_selection=

    if [ ! -z "${lc_answer}" ]
    then
        IFS='|' read -r -a lc_array <<< "${lc_answer}"
        for lc in ${lc_array[@]}
        do
            echo "lc:${lc}"
            case ${lc} in
                "0")
                    lc_selection=$(get_all_locals)
                    break
                    ;;
                "ALL")
                    lc_selection=$(get_all_locals)
                    break
                    ;;
                *)
                    if (echo -n $lc | grep -q -e "^[0-9][0-9]*$")
                    then
                        if [ $lc -lt ${#LOCALS[@]} ]
                        then
                            lc_selection="${lc_selection}|${LOCALS[$lc]}"
                        fi
                    else
                        if [ ! -z ${lc} ]
                        then
                            lc_selection="${lc_selection}|${lc}"
                        fi
                    fi
                    ;;
              esac
          done
    fi

    if [ ! -z ${lc_selection} ]
    then
        # remove '|' at the beginning if exists
        lc_selection=${lc_selection#|}
        # remote '|' in the end if exists
        lc_selection=${lc_selection%|}
    fi

    echo
    echo "You choose locals ${lc_selection:-"NULL"}"

    pack ${apk_dir} ${pkg_selection} ${lc_selection}
}

main
