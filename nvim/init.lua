
-- pre install
-- go install golang.org/x/tools/gopls@latest
-- export PATH=$PATH:$HOME/go/bin
-- https://github.com/akinsho/toggleterm.nvim
-- https://github.com/akinsho/bufferline.nvim
-- https://github.com/folke/which-key.nvim
-- https://github.com/ahmedkhalf/project.nvim
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
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },

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
  -- Rust
  { "simrat39/rust-tools.nvim" },
  -- File Explorer
  { "nvim-tree/nvim-tree.lua" },
  -- codium https://github.com/Exafunction/windsurf.nvim
  --"Exafunction/codeium.vim",
  { "github/copilot.vim" },
  -- Todo
  {
    "folke/todo-comments.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("todo-comments").setup {}
      require("telescope").load_extension("todo-comments")
    end,
    event = "VeryLazy", 
  },
  --
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  --
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  --
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
  },
  -- icon
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  -- 
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "go", "rust", "c", "lua", "bash" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
})

-- Basic LSP setup (example: gopls for Go)
-- local lspconfig = require("lspconfig")
-- lspconfig.gopls.setup {}
-- lspconfig.rust_analyzer.setup {}
-- Setup LSP capabilities for autocomplete
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Go
require("lspconfig").gopls.setup({
  capabilities = capabilities,
})

-- Rust
require("rust-tools").setup({
  server = {
    capabilities = capabilities,
    on_attach = function(_, bufnr)
      local rt = require("rust-tools")
      vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })
      vim.keymap.set("n", "<leader>ca", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy",
        },
      },
    },
  },
})

-- C/C++
require("lspconfig").clangd.setup({ })

-- JS/TS
require("lspconfig").tsserver.setup({
  capabilities = capabilities,
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false -- اگر با prettier یا eslint میخوای فرمت کنی
  end,
})

-- Bash
require("lspconfig").bashls.setup({ capabilities = capabilities })

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

vim.keymap.set("n", "<leader>t", function()
  require("telescope").extensions["todo-comments"].todo()
end, { desc = "Show TODOs" })

vim.keymap.set("n", "<leader>s", function()
  require("telescope.builtin").live_grep()
end, { desc = "Live Grep Search" })

vim.keymap.set("n", "<leader>g", function()
  require("telescope.builtin").git_commits()
end, { desc = "Git commit history" })

vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = {"*.go"},
  callback = function()
    vim.lsp.buf.format()
  end,
})

vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { expr = true, silent = true })


-- Some nice options
vim.o.number = true
vim.o.relativenumber = true


vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevel = 99 

vim.cmd("colorscheme tokyonight-night")
