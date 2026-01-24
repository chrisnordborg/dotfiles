---@diagnostic disable: missing-fields

----------------------------------------------------------------
-- Leader
----------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

----------------------------------------------------------------
-- Options
----------------------------------------------------------------
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.o.scrolloff = 10
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.signcolumn = "yes"

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.hlsearch = true
vim.opt.breakindent = true
vim.opt.wrap = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.textwidth = 80

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.INFO]  = " ",
      [vim.diagnostic.severity.HINT]  = " ",
    },
  },
  virtual_text = true,
})

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

----------------------------------------------------------------
-- lazy.nvim bootstrap
----------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

----------------------------------------------------------------
-- Plugins
----------------------------------------------------------------
require("lazy").setup({

  ----------------------------------------------------------------
  -- Treesitter
  ----------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false, -- load at startup to avoid "module not found"
    config = function()
      local ts = require("nvim-treesitter.configs")
      ts.setup({
        auto_install = true,
      })
      -- Auto-install missing parsers
      vim.cmd([[autocmd BufEnter * TSUpdateSync]])
    end,
  },

  ----------------------------------------------------------------
  -- Completion (blink.cmp)
  ----------------------------------------------------------------
  {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("blink.cmp").setup({
        completion = { documentation = { auto_show = true } },
        keymap = {
          ['<C-p>']     = { 'select_prev', 'fallback_to_mappings' },
          ['<C-n>']     = { 'select_next', 'fallback_to_mappings' },
          ['<C-y>']     = { 'select_and_accept', 'fallback' },
          ['<C-e>']     = { 'cancel', 'fallback' },
          ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
          ['<Tab>']     = { 'snippet_forward', 'fallback' },
          ['<S-Tab>']   = { 'snippet_backward', 'fallback' },
          ['<C-b>']     = { 'scroll_documentation_up', 'fallback' },
          ['<C-f>']     = { 'scroll_documentation_down', 'fallback' },
          ['<C-k>']     = { 'show_signature', 'hide_signature', 'fallback' },
        },
        fuzzy = { implementation = "lua" },
      })
    end,
  },

  ----------------------------------------------------------------
  -- LSP + Mason
  ----------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      local runtime_files = vim.api.nvim_get_runtime_file("", true)
      local lib = {}
      for _, path in ipairs(runtime_files) do lib[path] = true end

      local lsp_servers = {
        lua_ls = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { library = lib, checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
        clangd = {},
        rust_analyzer = {},
        gopls = {},
      }

      -- Mason setup
      require("mason").setup()
      require("mason-lspconfig").setup()
      require("mason-tool-installer").setup({
        ensure_installed = vim.tbl_keys(lsp_servers),
        auto_update = true,
        run_on_start = true, -- auto-install on first launch
      })

      -- Configure LSP servers
      for server, config in pairs(lsp_servers) do
        vim.lsp.config(server, {
          settings = config,
          on_attach = function(_, bufnr)
            vim.keymap.set("n", "grd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
            vim.keymap.set("n", "grf", vim.lsp.buf.format,     { buffer = bufnr, desc = "Format buffer" })
          end,
        })
      end
    end,
  },

  ----------------------------------------------------------------
  -- Telescope
  ----------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("telescope").setup({})
      local pickers = require("telescope.builtin")
      vim.keymap.set("n", "<leader>sp", pickers.builtin,    { desc = "[S]earch [P]ickers" })
      vim.keymap.set("n", "<leader>sb", pickers.buffers,    { desc = "[S]earch [B]uffers" })
      vim.keymap.set("n", "<leader>sf", pickers.find_files, { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>sw", pickers.grep_string, { desc = "[S]earch [W]ord" })
      vim.keymap.set("n", "<leader>sg", pickers.live_grep,  { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>sr", pickers.resume,     { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>sh", pickers.help_tags,  { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sm", pickers.man_pages,  { desc = "[S]earch [M]anuals" })
    end,
  },

  ----------------------------------------------------------------
  -- which-key
  ----------------------------------------------------------------
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup({
        spec = {
          { "<leader>s", group = "[S]earch", icon = { icon = "", color = "green" } },
        },
      })
    end,
  },

})

