-- pre install
-- go install golang.org/x/tools/gopls@latest
-- export PATH=$PATH:$HOME/go/bin
-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  -- LSP Config
  { "neovim/nvim-lspconfig" },

  -- Autocomplete Engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
    },
  },

  -- File Explorer
  { "nvim-tree/nvim-tree.lua" },
  -- codium https://github.com/Exafunction/windsurf.nvim
  "Exafunction/codeium.vim",
  { "github/copilot.vim" },
})

-- Basic LSP setup (example: gopls for Go)
local lspconfig = require("lspconfig")
lspconfig.gopls.setup {}

-- Basic nvim-cmp setup
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "buffer" },
  }),
})

-- nvim-tree setup
require("nvim-tree").setup()

-- Basic keymap for nvim-tree toggle
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { expr = true, silent = true })

-- Some nice options
vim.o.number = true
vim.o.relativenumber = true
