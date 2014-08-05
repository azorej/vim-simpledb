vnoremap <buffer> <F5> :SimpleDBExecuteSql<cr>
nnoremap <buffer> <F5> m':SimpleDBExecuteSql <cr>g`'
nnoremap <buffer> <leader><F5> m':'{,'}SimpleDBExecuteSql<cr>g`'

vnoremap <buffer> <C-F5> :SimpleDBExecuteSqlInNewWindow<cr>
nnoremap <buffer> <C-F5> m':SimpleDBExecuteSqlInNewWindow <cr>g`'
nnoremap <buffer> <leader><C-F5> m':'{,'}SimpleDBExecuteSqlInNewWindow<cr>g`'

vnoremap <buffer> <S-F5> :SimpleDBExecuteSqlSilence<cr>
nnoremap <buffer> <S-F5> m':SimpleDBExecuteSqlSilence <cr>g`'
nnoremap <buffer> <leader><S-F5> m':'{,'}SimpleDBExecuteSqlSilence<cr>g`'

nnoremap <buffer> gd :SimpleDBGetDescription <cr>
