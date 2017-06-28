
if exists('g:loaded_toggle_help')
  finish
endif
let g:loaded_toggle_help = 1

command! -bar ToggleHelp call ToggleHelp('')

" Window ID shim
let s:window_id_builtin = exists('*win_getid')
if !s:window_id_builtin
  let s:win_id_counter = 1000
  augroup toggle_help_win_id
    autocmd!
    autocmd WinEnter * call s:create_window_id(winnr())
    autocmd VimEnter * call s:create_window_id(winnr())
  augroup END
endif

function! s:create_window_id(window_number)
  if empty(getwinvar(a:window_number, 'toggle_help_winid'))
    call setwinvar(a:window_number, 'toggle_help_winid', s:win_id_counter)
    let s:win_id_counter += 1
  endif
endfunction

function! s:my_win_getid(window_number)
  if s:window_id_builtin
    return win_getid(a:window_number)
  endif
  return getwinvar(a:window_number, 'toggle_help_winid')
endfunction

function! s:my_win_gotoid(window_id)
  if s:window_id_builtin
    return win_gotoid(a:window_id)
  endif
  for window in range(1, winnr('$'))
    if getwinvar(window, 'toggle_help_winid') == a:window_id
      exec window.'wincmd w'
      return
    endif
  endfor
  " do nothing if there was no matching id
endfunction

" Help toggling

augroup toggle_help
  autocmd!
  autocmd WinLeave * if &buftype == 'help' | call s:buf_win_leave_seen(expand('%:p'), expand('%'), s:my_win_getid(winnr()), winsaveview()) | endif
augroup END

function! s:buf_win_leave_seen(filename, bufname, window_number, window_view)
  call s:save_current_tab_help(a:filename, a:bufname, a:window_number, a:window_view)
endfunction

function! s:save_current_tab_help(filename, bufname, current_winid, window_view)
  if !exists('s:help_windows')
    let s:help_windows = {}
    let s:help_tabs = {}
  endif

  let current_tab_help = {}
  let current_tab_help['lastwin'] = a:current_winid
  let current_tab_help['bufname'] = a:bufname
  let current_tab_help['file'] = a:filename
  let current_tab_help['view'] = a:window_view
  let s:help_tabs[tabpagenr()] = current_tab_help
  let window_ids = map(range(1, winnr('$')), 's:my_win_getid(v:val)')
  for window_id in window_ids
    let s:help_windows[window_id] = current_tab_help
  endfor
endfunction

" returnMode: '' does nothing, 'i' returns to insert mode, 'v' returns to visual mode
function! ToggleHelp(returnMode)
  if !exists('s:help_windows')
    let s:help_windows = {}
    let s:help_tabs = {}
  endif
  let original_lazyredraw = &lazyredraw
  set lazyredraw
  let current_winid = s:my_win_getid(winnr())
  wincmd p
  let last_winid = s:my_win_getid(winnr())
  wincmd p
  let help_winnr = -1

  " Get the help window
  for window in range(1, winnr('$'))
    let window_type = getwinvar(window, '&buftype')
    if window_type == 'help'
      let help_winnr = window
      break
    endif
  endfor

  let help_is_open = help_winnr > 0
  if help_is_open
    let only_help_window_remains = winnr('$') == 1
    if !only_help_window_remains
      helpclose
    endif
    call s:restore_return_mode(a:returnMode, last_winid, current_winid, original_lazyredraw)
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
    call s:restore_return_mode(a:returnMode, last_winid, current_winid, original_lazyredraw)
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
    call s:restore_return_mode(a:returnMode, last_winid, current_winid, original_lazyredraw)
    return
  endif

  " This is a new tab.
  " No new help was requested, so open the default help.
  help
  call s:restore_return_mode(a:returnMode, last_winid, current_winid, original_lazyredraw)
endfunction

function! s:restore_return_mode(mode, last_winid, current_winid, original_lazyredraw)
  if a:mode == 'i'
    call s:my_win_gotoid(a:last_winid)
    call s:my_win_gotoid(a:current_winid)
    startinsert
  elseif a:mode == 'v'
    call s:my_win_gotoid(a:last_winid)
    call s:my_win_gotoid(a:current_winid)
    normal gv
  endif
  let &lazyredraw = a:original_lazyredraw
endfunction

"nnoremap <F1> :ToggleHelp<CR>
"inoremap <F1> <C-o>:call ToggleHelp('i')<CR>
"vnoremap <F1> <Esc>:call ToggleHelp('v')<CR>

" vim: set ts=2 sw=2 et:
