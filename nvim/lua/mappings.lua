require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- Keep `;` free for f/t repeat; use `;;` to open command mode quickly
map({ "n", "v" }, ";;", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
