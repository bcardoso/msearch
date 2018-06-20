# msearch.sh
simple mpd playlist manager using mpc search and random options. depends on [mpc](https://musicpd.org/clients/mpc/) and [fzf](https://github.com/junegunn/fzf).

## how to use
`msearch.sh` [option] [keyword(s)]

    -h	 this help
    -c	 clear playlist
    -C	 'crop' all but current song
    -p	 toggle play-pause
    -s	 stop after current
    -r	 toggle random mode
    -ra	 random artist
    -rb	 random album
    -rg	 random genre
    -rs	 random songs
    -la	 search artists list
    -lb	 search albums list
    -lg	 search genres list
    -n	 recently (7d) added/modified songs
    -a	 add artist(s) to playlist
    -b	 add album(s) to playlist
    -g	 add genre(s) to playlist
    -i	 fzf search; 'insert' below current
    *	 fzf search; 'add' to playlist end

usage:
./msearch.sh -a sabbath "miles davis" dylan
./msearch.sh -rb

