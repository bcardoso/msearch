#!/bin/sh

### msearch.sh 0.2 // bcardoso
### 2017-05-05: random songs
### 2017-04-19: random artist/album/genre, new songs options
### 2017-04-02: mpc search >> current playlist
# requires mpc, fzf

# your mpd music dir
MUSICDIR=/media/arquivos/musicas

HELP () {
	echo "\n$(basename $0) [option] [keyword(s)]\n"
	grep ") \#" $0 | sed -e 's/\t/\ /g;s/)\ \#/\t/g'
	echo
	echo "usage:"
	echo "./$(basename $0) -a sabbath \"miles davis\" dylan"
	echo "./$(basename $0) -rb"
	echo
}

FZFSEARCH () {
	ACTION=$1
	shift
	QUERY="$@"
	mpc search any '' | fzf -m -e -q "$QUERY" | sort | mpc $ACTION
}

MPCSEARCH () {
	if [ "$#" -ge 2 ] ; then
		MODE=$1
		shift
		for keyword in "$@" ; do
			mpc search $MODE "$keyword"
		done | mpc add
	else
		HELP
		exit 1
	fi
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
		echo "> added all songs by \"$ARTIST\" to current playlist"
		;;
	
	-rb) # random album
		ALBUM=$(mpc list album | shuf | head -1)
		MPCSEARCH album "$ALBUM"
		echo "> added album \"$ALBUM\" to current playlist"
		;;		
	
	-rg) # random genre
		GENRE=$(mpc list genre | shuf | head -1)
		MPCSEARCH genre "$GENRE" 
		echo "> added all \"$GENRE\" songs to current playlist"
		;;

	-rs) # random songs
		NUM=78
		[ ! -z $2 ] && NUM=$2
		mpc search any '' | shuf | head -$NUM | mpc add
		echo "> added $NUM random songs to current playlist"
		;;

	-new) # recently (7d) added/modified songs
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
		FZFSEARCH insert "$@"
		;;

	*) # fzf search; 'add' to playlist end
		FZFSEARCH add "$@"
		;;
esac
