let b:i18_buffer_name = ''

function! Initialise_i18ni3r()
  let curbufname = expand('%')
  let altbufname = expand('%:t:r') . '_i18n.txt'
  if filereadable(altbufname)
    exe 'edit ' . altbufname
    $
  else
    enew
    exe 'write ' . altbufname
  endif
  " set up local buffer switch
  nnoremap <buffer> <leader>m :call PrepareSubstitution()<cr>
  let b:i18_buffer_name = curbufname
  exe 'buffer ' . curbufname
  let b:i18_buffer_name = altbufname
endfunction

function! PrepareSubstitution()
  " switch to the source buffer
  exe 'buffer ' . b:i18_buffer_name
  normal `>a')
  normal `<it('
  normal vi'
endfunction

function! ExtractString(type, ...)
  let sel_save = &selection
  let &selection = "inclusive"
  let reg_save = @@

  if a:0  " Invoked from Visual mode, use '< and '> marks.
    silent exe "normal! `<" . a:type . "`>y"
  elseif a:type == 'line'
    silent exe "normal! '[V']y"
  elseif a:type == 'block'
    silent exe "normal! `[\<C-V>`]y"
  else
    silent exe "normal! `[v`]y"
  endif

  exe 'b ' . b:i18_buffer_name
  pu
  pu
  normal! `[v`]

  let &selection = sel_save
  let @@ = reg_save

endfunction

vmap <silent> <leader>m :<C-U>call ExtractString(visualmode(), 1)<CR>
nmap <silent> <leader>m :set opfunc=ExtractString<CR>g@

