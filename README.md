# rspec-runner.nvim

Runs rspec inside nvim and collects results for convenient browsing of results and populating diagnostics.

## Available commands
`RspecRunnerAll` runs all tests in the project

`RspecRunnerBase` runs tests for files that changed since the `base` commit/branch, defaults to "master"

`RspecRunnerStaged` runs tests for files that are currently staged in git

`RspecRunnerFailures` runs tests only for the examples that failed in the last run

`RspecRunnerFile` runs tests for current file if a specfile exists

`RspecRunnerLast` re-runs with the last settings

`RspecRunnerNearest` runs tests for `it`, `context`, `describe` nearest to cursor

`RspecRunnerTermAll` runs all inside neovim terminal

`RspecRunnerTermBase` runs base inside neovim terminal

`RspecRunnerTermStaged` runs staged inside neovim terminal

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

### Command Placeholders
When using a table for `cmd`, you can use placeholders to control where the RSpec arguments and file paths are injected. This is particularly useful for complex commands that wrap the execution in a string.

- `{}`: Injects both RSpec flags and file paths (e.g., `--format json spec/models/user_spec.rb`).
- `{files}`: Injects only the spec file paths.
- `{flags}`: Injects only the RSpec flags.

#### Example: Docker Compose with a wrapper script
If you need to pass arguments into a quoted string for a remote execution script:

```lua
cmd = {
  "docker", "compose", "run", "--rm", "app",
  "script/runspecs.sh {files}"
}
```

This also works via environment variables:

```bash
export RSPEC_RUNNER_CMD='docker compose run --rm app "script/runspecs.sh {files}"'
```

If no placeholder is present, the arguments are simply appended to the end of the command.

### Custom Command Function
If the project uses a wrapper around `rspec`, you can also construct the command by passing a function:

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
