let b:i18_buffer_name = ''
let b:orig_buffer_name = ''

function! Initialise_i18ni3r()
  let curbufname = expand('%')
  let path = expand('%:p')
  let translated_path = substitute(path, 'app/views/\(.*\)\.html.*', 'config/locales/\1/', '')
  let altbufname = translated_path . "da.yml"

  if ! isdirectory(translated_path)
    if exists("*mkdir")
      echo "Create dir " . translated_path
      call mkdir(translated_path, "p")
    else
      echo "mkdir missing"
    endif
  endif

  echo altbufname
  if filereadable(altbufname)
    exe 'edit ' . altbufname
    $
  else
    enew
    exe 'write ' . altbufname
  endif
  " set up local buffer switch
  nnoremap <buffer> <leader>m :call PrepareSubstitution()<cr>
  let b:orig_buffer_name = curbufname
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

function! ExtractString(type, subst, ...)
  let subst = a:subst
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
  normal Go
  exe 'normal i' . subst . ':'
  pu
  normal k$J==
  exe 'b ' . b:orig_buffer_name

  exe "normal gvc<%= t('. " . subst . "') %>\<esc>"

  let &selection = sel_save
  let @@ = reg_save

endfunction

vmap <silent> <leader>m :<C-U>call ExtractString(visualmode(), 1)<CR>
nmap <silent> <leader>m :set opfunc=ExtractString<CR>g@

