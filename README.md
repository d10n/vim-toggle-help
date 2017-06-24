vim-toggle-help
===============

Toggle the vim help window on and off, like the Quake console.

    Plug 'd10n/vim-toggle-help'
    nnoremap <F1> :ToggleHelp<CR>

    " Make :h expand to :ToggleHelp. Use :help to bypass.
    cnoreabbrev <expr> h getcmdtype() == ":" && getcmdline() == 'h' ? 'ToggleHelp' : 'h'

## Caveats

 * The help tag stack can't be restored
 * Multiple help windows in a single tab are unsupported
 * vim-toggle-help can only restore help windows that it has seen. If you open and close a help page without having used :ToggleHelp, :ToggleHelp can't restore it.

## TODO

 * When toggling help on from insert mode, stay in insert mode
