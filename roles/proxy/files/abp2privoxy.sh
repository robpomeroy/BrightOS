#!/usr/bin/bash
#
# This script is a simplification of the (presumed) open source script:
#   https://github.com/Andrwe/privoxy-blocklist/blob/master/privoxy-blocklist.sh
# The sed lines work the magic. I haven't attempted to understand or refine
# them! :-) RP.
#
# The script ensures a single instance is running, as root. There's no need to
# restart Privoxy after the script runs. 

[ ${UID} -ne 0 ] && echo -e "Please run this script as root.\n\n" && exit 1

# AdblockPlus list URLs:
#   easylist             Removes most adverts from international webpages
#   easyprivacy          Supplementary filter list removes most tracking
#   fanboy-annoyance     Blocks social media content, in-page pop-ups, etc.
#   fanboy-social        Removes social media widgits such as Facebook like button
#   easylist-cookie:     Blocks cookies banners
#   liste_fr             Removes adverts on French language websites
#   antiadblockfilters   Remove Adblock warnings
#   malwaredomains_full  Block malware domains (generated from malwaredomains.com)
ADBLOCK_LISTS=( \
    "https://easylist.to/easylist/easylist.txt" \
    "https://easylist.to/easylist/easyprivacy.txt" \
    "https://easylist.to/easylist/fanboy-annoyance.txt" \
    "https://easylist.to/easylist/fanboy-social.txt" \
    "https://easylist-downloads.adblockplus.org/easylist-cookie.txt" \
    "https://easylist-downloads.adblockplus.org/liste_fr.txt" \
    "https://easylist-downloads.adblockplus.org/antiadblockfilters.txt" \
    "https://easylist-downloads.adblockplus.org/malwaredomains_full.txt" \
)

# Privoxy details
PRIVOXY_USER="privoxy"
PRIVOXY_GROUP="privoxy"
PRIVOXY_DIR="/etc/privoxy"
PRIVOXY_CONF="/etc/privoxy/config"

# Working directories/files
TMPNAME="$(basename ${0})" # Name of the script
TMPDIR="/tmp/${TMPNAME}"   # Directory for temporary files

# `trap` ensures we clean up the temporary directory, however we exit
trap "rm -fr ${TMPDIR};exit" INT TERM EXIT

# Create temporary directory (lists will be stored here for processing)
mkdir -p -m0700 ${TMPDIR}

# Check/remove lock file
if [ -f "${TMPDIR}/${TMPNAME}.lock" ]; then
    read -r fpid <"${TMPDIR}/${TMPNAME}.lock"
    ppid=$(pidof -o %PPID -x "${TMPNAME}")
    if [[ $fpid = "${ppid}" ]] 
    then
        # Exit if the script is already running, to avoid a conflict.
        echo "An Instance of ${TMPNAME} is already running. Exit" && exit 1
    else
        # Remove dead lock file
        rm -f "${TMPDIR}/${TMPNAME}.lock"
    fi
fi

# Save script PID in lock file
echo $$ > "${TMPDIR}/${TMPNAME}.lock"

