vim.g.mapleader = " "
vim.g.maplocalleader = " "

local config_group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Editing
vim.opt.mouse = ""
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 10
vim.opt.wrap = false
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true

vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.confirm = true
vim.opt.updatetime = 300
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menuone", "noselect", "popup" }

vim.diagnostic.config({
    virtual_text =  { prefix = '       ●' },
    update_in_insert = false,
    signs = true,
    underline = true,
    severity_sort = true,
    float = { border = "rounded", source = "if_many" },
})

vim.keymap.set("n", "<Esc>", function()
    vim.cmd("nohlsearch")
    vim.api.nvim_echo({ { "" } }, false, {})
end, { desc = "Clear search" })

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic" })

for _, mode in ipairs({ "n", "i" }) do
    local prefix = mode == "i" and "<Esc>" or ""
    for _, direction in ipairs({ "h", "j", "k", "l" }) do
        vim.keymap.set(mode, "<A-" .. direction .. ">", prefix .. "<C-w>" .. direction)
    end
end

for _, direction in ipairs({ "h", "j", "k", "l" }) do
    vim.keymap.set("t", "<A-" .. direction .. ">", "<C-\\><C-n><C-w>" .. direction)
end

-- Plugins
vim.api.nvim_create_autocmd("PackChanged", {
    group = config_group,
    desc = "Update Tree-sitter parsers with the plugin",
    callback = function(event)
        local data = event.data
        if data.spec.name ~= "nvim-treesitter" or data.kind ~= "update" then
            return
        end

        local ok, err = pcall(function()
            if not data.active then
                vim.cmd("packadd nvim-treesitter")
            end
            require("nvim-treesitter").update()
        end)
        if not ok then
            vim.notify("Tree-sitter update failed: " .. tostring(err), vim.log.levels.WARN)
        end
    end,
})

if vim.pack then
    local ok, err = pcall(vim.pack.add, {
        { src = "https://github.com/rebelot/kanagawa.nvim" },
        { src = "https://github.com/neovim/nvim-lspconfig" },
        { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    }, { load = true, confirm = false })

    if not ok then
        vim.notify("Plugin setup failed: " .. tostring(err), vim.log.levels.WARN)
    end
else
    vim.notify("This config requires Neovim 0.12 or newer", vim.log.levels.ERROR)
end

-- Syntax
local treesitter_ok, treesitter = pcall(require, "nvim-treesitter")
if treesitter_ok then
    treesitter.setup({})

    local parsers = {
        "bash",
        "c",
        "css",
        "html",
        "javascript",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "rust",
    }
    treesitter.install(parsers)

    vim.api.nvim_create_autocmd("FileType", {
        group = config_group,
        pattern = { "sh", "c", "css", "html", "javascript", "lua", "markdown", "python", "rust" },
        desc = "Enable Tree-sitter highlighting",
        callback = function(event)
            pcall(vim.treesitter.start, event.buf)
        end,
    })
end

if not pcall(vim.cmd.colorscheme, "kanagawa-dragon") then
    vim.cmd.colorscheme("habamax")
end

-- Rust
vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { { "Cargo.toml", "rust-project.json" }, ".git" },
    settings = {
        ["rust-analyzer"] = {
            cargo = { targetDir = true },
            check = { command = "clippy" },
        },
    },
})
vim.lsp.enable("rust_analyzer")

vim.api.nvim_create_autocmd("LspAttach", {
    group = config_group,
    desc = "Configure LSP features",
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
            return
        end

        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
        end

        map("n", "gd", vim.lsp.buf.definition, "Definition")

        if client:supports_method("textDocument/formatting", event.buf) then
            map("n", "<leader>f", function()
                vim.lsp.buf.format({ bufnr = event.buf, id = client.id, timeout_ms = 3000 })
            end, "Format")
        end

        if client:supports_method("textDocument/completion", event.buf) then
            vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
            map("i", "<C-Space>", vim.lsp.completion.get, "Complete")
        end

        if client:supports_method("textDocument/inlayHint", event.buf) then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
        end
    end,
})

vim.keymap.set("n", "<leader>ih", function()
    local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

-- Cargo
local function hide_cargo_ui()
    if vim.t.user_cargo_terminal ~= true then
        return
    end

    if vim.t.user_cargo_ui == nil then
        vim.t.user_cargo_ui = {
            laststatus = vim.o.laststatus,
            ruler = vim.o.ruler,
            showcmd = vim.o.showcmd,
            showmode = vim.o.showmode,
            showtabline = vim.o.showtabline,
        }
    end

    vim.o.laststatus = 0
    vim.o.ruler = false
    vim.o.showcmd = false
    vim.o.showmode = false
    vim.o.showtabline = 0
    vim.wo.cursorline = false
    vim.wo.list = false
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.scrolloff = 0
    vim.wo.signcolumn = "no"
end

local function restore_cargo_ui()
    local ui = vim.t.user_cargo_ui
    if vim.t.user_cargo_terminal ~= true or type(ui) ~= "table" then
        return
    end

    vim.o.laststatus = ui.laststatus
    vim.o.ruler = ui.ruler
    vim.o.showcmd = ui.showcmd
    vim.o.showmode = ui.showmode
    vim.o.showtabline = ui.showtabline
    vim.t.user_cargo_ui = nil
end

vim.api.nvim_create_autocmd("TabEnter", {
    group = config_group,
    callback = hide_cargo_ui,
})

vim.api.nvim_create_autocmd("TabLeave", {
    group = config_group,
    callback = restore_cargo_ui,
})

hide_cargo_ui()

local function terminal_tab(argv, cwd)
    vim.cmd("tabnew")

    local buffer = vim.api.nvim_get_current_buf()
    vim.bo[buffer].bufhidden = "wipe"
    vim.bo[buffer].buflisted = false
    vim.bo[buffer].swapfile = false

    local job = vim.fn.jobstart(argv, { term = true, cwd = cwd })
    if job <= 0 then
        vim.cmd("tabclose!")
        vim.notify("Could not start terminal job", vim.log.levels.ERROR)
        return
    end

    vim.t.user_cargo_terminal = true
    hide_cargo_ui()
    vim.cmd("startinsert")
    vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = buffer, nowait = true })
    vim.keymap.set("n", "q", "<cmd>tabclose!<CR>", { buffer = buffer, silent = true })
end

local function cargo(...)
    if vim.fn.executable("cargo") == 0 then
        vim.notify("cargo is not installed", vim.log.levels.ERROR)
        return
    end

    local current_dir = vim.uv.cwd()
    local root = vim.fs.root(0, { "Cargo.toml" })
        or (current_dir and vim.fs.root(current_dir, { "Cargo.toml" }))
    if not root then
        vim.notify("No Cargo.toml found", vim.log.levels.WARN)
        return
    end

    local saved, save_err = pcall(vim.cmd, "silent wall")
    if not saved then
        vim.notify("Could not save files: " .. tostring(save_err), vim.log.levels.ERROR)
        return
    end

    local argv = { "cargo" }
    vim.list_extend(argv, { ... })
    terminal_tab(argv, root)
end

vim.keymap.set("n", "<leader>rr", function()
    cargo("run", "--quiet")
end, { desc = "Cargo run" })

vim.keymap.set("n", "<leader>rt", function()
    cargo("test")
end, { desc = "Cargo test" })

vim.keymap.set("n", "<leader>rc", function()
    cargo("clippy")
end, { desc = "Cargo clippy" })

vim.keymap.set("n", "<leader>rb", function()
    cargo("build")
end, { desc = "Cargo build" })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = config_group,
    desc = "Highlight yanked text",
    callback = function()
        vim.hl.on_yank()
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = config_group,
    pattern = { "lua", "sh" },
    desc = "Use two-space indentation",
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
})

-- Shell
vim.api.nvim_create_user_command("ShellCheck", function()
    if vim.fn.executable("shellcheck") == 0 then
        vim.notify("shellcheck is not installed", vim.log.levels.ERROR)
        return
    end

    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
        vim.notify("Buffer has no file name", vim.log.levels.WARN)
        return
    end

    local saved, save_err = pcall(vim.cmd, "silent update")
    if not saved then
        vim.notify("Could not save file: " .. tostring(save_err), vim.log.levels.ERROR)
        return
    end

    local lines = vim.fn.systemlist({ "shellcheck", "--format=gcc", file })
    local exit_code = vim.v.shell_error
    if exit_code > 1 then
        vim.notify("ShellCheck failed:\n" .. table.concat(lines, "\n"), vim.log.levels.ERROR)
        return
    end

    vim.fn.setqflist({}, " ", {
        title = "ShellCheck",
        lines = lines,
        efm = "%f:%l:%c: %m",
    })

    if #lines == 0 then
        vim.cmd("silent! cclose")
        vim.notify("ShellCheck: no issues")
    else
        vim.cmd("copen")
    end
end, { desc = "Check the current shell script", force = true })
