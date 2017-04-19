# msearch.sh
simple mpd playlist manager using mpc search and random options. depends on [mpc](https://musicpd.org/clients/mpc/) and [fzf](https://github.com/junegunn/fzf).

## how to use
`msearch.sh -h` lists all available options:

    msearch.sh [option] [keyword(s)]
    
    -h	 this help guide
    -c	 clear playlist
    -C	 'crop' playlist (clears all but current song)
    -p	 toggle play-pause
    -s	 stop after current
    -r	 toggle random mode
    -ra	 random artist
    -rb	 random album
    -rg	 random genre
    -new	 recently added/modified songs (up to 3 days ago)
    -a	 add artist(s) to playlist
    -b	 add album(s) to playlist
    -g	 add genre(s) to playlist
    -i	 fzf mpc search; 'insert' below current
    *	 fzf mpc search; 'add' to playlist end

    usage: msearch.sh -a sabbath "miles davis" dylan
    usage: msearch.sh -g instrumental rock samba etc
    usage: msearch.sh -rb
