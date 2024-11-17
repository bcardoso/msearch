#!/usr/bin/env bash

### msearch.sh 0.4 // bcardoso

# requires: mpc, fzf

### 2024-11-16: refactor
### 2018-06-20: lists options
### 2017-05-05: random songs
### 2017-04-19: random artist/album/genre, new songs options
### 2017-04-02: mpc search >> current playlist

# your MPD music dir
readonly MUSICDIR="$HOME/music/collection"

set -o errexit
set -o pipefail

function help () {
    echo -e "\n$(basename "$0") [option] [keyword(s)]\n"
    grep ") # [a-z']" "$0" | sed -e 's/\t/\ /g;s/)\ \#/\t/g'
    echo -e "\nUsage:\n"
    echo -e "$(basename "$0") -a sabbath \"miles davis\" dylan"
    echo -e "$(basename "$0") -rb\n"
}

function mpc_search () {
    if [ "$#" -ge 2 ] ; then
        mode=$1
        shift
        for keyword in "$@" ; do
            mpc search "$mode" "$keyword" | mpc add
            echo "> Added \"$keyword\" to current playlist"
        done

    else
        help
        exit 1
    fi
}

function fzf_search () {
    local action=$1
    shift
    local query="$*"
    local selector="fzf --cycle -m -e"

    [ -n "$query" ] && selector+=" -q \"$query\""

    case $action in
        add | insert)
            mpc search any '' | eval "$selector" | sort | mpc "$action"
            ;;

        list_artist)
            mpc list artist | eval "$selector" | while read -r artist ; do
                mpc_search artist "$artist"
            done
            ;;

        list_album)
            mpc list album | eval "$selector" | while read -r album ; do
                mpc_search album "$album"
            done
            ;;

        list_genre)
            mpc list genre | eval "$selector" | while read -r genre ; do
                mpc_search genre "$genre"
            done
            ;;
    esac

}

function mpc_stop_after_current () {
    mpc current --wait > /dev/null
    mpc stop > /dev/null
}


### MAIN
case $1 in
    h | -h) # this help
        help
        ;;

    u | -u) # update database
        mpc update
        ;;

    c | -c) # clear playlist
        mpc clear
        ;;

    C | -C) # 'crop' all but current song
        mpc crop
        ;;

    p | -p) # toggle play-pause
        mpc toggle
        ;;

    s | -s) # stop after current
        mpc_stop_after_current &
        echo "> stop after $(mpc current -f "%artist% '%title%' (%time%)")"
        ;;

    r | -r) # toggle random mode
        mpc random > /dev/null
        ;;

    ra | -ra) # random artist
        artist=$(mpc list artist | shuf | head -1)
        mpc_search artist "$artist"
        ;;

    rb | -rb) # random album
        [ -n "$2" ] && num=$2 || num=1
        mpc list album | shuf | head -"$num" | while read -r album ; do
            mpc_search album "$album"
        done
        ;;

    rg | -rg) # random genre
        genre=$(mpc list genre | shuf | head -1)
        mpc_search genre "$genre"
        ;;

    rs | -rs) # random songs
        [ -n "$2" ] && num=$2 || num=78
        mpc search any '' | shuf | head -"$num" | mpc add
        echo "> added $num random songs to current playlist"
        ;;

    la | -la) # search artists list
        shift
        fzf_search list_artist "$@"
        ;;

    lb | -lb) # search albums list
        shift
        fzf_search list_album "$@"
        ;;

    lg | -lg) # search genres list
        shift
        fzf_search list_genre "$@"
        ;;

    n | -n) # recently (7d) added/modified songs
        [ -n "$2" ] && days=$2 || days=7
        cd "$MUSICDIR"
        find . -type f -mtime -"$days" \
            | grep -E '\.mp3$|\.flac$|\.ogg$' \
            | awk '{ sub(/^\.\//, ""); print }' \
            | sort \
            | mpc add
        echo "> added all new music from the past $days days"
        ;;

    a | -a) # add artist(s) to playlist
        shift
        mpc_search artist "$@"
        ;;

    b | -b) # add album(s) to playlist
        shift
        mpc_search album "$@"
        ;;

    g | -g) # add genre(s) to playlist
        shift
        mpc_search genre "$@"
        ;;

    i | -i) # fzf search, 'insert' below current
        shift
        mpc random off > /dev/null
        fzf_search insert "$@"
        ;;

    add | *) # fzf search, 'add' to playlist end
        fzf_search add "$@"
        ;;
esac
