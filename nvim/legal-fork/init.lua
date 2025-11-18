-- Set leader key
vim.g.mapleader = " "

-- Basic Neovim settings
vim.opt.guicursor = ""
vim.opt.syntax = "on"
vim.opt.tabstop = 4
vim.opt.filetype = "on"
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.spell = true
vim.opt.ruler = true
vim.opt.list = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.scrolloff = 8
vim.opt.colorcolumn = "80"
vim.opt.laststatus = 2
vim.opt.foldenable = false
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.breakindent = true  -- Added for smarter wrapping with indentation

-- Neovide settings
vim.g.neovide_transparency = 0.5
vim.g.transparency = 0.8
vim.g.neovide_background_color = "#0f1117" .. string.format("%x", math.floor(255 * vim.g.transparency))
vim.opt.guifont = "CaskaydiaCove Nerd Font:h13"

-- Colorscheme
vim.cmd("colorscheme industry")

-- Transparent background
vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
]]

-- Lazy.nvim setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
require("lazy").setup({
  { "folke/tokyonight.nvim", branch = "main" },
  { "morhetz/gruvbox" },
  { "preservim/nerdtree" },
  { "vim-airline/vim-airline" },
  { "vim-airline/vim-airline-themes" },
  { "vimwiki/vimwiki" },
  { "tbabej/taskwiki" },
  { "farseer90718/vim-taskwarrior" },
  { "plasticboy/vim-markdown" },
  { "powerman/vim-plugin-AnsiEsc" },
  { "majutsushi/tagbar" },
  { "tpope/vim-fugitive" },
  { "cormacrelf/vim-colors-github" },
  { "sonph/onehalf", rtp = "vim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "markdown", "markdown_inline" },
      highlight = { enable = true },
    })
  end },
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope.nvim" },
  { "xiyaowong/transparent.nvim" },
  { "godlygeek/tabular" },  -- Added for table formatting in vim-markdown
  { "iamcco/markdown-preview.nvim", cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" }, ft = { "markdown" }, build = function() vim.fn["mkdp#util#install"]() end },  -- Added for Markdown preview
  { "preservim/vim-pencil" },  -- Added for better writing experience
}, {
  install = { colorscheme = { "industry" } },
})

-- Keymappings for Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

-- NERDTree keymapping
vim.keymap.set("n", "<C-f>", ":NERDTreeToggle<CR>", {})

-- TaskWiki keymapping
vim.keymap.set("n", "<C-l>", ":TaskWikiToggle<CR>", {})

-- Fugitive keymappings
vim.keymap.set("n", "<leader>gf", ":diffget //2<CR>", {})
vim.keymap.set("n", "<leader>gj", ":diffget //3<CR>", {})
vim.keymap.set("n", "<leader>gs", ":G<CR>", {})

-- VimWiki configuration
vim.g.vimwiki_list = {
  {
    path = "~/doc/",
    syntax = "markdown",
    ext = ".md",
  },
}
vim.g.vimwiki_ext2syntax = {
  [".md"] = "markdown",
  [".markdown"] = "markdown",
  [".mdown"] = "markdown",
}
vim.g.vimwiki_markdown_link_ext = 1
vim.g.vimwiki_folding = ""

-- TaskWiki configuration
vim.g.taskwiki_markup_syntax = "markdown"
vim.g.taskwiki_disable_concealcursor = "nc"

-- Airline configuration
vim.g.airline_powerline_fonts = 1
vim.g.airline_theme = "raven"
