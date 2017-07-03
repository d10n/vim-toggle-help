vim-toggle-help
===============

Toggle the vim help window on and off, like the Quake console.

    Plug 'd10n/vim-toggle-help'
    nmap <F1> <Plug>(toggle-help-n)
    imap <F1> <Plug>(toggle-help-i)
    vmap <F1> <Plug>(toggle-help-v)

## Caveats

 * The help tag stack can't be restored
 * Multiple help windows in a single tab are unsupported

