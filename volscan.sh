#!/bin/bash
. utils.sh

OUTPUT="text json"
PLUGINS=" amcache apihooks atoms atomscan auditpol bigpools bioskbd cachedump callbacks clipboard cmdline cmdscan connections connscan consoles crashinfo deskscan devicetree dlldump dlllist driverirp drivermodule driverscan dumpcerts dumpfiles dumpregistry editbox envars eventhooks evtlogs filescan gahti gditimers gdt getservicesids getsids handles hashdump hibinfo hivedump hivelist hivescan hpakextract hpakinfo idt iehistory imagecopy imageinfo impscan joblinks kdbgscan kpcrscan ldrmodules lsadump machoinfo malfind mbrparser memdump memmap messagehooks mftparser moddump modscan modules multiscan mutantscan notepad objtypescan patcher poolpeek printkey privs procdump pslist psscan pstree psxview qemuinfo raw2dmp screenshot servicediff sessions shellbags shimcache shutdowntime sockets sockscan ssdt strings svcscan symlinkscan thrdscan threads timeliner timers truecryptmaster truecryptpassphrase truecryptsummary unloadedmodules userassist userhandles vaddump vadinfo vadtree vadwalk vboxinfo verinfo vmwareinfo volshell windows wintree wndscan yarascan"

# kill all processes
trap "pkill -f volatility" SIGINT SIGTERM

IFS=' '
for img in $*; do
    # Get the 'last' profile of the imageinfo output
    profile=$(
            volatility -f ${img} --output json imageinfo |
            transformJSON |
            jq '."Suggested Profile(s)" | 
                    split(", ")[] |
                    split(" ") | .[0]' |
            tail -n1 |
            tr -d '"'
        )
    echo "analyzing: ${img} with profile: ${profile}"
    for out in ${OUTPUT}; do
        dir="${img}-out"
        mkdir -p "${dir}"
        for p in ${PLUGINS}; do
            (
            volatility -f "${img}" --profile "${profile}" --output "${out}" "${p}" > "${dir}/${p}.${out}"
            ) &
        done
    done
done

# waiting for all processes to finish
wait
