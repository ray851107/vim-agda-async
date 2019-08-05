nnoremap <buffer> <plug>(agda-maps)l :call agda#load()<cr>
nnoremap <buffer> <plug>(agda-maps)= :call agda#constraints()<cr>

nnoremap <buffer> <plug>(agda-maps)r :call agda#refine()<cr>
nnoremap <buffer> <plug>(agda-maps)<space> :call agda#give('WithForce')<cr>

nmap <buffer> <LocalLeader> <plug>(agda-maps)
nnoremap <buffer> ]g :call agda#next_goal()<cr>
nnoremap <buffer> [g :call agda#prev_goal()<cr>

call agda#load()
