#!/bin/sh

### msearch.sh 0.2 // bcardoso
### 2017-05-05: random songs
### 2017-04-19: random artist/album/genre, new songs options
### 2017-04-02: mpc search >> current playlist
# requires mpc, fzf

# your mpd music dir
MUSICDIR=/media/arquivos/musicas

HELP () {
    echo -e "\n$(basename $0) [option] [keyword(s)]\n"
    grep ") \#" $0 | sed -e 's/\t/\ /g;s/)\ \#/\t/g'
    echo
    echo "usage:"
    echo "./$(basename $0) -a sabbath \"miles davis\" dylan"
    echo "./$(basename $0) -rb"
    echo
}

MPCSEARCH () {
    if [ "$#" -ge 2 ] ; then
	MODE=$1
	shift
	for keyword in "$@" ; do
	    mpc search $MODE "$keyword" | mpc add
	    echo "> added \"$keyword\" to current playlist"
	done
	
    else
	HELP
	exit 1
    fi
}

FZFSEARCH () {
    ACTION=$1
    shift
    QUERY="$@"
    if [ -z $QUERY ] ; then
	SELECTOR="fzf -m -e"
    else
	SELECTOR="fzf -m -e -q ${QUERY}"
    fi
    
    case $ACTION in
	add | insert)
	    mpc search any '' | $SELECTOR | sort | mpc $ACTION
	    ;;

	list_artist)
	    mpc list artist | $SELECTOR | while read ARTIST ; do
		MPCSEARCH artist "$ARTIST"
	    done
	    ;;

	list_album)
	    mpc list album | $SELECTOR | while read ALBUM ; do
		MPCSEARCH album "$ALBUM"
	    done
	    ;;

	list_genre)
	    mpc list genre | $SELECTOR | while read GENRE ; do
		MPCSEARCH genre "$GENRE"
	    done
	    ;;
    esac
	
}

STOPAFTERCURRENT () {
    mpc current --wait > /dev/null
    mpc stop > /dev/null
}


### MAIN
case $1 in
    -h) # this help
	HELP
	;;
    
    -c) # clear playlist
	mpc clear
	;;
    
    -C) # 'crop' all but current song
	mpc crop
	;;
    
    -p) # toggle play-pause
	mpc toggle
	;;
    
    -s) # stop after current
	STOPAFTERCURRENT &
	echo "> will stop after $(mpc current -f "%artist% '%title%' (%time%)")"
	;;

    -r) # toggle random mode
	mpc random > /dev/null
	;;
	
    -ra) # random artist
	ARTIST=$(mpc list artist | shuf | head -1)
	MPCSEARCH artist "$ARTIST"
	;;
    
    -rb) # random album
	if [ ! -z $2 ] ; then
	    NUM=$2
	    mpc list album | shuf | head -$NUM | while read ALBUM ; do
		MPCSEARCH album "$ALBUM"
	    done
	else
	    ALBUM=$(mpc list album | shuf | head -1)
	    MPCSEARCH album "$ALBUM"
	fi
	;;		
    
    -rg) # random genre
	GENRE=$(mpc list genre | shuf | head -1)
	MPCSEARCH genre "$GENRE"
	;;
    
    -rs) # random songs
	NUM=78
	[ ! -z $2 ] && NUM=$2
	mpc search any '' | shuf | head -$NUM | mpc add
	echo "> added $NUM random songs to current playlist"
	;;

    -la) # search artists list
	shift
	FZFSEARCH list_artist "$@"
	;;
    
    -lb) # search albums list
	shift
	FZFSEARCH list_album "$@"
	;;
    
    -lg) # search genres list
	shift
	FZFSEARCH list_genre "$@"
	;;
    
    -n) # recently (7d) added/modified songs
	DAYS=7
	cd $MUSICDIR
	find . -type f -mtime -$DAYS  | egrep '\.mp3$|\.flac$|\.ogg$' | awk '{ sub(/^\.\//, ""); print }' | sort | mpc add
	echo "> added all new music from the past $DAYS days"
	;;

    -a) # add artist(s) to playlist
	shift
	MPCSEARCH artist "$@"
	;;
    
    -b) # add album(s) to playlist
	shift
	MPCSEARCH album "$@"
	;;
	
    -g) # add genre(s) to playlist
	shift
	MPCSEARCH genre "$@"
	;;
    
    -i) # fzf search; 'insert' below current
	shift
	mpc random off > /dev/null
	FZFSEARCH insert "$@"
	;;

    *) # fzf search; 'add' to playlist end
	FZFSEARCH add "$@"
	;;
esac
