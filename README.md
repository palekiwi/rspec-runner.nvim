# rspec-runner.nvim

Runs rspec inside nvim and collects results for convenient browsing of results and populating diagnostics.

## Available commands
`RspecRunnerAll` runs all tests in the project

`RspecRunnerBase` runs tests for files that changed since the `base` commit/branch, defaults to "master"

`RspecRunnerFailures` runs tests only for the examples that failed in the last run

`RspecRunnerFile` runs tests for current file if a specfile exists

`RspecRunnerLast` re-runs with the last settings

`RspecRunnerNearest` runs tests for `it`, `context`, `describe` nearest to cursor

`RspecRunnerTermAll` runs all inside neovim terminal

`RspecRunnerTermBase` runs base inside neovim terminal

`RspecRunnerFile` runs for current file inside neovim terminal

`RspecRunnerNearest` runs for nearest scope inside neovim terminal

`RspecRunnerCancel` cancels current run

`RspecRunnerShowResults` displays results in a telescope window, requires telescope. Use `<C-d>` and `<C-u>` to scroll preview down/up. `<C-q>` over an entry populates quickfix list with the backtrace of a failed test.

## Setup
Recommended minimal setup:

```lua
return {
  {
    "palekiwi/rspec-runner.nvim",
    config = function()
      require 'rspec-runner'.setup({
        defaults =  {
          notify = false, -- set to `true` if using a notification plugin, such as `rcarriga/nvim-notify`
          cmd = { "bundle", "exec", "rspec" }, -- command that executes rspec
        },
        projects = { -- per project settings
          {
            path = "/home/user/code/some-namespace/.*", -- path to a project, must be a lua pattern
            cmd = { "docker-compose", "exec", "-it", "test", "bundle", "exec", "rspec" }, -- command
          }
        }
      })
    end,
  }
}
```
The `cmd` can be either a `string[]` or `fun(rspec_args: string[], files: string[]): string[]`.
If the project uses a wrapper around `rspec`, you can construct the command by passing a function, for example:

```lua
...
  projects = {
    {
      path = "/home/user/code/my-project",
      cmd = function(rspec_flags, files)
        local args = vim.list_extend(rspec_flags, files)

        return vim.list_extend(
          { "docker-compose", "exec", "-it", "test", "bundle", "exec", "rspec" },
          args
        )
      end,
    }
  },
...
```
