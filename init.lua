-- Set the leader key to space
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.modeline = true
vim.opt.modelines = 5 -- Check first and last 5 lines of a file for modeline commands
-- Define a custom status line for an aesthetic look with file information
vim.opt.statusline = "%f %y [%{&fileencoding}] %l/%L [%p%%]"
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })

-- Plugin manager setup (using packer.nvim)
-- Install packer if you haven't already (run this command in your terminal):
-- git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Gruvbox theme
  use 'morhetz/gruvbox'

  -- LSP configuration and Rust support
  use 'neovim/nvim-lspconfig' -- LSP configurations
  use 'simrat39/rust-tools.nvim' -- Rust tools for LSP

  -- Fuzzy finder for file search
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  use {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {
        -- Your configuration comes here
        -- or leave it empty to use the default settings
        detection_methods = { "pattern" },  -- Detect projects based on patterns
        patterns = { ".git", "Makefile", "package.json" },  -- Define project root patterns
      }
  end
  }

  use {
    "SmiteshP/nvim-navic",
    requires = "neovim/nvim-lspconfig"
  }
  use 'hrsh7th/nvim-cmp'              -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp'          -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-buffer'            -- Buffer completion source
  use 'hrsh7th/cmp-path'              -- Path completion source
  use 'hrsh7th/cmp-cmdline'           -- Command-line completion source
  use 'L3MON4D3/LuaSnip'              -- Snippet engine
  use 'saadparwaiz1/cmp_luasnip'      -- Snippet completion source
  use 'yorickpeterse/nvim-window'
  use {
    'NeogitOrg/neogit',
    requires = {
      'nvim-lua/plenary.nvim',          -- Required dependency
      'sindrets/diffview.nvim',         -- Optional: for enhanced diff views
      'nvim-telescope/telescope.nvim',  -- Optional: for telescope integration
    },
    config = function()
      require('neogit').setup()
    end
  }
    -- vim-airline plugin
  use {
    'vim-airline/vim-airline',
    config = function()
      -- Enable the tabline extension
      vim.g['airline#extensions#tabline#enabled'] = 1
      -- Set a theme (optional)
      vim.g['airline_theme'] = 'dark'
    end
  }

  -- vim-airline-themes plugin (optional)
  use 'vim-airline/vim-airline-themes'
  use {'nvim-telescope/telescope-ui-select.nvim' }
end)

-- Gruvbox theme setup
vim.cmd('colorscheme gruvbox')

-- lsp code action 
-- This is your opts table
require("telescope").setup {
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {}
    }
  }
}
-- To get ui-select loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("ui-select")

-- LSP setup for Rust
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.zls.setup{
  capabilities = capabilities, -- Enables LSP autocompletion
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("Format", { clear = true }),
        buffer = bufnr,
        callback = function() vim.lsp.buf.format({ bufnr = bufnr }) end
      })
    end
    -- Add additional LSP keymaps here if needed
    local opts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', '<leader>cd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>cn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
  end

}

-- Example for Rust
lspconfig.rust_analyzer.setup {
  capabilities = capabilities, -- Enables LSP autocompletion
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("Format", { clear = true }),
        buffer = bufnr,
        callback = function() vim.lsp.buf.format({ bufnr = bufnr }) end
      })
    end
    -- Add additional LSP keymaps here if needed
    local opts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', '<leader>cd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>cn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
  end
}

-- Example for Python
lspconfig.pyright.setup {
  capabilities = capabilities, -- Enables LSP autocompletion
}

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  focusable = false,
  -- Trigger hover after 3 seconds (3000 ms)
  update_in_insert = false,
  debounce = 3000,
})

local navic = require("nvim-navic")
vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
require('lspconfig').rust_analyzer.setup{
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
      navic.attach(client, bufnr)
    end
  end
}

require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')
require('telescope').load_extension('projects')

-- Configure nvim-cmp for autocompletion
local cmp = require'cmp'
cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require('luasnip').lsp_expand(args.body)  -- For `luasnip` users
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),     -- Trigger completion menu
    ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Confirm completion
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Confirm completion
    ['<C-n>'] = cmp.mapping.select_next_item(),  -- Navigate through suggestions
    ['<C-p>'] = cmp.mapping.select_prev_item(),  -- Navigate backwards
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },         -- LSP completion source
    { name = 'luasnip' },          -- Snippet completion source
  }, {
    { name = 'buffer' },           -- Buffer completion source
    { name = 'path' }              -- Path completion source
  })
})

require('nvim-window').setup({
  -- The characters available for hinting windows.
  chars = {
    'q', 'w', 'e', 'r', 't', 'y'
  },
})

-- Keymap to open file search with Ctrl+r in normal mode as well
local builtin = require('telescope.builtin')
local previewers = require('telescope.previewers')
local window = require('nvim-window')
local neogit = require('neogit')
vim.keymap.set('n', '<leader>fS', [[:lua require('telescope.builtin').current_buffer_fuzzy_find({ default_text = vim.fn.expand('<cword>') })<CR>]], { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fs', builtin.current_buffer_fuzzy_find, { desc = 'Telescope find in file' })
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>pr', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>x', builtin.commands, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>pp', ':Telescope projects<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>cs', ':Telescope lsp_document_symbols<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>wn', ':vsp<CR>', { noremap = true, silent = true})
vim.keymap.set('n', '<leader>wd', ':q<CR>', { noremap = true, silent = true})
vim.keymap.set('n', '<leader>fw', ':w<CR>', { noremap = true, silent = true})
vim.keymap.set('n', '<leader>w1', ':only<CR>', { noremap = true, silent = true})
vim.keymap.set('n', '<leader><leader>', window.pick, {desc = 'nvim-window: Jump to window'} )
vim.keymap.set('n', '<leader>gs', neogit.open, {desc = 'open git status'} )
vim.keymap.set('n', '<leader>r', ':source $MYVIMRC<CR>', { noremap = true, silent = true })
