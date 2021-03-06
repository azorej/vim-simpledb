if !exists('g:simpledb_show_timing') | let g:simpledb_show_timing = 0 | en

function! s:GenerateNewResultFileName()
        if !exists('s:result_file_nr')
          let s:result_file_nr = 1
        else
          let s:result_file_nr += 1
        endif

        let t:result_filename = '/tmp/vim-simpledb-result' . s:result_file_nr . '.pgsql'
endfunction

function! s:GetResultFileName()
        return t:result_filename
endfunction

function! s:GetResultBufferFileName()
        return '/tmp/vim-simpledb-buffer.txt'
endfunction        

function! s:GetResultErrorFileName()
        return '/tmp/vim-simpledb-error.txt'
endfunction        

function! s:GetQuery(first, last)
  let query = ''
  let lines = getline(a:first, a:last)
  for line in lines
    "if line !~ '--.*'
      let query .= line . "\n"
    "endif
  endfor
  return query
endfunction

function! s:GetConnectionString()
  let conprops = matchstr(getline(1), '--\s*\zs.*')
  let conprops = substitute(conprops, "db:\\w\\+", "", "")
  return conprops
endfunction

function! s:GetColumnValue(column_name)
  let table = readfile(s:GetResultBufferFileName())
  let record_begin_pat = '^-\[ RECORD \d\+ \][-+]*'
  let record_pos = match(table, record_begin_pat)
  let value = ""

  if record_pos != -1
    let value_line_index = match(table, '^' . a:column_name . ' \+|', record_pos)
   if value_line_index != -1
      let match_list = matchlist(table[value_line_index], '| \+\(.\+\)$')
      let value = match_list[1]
    endif
  endif

  return value
endfunction

function! s:ShowResults(result_window)
  if !exists('t:result_buf_nr') || a:result_window == 2
    call s:GenerateNewResultFileName()
    let t:result_buf_nr = -1
  endif

  silent execute '!(cat ' . s:GetResultBufferFileName() . ' > ' . s:GetResultFileName() . ')'

  if bufwinnr(t:result_buf_nr) == -1
    let source_win_nr = winnr()
    exec 'silent! botright sview +setlocal\ noswapfile\ autoread ' . s:GetResultFileName() . ''
    let t:result_buf_nr = bufnr('%')
    exec bufwinnr(source_win_nr) . "wincmd w"
  endif
endfunction

function! simpledb#ExecuteSql(result_window) range
  let query = s:GetQuery(a:firstline, a:lastline)

  call s:ExecuteSql(query, a:result_window)
endfunction

function! s:ExecuteSql(query, result_window) range
  let conprops = s:GetConnectionString()

  let cmdline = s:PostgresCommand(conprops, a:query)

  silent execute '!(echo ' . getline(1) . ' > ' . s:GetResultBufferFileName() . ')'
  silent execute '!(' . cmdline . ' >> ' . s:GetResultBufferFileName() . ') 2> ' . s:GetResultErrorFileName() . ''
  silent execute '!(cat ' . s:GetResultErrorFileName() . ' >> ' . s:GetResultBufferFileName() . ')'
  if a:result_window 
    call s:ShowResults(a:result_window)
  endif

  redraw!
endfunction

function! s:PostgresCommand(conprops, query)
  if g:simpledb_show_timing == 1
    let sql_text = shellescape('\\timing on \\\ ' . a:query)
  else
    let sql_text = shellescape(a:query)
  end

  let sql_text = escape(sql_text, '%')
  let cmdline = 'echo -e ' . sql_text . '| psql ' . a:conprops
  return cmdline
endfunction

function! simpledb#GetDescription(object_name)
  let match_list = matchlist(a:object_name, '\(.\+\)\.\(.\+\)')
  let schema = match_list[1]
  let name = match_list[2]

  let query = "\\pset expanded on\n"

  let query .= "with ns as (select oid from pg_catalog.pg_namespace as ns where nspname = '" . schema ."')\n"
  let query .= "  select 'function' as type from pg_catalog.pg_proc join ns on pronamespace = ns.oid where proname = '" . name . "'\n"
  let query .= "  UNION\n"
  let query .= "  select CASE\n"
  let query .= "          WHEN relkind = 'r' THEN 'table'\n"
  let query .= "          WHEN relkind = 'i' THEN 'index'\n"
  let query .= "          WHEN relkind = 'S' THEN 'sequence'\n"
  let query .= "          WHEN relkind = 'v' THEN 'view'\n"
  let query .= "          WHEN relkind = 'c' THEN 'composite type'\n"
  let query .= "          ELSE 'error type from pg_catalog.pg_class'\n"
  let query .= "         END as type\n"
  let query .= " from pg_catalog.pg_class join ns on relnamespace = ns.oid where relname = '" . name . "'\n"
  let query .= " UNION select 'data_type' as type from pg_catalog.pg_type join ns on typnamespace  = ns.oid where typname = '" . name . "'\n"

  call s:ExecuteSql(query, 0)  

  let type = s:GetColumnValue("type")

  let query = "\\pset expanded on\n"
  if type == 'function'
    let query .= "\\sf " . a:object_name
  else
    let query .= "\\d+ " . a:object_name
  endif

  call s:ExecuteSql(query, 1)
endfunction

function! s:GetDescription()
  let word = expand("<cword>")
  let big_word = expand("<cWORD>")
  let not_a_word_pat = '[^:()\[\]{},-]*'
  let match_list = matchlist(big_word, not_a_word_pat.word.not_a_word_pat)
  let object_name = match_list[0]

  call simpledb#GetDescription(object_name)
endfunction

command! -range=% SimpleDBExecuteSql <line1>,<line2>call simpledb#ExecuteSql(1)
command! -range=% SimpleDBExecuteSqlInNewWindow <line1>,<line2>call simpledb#ExecuteSql(2)
command! -range=% SimpleDBExecuteSqlSilence <line1>,<line2>call simpledb#ExecuteSql(0)
command! SimpleDBGetDescription call s:GetDescription()
