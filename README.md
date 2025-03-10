# rspec-runner.nvim

Runs rspec inside nvim and collects results for convenient browsing of results and populating diagnostics.

## Available commands
`RspecRunnerAll`  runs all test in the project

`RspecRunnerBase` runs tests for files that changed since the `base` commit/branch, defaults to "master"

`RspecRunnerFile` runs tests for current file if a specfile exists

`RspecRunnerLast` re-runs with the last settings

`RspecRunnerNearest` runs tests for `it`, `context`, `describe` nearest to cursor

`RspecRunnerCancel` cancels current run

`RspecRunnerShowResults` displays results in a telescope window, requires telescope. Use `<C-d>` and `<C-d>` to scroll preview down/up. `<C-q>` over an entry populates quickfix list with the backtrace of a failed test.

## Setup
Recommended minimal setup:

```lua
return {
  {
    "palekiwi/rspec-runner.nvim",
    config = function()
      require 'rspec-runner'.setup({
        defaults =  {
            cmd = { "bundle", "exec", "rspec" }, -- command that executes rspec
        },
        projects = { -- per project settings
          {
            path = "/home/user/code/some-namespace/.*", -- path to a project, must be a lua pattern
            cmd = { "docker-compose", "exec", "-it", "test", "bin/rspec" }, -- command
          }
        }
      })
    end,
  }
}
```
