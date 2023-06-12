#!/usr/bin/env bash

(
set -e
PS1="$"
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir"
builddatadir="$workdir/BuildData"
minecraftversion="$(cat "${builddatadir}/info.json" | grep minecraftVersion | cut -d '"' -f 4)"
minecrafthash=$(cat "${builddatadir}/info.json" | grep minecraftHash | cut -d '"' -f 4)
accesstransforms="${builddatadir}/mappings/"$(cat "${builddatadir}/info.json" | grep accessTransforms | cut -d '"' -f 4)
classmappings="${builddatadir}/mappings/"$(cat "${builddatadir}/info.json" | grep classMappings | cut -d '"' -f 4)
membermappings="${builddatadir}/mappings/"$(cat "${builddatadir}/info.json" | grep memberMappings | cut -d '"' -f 4)
packagemappings="${builddatadir}/mappings/"$(cat "${builddatadir}/info.json" | grep packageMappings | cut -d '"' -f 4)
decompiledir="$workdir/work/mc-dev"
jarpath="$decompiledir/$minecraftversion"
mkdir -p "$decompiledir"

if [ ! -f  "$jarpath.jar" ]; then
    echo "Downloading unmapped vanilla jar..."
    curl -s -o "$jarpath.jar" "https://launcher.mojang.com/v1/objects/$minecrafthash/server.jar"
    if [ "$?" != "0" ]; then
        echo "Failed to download the vanilla server jar. Check connectivity or try again later."
        exit 1
    fi
fi

checksum=$(sha1sum "$jarpath.jar" | cut -d ' ' -f 1)
if [ "$checksum" != "$minecrafthash" ]; then
    echo "The SHA1 checksum of the downloaded server jar does not match the BuildData hash."
    exit 1
fi

# These specialsource commands are from https://hub.spigotmc.org/stash/projects/SPIGOT/repos/builddata/browse/info.json
if [ ! -f "$jarpath-cl.jar" ]; then
    echo "Applying class mappings..."
    java -jar "${builddatadir}/bin/SpecialSource-2.jar" map -i "$jarpath.jar" -m "$classmappings" -o "$jarpath-cl.jar" 1>/dev/null
    if [ "$?" != "0" ]; then
        echo "Failed to apply class mappings."
        exit 1
    fi
fi

if [ ! -f "$jarpath-m.jar" ]; then
    echo "Applying member mappings..."
    java -jar "${builddatadir}/bin/SpecialSource-2.jar" map -i "$jarpath-cl.jar" -m "$membermappings" -o "$jarpath-m.jar" 1>/dev/null
    if [ "$?" != "0" ]; then
        echo "Failed to apply member mappings."
        exit 1
    fi
fi

if [ ! -f "$jarpath-mapped.jar" ]; then
    echo "Creating remapped jar..."
    java -jar "${builddatadir}/bin/SpecialSource.jar" --kill-lvt -i "$jarpath-m.jar" --access-transformer "$accesstransforms" -m "$packagemappings" -o "$jarpath-mapped.jar" 1>/dev/null
    if [ "$?" != "0" ]; then
        echo "Failed to create remapped jar."
        exit 1
    fi
fi
)
