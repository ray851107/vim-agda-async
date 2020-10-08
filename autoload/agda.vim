" Copyright (C) 2019  ray851107
"
" This file is part of vim-agda-async.
"
" vim-agda-async is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" vim-agda-async is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with vim-agda-async.  If not, see <https://www.gnu.org/licenses/>.

function agda#start()
  if !exists('b:agda_ctx')
    let l:ctx = {}
    let l:ctx.buf = bufnr('%')
    let l:ctx.interaction_point_ids = []
    let l:ctx.job = job_start(
      \ ['agda', '--interaction-json'],
      \ {'out_cb': function('s:handle_response', [l:ctx])})
    let l:ctx.ch = job_getchannel(l:ctx.job)
    let b:agda_ctx = l:ctx
  endif
endfunction

function agda#stop()
  if exists('b:agda_ctx')
    call job_stop(b:agda_ctx.job)
    call agda#highlight#clear(b:agda_ctx.buf)
    call agda#definition#clear(b:agda_ctx.buf)
    unlet b:agda_ctx
  endif
endfunction

function agda#restart()
  call agda#stop()
  call agda#start()
endfunction

function s:get_ctx()
  if !exists('b:agda_ctx')
    call agda#start()
  endif
  return b:agda_ctx
endfunction

" commands
function agda#load()
  update
  call s:send_command(
    \ ['Cmd_load', s:encode_haskell_string(expand('%')), '[]'])
endfunction

function agda#compile()
  update
  call s:send_command(
    \ ['Cmd_compile', 'MAlonzo', s:encode_haskell_string(expand('%')), '[]'])
endfunction

function agda#constraints()
  call s:send_command(['Cmd_constraints'])
endfunction

function agda#metas()
  call s:send_command(['Cmd_metas'])
endfunction

function agda#show_module_contents_toplevel(rewrite)
  let l:module_name = s:encode_haskell_string(input('Module name: '))
  call s:send_command(
    \ ['Cmd_show_module_contents_toplevel', a:rewrite, l:module_name])
endfunction

function agda#search_about_toplevel(rewrite)
  let l:name = s:encode_haskell_string(input('Name: '))
  call s:send_command(
    \ ['Cmd_search_about_toplevel', a:rewrite, l:name])
endfunction

function agda#solveAll(rewrite)
  call s:send_command(['Cmd_solveAll', a:rewrite])
endfunction

function agda#autoAll()
  call s:send_command(['Cmd_autoAll'])
endfunction

function agda#infer_toplevel(rewrite)
  let l:expression = s:encode_haskell_string(input('Expression: '))
  call s:send_command(
    \ ['Cmd_infer_toplevel', a:rewrite, l:expression])
endfunction

function agda#compute_toplevel(compute_mode)
  let l:expression = s:encode_haskell_string(input('Expression: '))
  call s:send_command(
    \ ['Cmd_compute_toplevel', a:compute_mode, l:expression])
endfunction

function agda#why_in_scope_toplevel()
  let l:name = s:encode_haskell_string(input('Name: '))
  call s:send_command(
    \ ['Cmd_why_in_scope_toplevel', l:name])
endfunction

function agda#show_version()
  call s:send_command(['Cmd_show_version'])
endfunction

function agda#abort()
  call s:send_command(['Cmd_abort'])
endfunction

function agda#toggle_implicit_args()
  call s:send_command(['ToggleImplicitArgs'])
endfunction

" goal commands
function agda#solveOne(rewrite)
  call s:goal_command(['Cmd_solveOne', a:rewrite])
endfunction

function agda#autoOne()
  call s:goal_command(['Cmd_autoOne'])
endfunction

function agda#give(use_force)
  call s:goal_command(['Cmd_give', a:use_force])
endfunction

function agda#refine()
  call s:goal_command(['Cmd_refine'])
endfunction

function agda#intro(pmlambda)
  call s:goal_command(['Cmd_intro', a:pmlambda])
endfunction

function agda#refine_or_intro(pmlambda)
  call s:goal_command(['Cmd_refine_or_intro', a:pmlambda])
endfunction

function agda#context(rewrite)
  call s:goal_command(['Cmd_context', a:rewrite])
endfunction

function agda#helper_function(rewrite)
  call s:goal_command(['Cmd_helper_function', a:rewrite])
endfunction

function agda#infer(rewrite)
  call s:goal_command(['Cmd_infer', a:rewrite])
endfunction

function agda#goal_type(rewrite)
  call s:goal_command(['Cmd_goal_type', a:rewrite])
endfunction

function agda#elaborate_give(rewrite)
  call s:goal_command(['Cmd_elaborate_give', a:rewrite])
endfunction

function agda#goal_type_context(rewrite)
  call s:goal_command(['Cmd_goal_type_context', a:rewrite])
endfunction

function agda#goal_type_context_infer(rewrite)
  call s:goal_command(['Cmd_goal_type_context_infer', a:rewrite])
endfunction

