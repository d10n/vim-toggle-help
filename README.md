vim-toggle-help
===============

Toggle the vim help window on and off, like the Quake console.

    Plug 'd10n/vim-toggle-help'
    nnoremap <F1> :ToggleHelp<CR>
    inoremap <F1> <C-o>:call ToggleHelp('', 'i')<CR>
    vnoremap <F1> <esc>:call ToggleHelp('', 'v')<CR>

    " Optional: make :h expand to :ToggleHelp. Use :help to bypass.
    cnoreabbrev <expr> h getcmdtype() == ':' && getcmdline() == 'h' ? 'ToggleHelp' : 'h'

## Caveats

 * The help tag stack can't be restored
 * Multiple help windows in a single tab are unsupported
 * vim-toggle-help can only restore help windows that it has seen. You need to either open or close a help page with ToggleHelp in order for ToggleHelp to be able to restore it.

