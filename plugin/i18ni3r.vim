let b:i18_buffer_name = ''

function! Initialise_i18ni3r()
  let curbufname = expand('%')
  let path = expand('%:p')
  let translated_path = substitute(path, 'app/views/\(.*\)/_\?\(.*\)\.html.*', 'config/locales/\1/\2/', '')
  let altbufname = translated_path . "da.yml"

  if filereadable(altbufname)
    exe 'edit ' . altbufname
    let b:buffer_indent = 'none'
    $
  else
    enew
    " Prepare translation file
    exe "normal ida:"
    let t_indent='  '
    let t_path=substitute(translated_path, '.*config\/locales\/', '', '')
    for transkey in split(t_path, '/')
      exe "normal o" . t_indent . transkey . ':'
      let t_indent=t_indent . '  '
    endfor
    let b:buffer_indent = t_indent
    exe 'write ' . altbufname
  endif
  let b:i18_buffer_name = curbufname
  exe 'buffer ' . curbufname
  let b:i18_buffer_name = altbufname
endfunction

function! ExtractString(type, ...)
  call Initialise_i18ni3r()
  let subst = input('I18n key: ')
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
  exe 'normal i' . subst . ': '
  normal p
  if b:buffer_indent == 'none'
    normal ==
  else
    exe 'normal 0i' . b:buffer_indent
  endif
  silent w
  exe 'b ' . b:i18_buffer_name

  exe "normal gvc<%= t('." . subst . "') %>\<esc>"

  " Open the other buffer if it is not open
  if bufwinnr(b:i18_buffer_name) < 0
    exe "rightb vs " . b:i18_buffer_name
  endif

  let &selection = sel_save
  let @@ = reg_save

endfunction

vmap <silent> <leader>m :<C-U>call ExtractString(visualmode(), 1)<CR>