function agda#goal_type_context_check(rewrite)
  call s:goal_command(['Cmd_goal_type_context_check', a:rewrite])
endfunction

function agda#show_module_contents(rewrite)
  call s:goal_command(['Cmd_show_module_contents', a:rewrite])
endfunction

function agda#make_case()
  call s:goal_command(['Cmd_make_case'])
endfunction

function agda#compute(compute_mode)
  call s:goal_command(['Cmd_compute', a:compute_mode])
endfunction

function agda#why_in_scope()
  call s:goal_command(['Cmd_why_in_scope'])
endfunction

" 'maybe toplevel' commands
function agda#solve_maybe_all(rewrite)
  call s:goal_command(
    \ ['Cmd_solveOne', a:rewrite],
    \ function('agda#solveAll', [a:rewrite]))
endfunction

function agda#auto_maybe_all()
  call s:goal_command(['Cmd_autoOne'], function('agda#autoAll'))
endfunction

function agda#infer_maybe_toplevel(rewrite)
  call s:goal_command(
    \ ['Cmd_infer', a:rewrite],
    \ function('agda#infer_toplevel', [a:rewrite]))
endfunction

function agda#why_in_scope_maybe_toplevel()
  call s:goal_command(
    \ ['Cmd_why_in_scope'],
    \ function('agda#why_in_scope_toplevel'))
endfunction

function agda#show_module_contents_maybe_toplevel(rewrite)
  call s:goal_command(
    \ ['Cmd_show_module_contents', a:rewrite],
    \ function('agda#show_module_contents_toplevel', [a:rewrite]))
endfunction

function agda#compute_maybe_toplevel(compute_mode)
  call s:goal_command(
    \ ['Cmd_compute', a:compute_mode],
    \ function('agda#compute_toplevel', [a:compute_mode]))
endfunction

function s:goal_command(cmd, ...)
  let l:goals = agda#goal#get_all(bufnr('%'))
  let l:goal_index = agda#goal#find_current(l:goals)
  if l:goal_index != -1
    let l:goal_name = s:get_ctx().interaction_point_ids[l:goal_index]
    let l:goal_body = agda#goal#get_body(goals[l:goal_index])
    call s:send_command(a:cmd + [
      \ l:goal_name,
      \ 'noRange',
      \ s:encode_haskell_string(l:goal_body)
    \ ])
  elseif a:0 > 0
    " call the second argument if not in a goal
    call a:1()
  else
    echohl ErrorMsg
    echom 'For this command, please place the cursor in a goal'
    echohl None
  endif
endfunction

function s:send_command(cmd)
  let l:args = [
    \ 'IOTCM',
    \ s:encode_haskell_string(expand('%')),
    \ 'NonInteractive',
    \ 'Direct',
    \ '(' . join(a:cmd) . ')' ]

  call ch_sendraw(s:get_ctx().ch, join(l:args) . "\n")
endfunction

function s:encode_haskell_string(str)
  return '"' . substitute(a:str, '.', {c -> '\' . char2nr(c[0], v:true)}, 'g') . '"'
endfunction


function s:handle_response(ctx, ch, msg)
  let l:msg = s:parse_response(a:msg)
  if type(l:msg) == v:t_dict && has_key(s:handler, l:msg.kind)
    call s:handler[l:msg.kind](a:ctx, l:msg)
  endif
endfunction

function s:parse_response(msg)
  return json_decode(substitute(a:msg, '^JSON> ', '', ''))
endfunction

let s:handler = {}
function s:handler.RunningInfo(ctx, msg)
  for l:line in split(a:msg.message, "\n")
    echom l:line
  endfor
endfunction

function s:handler.ClearHighlighting(ctx, msg)
  call agda#highlight#clear(a:ctx.buf)
endfunction

function s:handler.InteractionPoints(ctx, msg)
  call map(a:msg.interactionPoints, { key, val -> val.id })
  let a:ctx.interaction_point_ids = a:msg.interactionPoints
endfunction

function s:handler.HighlightingInfo(ctx, msg)
  call agda#highlight#highlight(a:ctx.buf, a:msg.info.payload)
endfunction

function s:handler.GiveAction(ctx, msg)
  let l:goal_index = index(a:ctx.interaction_point_ids, a:msg.interactionPoint.id)
  if l:goal_index != -1
    let l:goal = agda#goal#get_all(a:ctx.buf)[l:goal_index]
    call agda#goal#set_body(a:ctx.buf, l:goal, a:msg.giveResult.str)
  endif
endfunction

function s:handler.MakeCase(ctx, msg)
  let l:goal_index = index(a:ctx.interaction_point_ids, a:msg.interactionPoint.id)
  if l:goal_index != -1
    let l:goal = agda#goal#get_all(a:ctx.buf)[l:goal_index]
    call agda#goal#make_case(a:ctx.buf, l:goal, a:msg.clauses)
  endif
endfunction

function s:handler.DisplayInfo(ctx, msg)
  call agda#preview#display_info(a:msg.info)
endfunction