# Process the lists
for url in ${ADBLOCK_LISTS[@]}
do
    file=${TMPDIR}/$(basename ${url})      # Path to the downloaded file
    actionfile=${file%\.*}.script.action   # Corresponding action file
    filterfile=${file%\.*}.script.filter   # Corresponding filter file
    list=$(basename ${file%\.*})           # Remove the file extension

    # Download the Adblock Plus list
    wget -t 3 --no-check-certificate -O ${file} ${url} >${TMPDIR}/wget-${url//\//#}.log 2>&1

    # Simple check for true ABP lists; skip if not
    [ "$(grep -E '^.*\[Adblock.*\].*$' ${file})" == "" ] && continue

    # Convert AdblockPlus list to Privoxy list
    # URL block list
    echo -e "{ +block{${list}} }" > ${actionfile}
    sed '/^!.*/d;1,1 d;/^@@.*/d;/\$.*/d;/#/d;s/\./\\./g;s/\?/\\?/g;s/\*/.*/g;s/(/\\(/g;s/)/\\)/g;s/\[/\\[/g;s/\]/\\]/g;s/\^/[\/\&:\?=_]/g;s/^||/\./g;s/^|/^/g;s/|$/\$/g;/|/d' ${file} >> ${actionfile}

    echo "FILTER: ${list} Tag filter of ${list}" > ${filterfile}
    # Set filter for html elements
    sed '/^#/!d;s/^##//g;s/^#\(.*\)\[.*\]\[.*\]*/s@<([a-zA-Z0-9]+)\\s+.*id=.?\1.*>.*<\/\\1>@@g/g;s/^#\(.*\)/s@<([a-zA-Z0-9]+)\\s+.*id=.?\1.*>.*<\/\\1>@@g/g;s/^\.\(.*\)/s@<([a-zA-Z0-9]+)\\s+.*class=.?\1.*>.*<\/\\1>@@g/g;s/^a\[\(.*\)\]/s@<a.*\1.*>.*<\/a>@@g/g;s/^\([a-zA-Z0-9]*\)\.\(.*\)\[.*\]\[.*\]*/s@<\1.*class=.?\2.*>.*<\/\1>@@g/g;s/^\([a-zA-Z0-9]*\)#\(.*\):.*[:[^:]]*[^:]*/s@<\1.*id=.?\2.*>.*<\/\1>@@g/g;s/^\([a-zA-Z0-9]*\)#\(.*\)/s@<\1.*id=.?\2.*>.*<\/\1>@@g/g;s/^\[\([a-zA-Z]*\).=\(.*\)\]/s@\1^=\2>@@g/g;s/\^/[\/\&:\?=_]/g;s/\.\([a-zA-Z0-9]\)/\\.\1/g' ${file} >> ${filterfile}

    # Add filter file to action file
    echo "{ +filter{${list}} }" >> ${actionfile}
    echo "*" >> ${actionfile}

    # URL allow list
    echo "{ -block }" >> ${actionfile}
    sed '/^@@.*/!d;s/^@@//g;/\$.*/d;/#/d;s/\./\\./g;s/\?/\\?/g;s/\*/.*/g;s/(/\\(/g;s/)/\\)/g;s/\[/\\[/g;s/\]/\\]/g;s/\^/[\/\&:\?=_]/g;s/^||/\./g;s/^|/^/g;s/|$/\$/g;/|/d' ${file} >> ${actionfile}

    # Image URL allow list
    echo "{ -block +handle-as-image }" >> ${actionfile}
    sed '/^@@.*/!d;s/^@@//g;/\$.*image.*/!d;s/\$.*image.*//g;/#/d;s/\./\\./g;s/\?/\\?/g;s/\*/.*/g;s/(/\\(/g;s/)/\\)/g;s/\[/\\[/g;s/\]/\\]/g;s/\^/[\/\&:\?=_]/g;s/^||/\./g;s/^|/^/g;s/|$/\$/g;/|/d' ${file} >> ${actionfile}

    # Copy Privoxy action file into place
    install -o ${PRIVOXY_USER} -g ${PRIVOXY_GROUP} ${actionfile} ${PRIVOXY_DIR}
    if [ "$(grep $(basename ${actionfile}) ${PRIVOXY_CONF})" == "" ] 
    then
        # Ensure the Privoxy configuration loads this action file
        sed "s/^actionsfile user\.action/actionsfile $(basename ${actionfile})\nactionsfile user.action/" ${PRIVOXY_CONF} > ${TMPDIR}/config
        install -o ${PRIVOXY_USER} -g ${PRIVOXY_GROUP} ${TMPDIR}/config ${PRIVOXY_CONF}
    fi	

    # Copy Privoxy filter file into place
    install -o ${PRIVOXY_USER} -g ${PRIVOXY_GROUP} ${filterfile} ${PRIVOXY_DIR}
    if $(grep $(basename ${filterfile}) ${PRIVOXY_CONF})
    then
        # Ensure the Privoxy configuration loads this filter file
        sed "s/^\(#*\)filterfile user\.filter/filterfile $(basename ${filterfile})\n\1filterfile user.filter/" ${PRIVOXY_CONF} > ${TMPDIR}/config
        install -o ${PRIVOXY_USER} -g ${PRIVOXY_GROUP} ${TMPDIR}/config ${PRIVOXY_CONF}
    fi	

done

# Restore default exit
trap - INT TERM EXIT
rm -rf "${TMPDIR}"
exit 0