vim-toggle-help
===============

Toggle the vim help window on and off, like the Quake console.

    Plug 'd10n/vim-toggle-help'
    nnoremap <F1> :ToggleHelp<CR>
    inoremap <F1> <C-o>:call ToggleHelp('i')<CR>
    vnoremap <F1> <esc>:call ToggleHelp('v')<CR>

## Caveats

 * The help tag stack can't be restored
 * Multiple help windows in a single tab are unsupported

