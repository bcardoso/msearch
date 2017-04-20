#!/bin/sh

### msearch.sh 0.2
### 2017-04-19: random artist/album/genre, new songs options
### 2017-04-02: mpc search >> current playlist
# requires mpc, fzf

# your mpd music dir
MUSICDIR=/media/arquivos/musicas

HELP () {
	echo "\n$(basename $0) [option] [keyword(s)]\n"
	grep ") \#" $0 | sed -e 's/\t/\ /g;s/)\ \#/\t/g'
	echo
	echo "usage: $(basename $0) -a sabbath \"miles davis\" dylan"
	echo "usage: $(basename $0) -g instrumental rock samba etc"
	echo "usage: $(basename $0) -rb"
	echo
}

FZFSEARCH () {
	mpc search any '' | fzf -m -e | sort | mpc $1
}

MPCSEARCH () {
	if [ "$#" -ge 2 ] ; then
		MODE=$1
		shift
		for keyword in $@ ; do
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

	-C) # 'crop' playlist (clears all but current song)
		mpc crop
		;;

	-p) # toggle play-pause
		mpc toggle
		;;

	-s) # stop after current
		STOPAFTERCURRENT &
		;;

	-r) # toggle random mode
		mpc random > /dev/null
		;;
	
	-ra) # random artist
		ARTIST=$(mpc list artist | shuf | head -1)
		mpc search artist "$ARTIST" | mpc add
		echo "> added all songs by \"$ARTIST\" to current playlist"
		;;
	
	-rb) # random album
		ALBUM=$(mpc list album | shuf | head -1)
		mpc search album "$ALBUM" | mpc add
		echo "> added album \"$ALBUM\" to current playlist"
		;;		
	
	-rg) # random genre
		GENRE=$(mpc list genre | shuf | head -1)
		mpc search genre "$GENRE" | mpc add
		echo "> added all \"$GENRE\" songs to current playlist"
		;;

	-new) # recently added/modified songs (up to 3 days ago)
		cd $MUSICDIR
		find . -type f -mtime -3  | egrep '\.mp3$|\.flac$|\.ogg$' | awk '{ sub(/^\.\//, ""); print }' | sort | mpc add
		;;

	-a) # add artist(s) to playlist
		shift
		MPCSEARCH artist $@
		;;

	-b) # add album(s) to playlist
		shift
		MPCSEARCH album $@
		;;
	
	-g) # add genre(s) to playlist
		shift
		MPCSEARCH genre $@
		;;
	
	-i) # fzf mpc search; 'insert' below current
		FZFSEARCH insert
		;;

	*) # fzf mpc search; 'add' to playlist end
		FZFSEARCH add
		;;
esac
