#!/bin/bash
#|---/ /+------------------------------------+---/ /|#
#|--/ /-| Script to restore personal configs |--/ /-|#
#|-/ /--| Prasanth Rangan                    |-/ /--|#
#|/ /---+------------------------------------+/ /---|#

source global_fn.sh
if [ $? -ne 0 ] ; then
    echo "Error: unable to source global_fn.sh, please execute from $(dirname $(realpath $0))..."
    exit 1
fi

ThemeOverride="${1:-}"              #override default config list with custom theme list [param 1]
CfgDir="${2:-${CloneDir}/Configs}"  #override default config path with custom theme path [param 2]

if [ ! -f "${ThemeOverride}restore_cfg.lst" ] || [ ! -d "${CfgDir}" ] ; then
    echo "ERROR : '${ThemeOverride}restore_cfg.lst' or '${CfgDir}' does not exist..."
    exit 1
fi

BkpDir="${HOME}/.config/$(date +'cfg_%y%m%d_%Hh%Mm%Ss')"

if [ -d $BkpDir ] ; then
    echo "ERROR : $BkpDir exists!"
    exit 1
else
    mkdir -p $BkpDir
fi

cat "${ThemeOverride}restore_cfg.lst" | while read lst
do

    bkpFlag=`echo $lst | awk -F '|' '{print $1}'`
    eval pth=`echo $lst | awk -F '|' '{print $2}'`
    cfg=`echo $lst | awk -F '|' '{print $3}'`
    pkg=`echo $lst | awk -F '|' '{print $4}'`

    while read pkg_chk
    do
        if ! pkg_installed $pkg_chk
            then
            echo "skipping ${cfg}..."
            continue 2
        fi
    done < <( echo "${pkg}" | xargs -n 1 )

    echo "${cfg}" | xargs -n 1 | while read cfg_chk
    do
        tgt=`echo $pth | sed "s+^${HOME}++g"`
        if [[ -z "$pth" ]]; then continue ; fi #Added this if cfg.lst have blank lines

        if ( [ -d $pth/$cfg_chk ] || [ -f $pth/$cfg_chk ] ) && [ "${bkpFlag}" == "Y" ]
            then

            if [ ! -d $BkpDir$tgt ] ; then
                mkdir -p $BkpDir$tgt
            fi

            mv $pth/$cfg_chk $BkpDir$tgt
            echo "config backed up $pth/$cfg_chk --> $BkpDir$tgt..."
        fi

        if [ ! -d $pth ] ; then
            mkdir -p $pth
        fi

        cp -r $CfgDir$tgt/$cfg_chk $pth
        echo "config restored ${pth} <-- $CfgDir$tgt/$cfg_chk..."
    done

done

touch ${HOME}/.config/hypr/monitors.conf
touch ${HOME}/.config/hypr/userprefs.conf

if nvidia_detect && [ $(grep '^source = ~/.config/hypr/nvidia.conf' ${HOME}/.config/hypr/hyprland.conf | wc -l) -eq 0 ] ; then
    cp ${CfgDir}/.config/hypr/nvidia.conf ${HOME}/.config/hypr/nvidia.conf
    echo -e 'source = ~/.config/hypr/nvidia.conf # auto sourced vars for nvidia\n' >> ${HOME}/.config/hypr/hyprland.conf
fi

./create_cache.sh
./restore_zsh.sh
./restore_lnk.sh

