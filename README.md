vim-toggle-help
===============

Toggle the vim help window on and off, like the Quake console.

    Plug 'd10n/vim-toggle-help'

Press `<F1>` to toggle or customize your maps:

    nmap ? <Plug>(toggle-help-n)
    imap ? <Plug>(toggle-help-i)
    vmap ? <Plug>(toggle-help-v)

## Caveats

 * The help tag stack can't be restored
 * Multiple help windows in a single tab are unsupported

