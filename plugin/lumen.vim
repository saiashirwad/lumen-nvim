if exists('g:loaded_lumen_nvim') | finish | endif

command! -nargs=* LumenDiff lua require('lumen').lumen_diff({<f-args>})
command! -nargs=* LumenDiffCurrentFile lua require('lumen').lumen_diff_current_file({<f-args>})

let g:loaded_lumen_nvim = 1
