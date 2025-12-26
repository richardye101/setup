-- VimTeX configuration goes here, e.g. zathura (linux)
vim.g.vimtex_view_method = "skim"
-- Compiler (latexmk is default and recommended)
vim.g.vimtex_compiler_method = "latexmk"
-- Store auxiliary files in a build directory
vim.g.vimtex_compiler_latexmk = {
    aux_dir = "build",
    out_dir = "build",
    continuous = 1,
}
