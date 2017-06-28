command! -nargs=? -bar -complete=help ToggleHelp call ToggleHelp(<q-args>, '')

" subject: help topic to load, or empty string to toggle help
" returnMode: '' does nothing, 'i' returns to insert mode, 'v' returns to visual mode
function! ToggleHelp(subject, returnMode)
  if !exists('s:help_windows')
    let s:help_windows = {}
    let s:help_tabs = {}
  endif
  let current_winid = win_getid()
  wincmd p
  let last_winid = win_getid()
  let current_tab_help = {}

  let open_new_topic = len(a:subject) > 0
  if open_new_topic
    " Open first to associate the other windows with this help subject
    try
      exec 'help '.a:subject
    catch /^Vim\%((\a\+)\)\=:E149/
      call win_gotoid(current_winid)
      echohl ErrorMsg
      echomsg 'E149: Sorry, no help for '.a:subject
      echohl None
      return
    endtry
  endif

  let window_ids = map(range(1, winnr('$')), 'win_getid(v:val)')

  " Get the help window
  exec "windo if &buftype == 'help' | let current_tab_help = {'bufname': bufname(winbufnr(winnr())), 'file': expand('%:p'), 'view': winsaveview()} | endif"

  " Set the previous window id so that focus returns to it if help is closd
  call win_gotoid(last_winid)
  call win_gotoid(current_winid)

  let help_is_open = !empty(current_tab_help)
  if help_is_open
    " Record the open help
    let current_tab_help['lastwin'] = current_winid
    let s:help_tabs[tabpagenr()] = current_tab_help
    for window_id in window_ids
      let s:help_windows[window_id] = current_tab_help
    endfor

    if open_new_topic
      " Open again to regain focus
      exec 'help '.a:subject
    else
      let only_help_window_remains = winnr('$') == 1
      if !only_help_window_remains
        helpclose
      endif
    endif
    call s:restore_return_mode(a:returnMode, last_winid, current_winid)
    return
  endif

  " Help is not open

  " Reopen the last help that this window has seen
  let help_for_this_window = get(s:help_windows, current_winid)
  if !empty(help_for_this_window)
    try
      exec 'help '.help_for_this_window['bufname']
    catch " E149: Sorry, no help for multiple_cursors
      " Work around bad plugin help
      silent! help
      exec 'edit '.fnameescape(help_for_this_window['file'])
    endtry
    exec 'call winrestview(help_for_this_window["view"])'
    call s:restore_return_mode(a:returnMode, last_winid, current_winid)
    return
  endif

  " This is a new window. Reopen the last help this tab has seen.
  let help_for_this_tab = get(s:help_tabs, tabpagenr())
  if !empty(help_for_this_tab)
    try
      exec 'help '.help_for_this_tab['bufname']
    catch
      silent! help
      exec 'edit '.fnameescape(help_for_this_tab['file'])
    endtry
    exec 'call winrestview(help_for_this_tab["view"])'
    call s:restore_return_mode(a:returnMode, last_winid, current_winid)
    return
  endif

  " This is a new window and a new tab.
  " No new help was requested, so open the default help.
  help
  call s:restore_return_mode(a:returnMode, last_winid, current_winid)
endfunction

function! s:restore_return_mode(mode, current_winid, last_winid)
  if a:mode == 'i'
    call win_gotoid(a:last_winid)
    call win_gotoid(a:current_winid)
    startinsert
  elseif a:mode == 'v'
    call win_gotoid(a:last_winid)
    call win_gotoid(a:current_winid)
    normal gv
  endif
endfunction

"nnoremap <F1> :ToggleHelp<CR>
"inoremap <F1> <C-o>:call ToggleHelp('', 'i')<CR>
"vnoremap <F1> <Esc>:call ToggleHelp('', 'v')<CR>
"cnoreabbrev <expr> h getcmdtype() == ':' && getcmdline() == 'h' ? 'ToggleHelp' : 'h'

" vim: set ts=2 sw=2:et:
