# 🌀 Lazy local patcher

<!-- panvimdoc-ignore-start -->

![Pull Requests](https://img.shields.io/badge/Pull_Requests-Welcome-a4e400?style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/polirritmico/lazy-local-patcher.nvim/main?style=flat-square&color=62d8f1)
![GitHub issues](https://img.shields.io/github/issues/polirritmico/lazy-local-patcher.nvim?style=flat-square&color=fc1a70)

<!-- panvimdoc-ignore-end -->

## 🐧 Description

Sometimes, I need to apply small patches to a plugin to fulfill a very niche use
case or to fix something without waiting for the PR to reach upstream. However,
when doing so, Lazy can't sync the repo because there are local changes. While
Lazy provides ways to handle this (like `dev` or `dir`), they require manually
monitoring and merging upstream changes to stay in sync...

This small plugin addresses this issue by automatically applying the patches
through git commands (if possible) and reverting them before Lazy starts its
lazy magic.

<!-- panvimdoc-ignore-start -->

---

**Before:**

> ![Before](https://github.com/polirritmico/lazy-local-patcher.nvim/assets/24460484/cd97c60b-e735-4b8f-966e-5a5d9c17a366)

**After:**

> ![After](https://github.com/polirritmico/lazy-local-patcher.nvim/assets/24460484/80ec51c6-aba9-4483-a341-dcc5ac4e6621)

---

<!-- panvimdoc-ignore-end -->

## 📋 Requirements

- [Neovim](https://neovim.io/) >= 0.9.0
- [Lazy.nvim](https://github.com/folke/lazy.nvim) >= 9.24.0
- Git

## 📦 Installation

```lua
return {
    "polirritmico/lazy-local-patcher.nvim",
    config = true,
    ft = "lazy", -- for lazy loading
}
```

## 🚀 Usage

### ⚙️ Setup

Create the `patches` directory or the plugin will complain about the missing
dir: (default path)

```command
$ mkdir ~/.config/nvim/patches
```

Here you could add your patches. Two considerations:

1. Only **one file** per plugin.
2. The name of the patch should match the repository name (more precisely, the
   directory name inside the Lazy root folder) and the file extension must be
   `.patch`. e.g.: `nvim-treesitter.patch`

### ⚙️ Configuration

Custom folders could be passed to the `setup` function:

```lua
require("lazy-local-patcher").setup({
    lazy_path = "/custom/root/lazy/path", -- directory where lazy install the plugins
    patches_path = "/custom/patch/path", -- directory where diff patches files are stored
})
```

### Defaults

Lazy local patcher comes with the following defaults:

```lua
local defaults = {
    lazy_path = vim.fn.stdpath("data") .. "/lazy", -- directory where lazy install the plugins
    patches_path = vim.fn.stdpath("config") .. "/patches", -- directory where diff patches files are stored
}
```

### Patches

Patches are applied using:

```command
git -C <plugin_path_in_Lazy_root> apply --ignore-space-change <patch>
```

Example of patch creation:

```
cd .local/share/nvim/lazy/nvim-treesitter
nvim edit/some/file
git diff | tee ~/.config/nvim/patches/nvim-treesitter.patch
```

Now enter into Nvim and sync the plugin with Lazy.

### Manual executions

You could use `apply_all` or `restore_all` functions to manually apply/restore
all patches inside the `patches-path` folder:

```
:lua require("lazy-local-patcher").apply_all()
[patches: nvim-treesitter.patch] Applying patch...
[patches: nvim-treesitter.patch] Done
```

```
:lua require("lazy-local-patcher").restore_all()
[patches: nvim-treesitter.patch] Restoring plugin repository...
[patches: nvim-treesitter.patch] Done
```

## 🌱 Contributions

While this plugin is primarily designed for my personal use and tailored to a
very specific use case, suggestions, issues, or pull requests are very welcome.

**_Enjoy_**
