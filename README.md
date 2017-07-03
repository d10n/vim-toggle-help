vim-toggle-help
===============

Toggle the vim help window on and off, like the Quake console.

    Plug 'd10n/vim-toggle-help'

Press `<F1>` to toggle or customize your maps:

    nmap <C-_> <Plug>(toggle-help-n)
    imap <C-_> <Plug>(toggle-help-i)
    vmap <C-_> <Plug>(toggle-help-v)

## Caveats

 * The help tag stack can't be restored
 * Multiple help windows in a single tab are unsupported

