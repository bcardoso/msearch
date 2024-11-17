# msearch.sh

Simple [MPD](https://www.musicpd.org/) playlist manager script using mpc search commands and random options.

Depends on [mpc](https://musicpd.org/clients/mpc/) and [fzf](https://github.com/junegunn/fzf).

## how to use
`msearch.sh` [option] [keyword(s)]

    h | -h	 this help
    u | -u	 update database
    c | -c	 clear playlist
    C | -C	 'crop' all but current song
    p | -p	 toggle play-pause
    s | -s	 stop after current
    r | -r	 toggle random mode
    ra | -ra	 random artist
    rb | -rb	 random album
    rg | -rg	 random genre
    rs | -rs	 random songs
    la | -la	 search artists list
    lb | -lb	 search albums list
    lg | -lg	 search genres list
    n | -n	 recently (7d) added/modified songs
    a | -a	 add artist(s) to playlist
    b | -b	 add album(s) to playlist
    g | -g	 add genre(s) to playlist
    i | -i	 fzf search, 'insert' below current
    add | *	 fzf search, 'add' to playlist end

Usage examples:

- Add multiple artists: `./msearch.sh -a sabbath "miles davis" dylan`
- Add a random album: `./msearch.sh -rb`


## shortcut

```sh
alias ms="~/bin/msearch.sh"
```
