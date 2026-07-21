local helpers = require("spec.spec_helpers")
local Runner = require("rspec-runner.runner")

local specfile = "spec/fixtures/adder_spec.rb"
local sourcefile = "spec/fixtures/adder.rb"
local nospecfile = "spec/fixtures/multiplier.rb"

---@return Config
local function build_config()
  return {
    cmd = { "rspec" },
    diagnostics = true,
    qflist = true,
    namespace = vim.api.nvim_create_namespace("rspec-runner"),
    notify = true,
    spec_patterns = { "_spec%.rb$" }
  }
end

describe("Runner", function()
  describe("#new", function()
    context("when called with scope `all`", function()
      it("creates a new runner for the whole project", function()
        helpers.view_file(specfile)

        local config = build_config()
        local err, runner = Runner.new("all", config)

        assert.falsy(err)
        assert.equal(vim.fn.getcwd(), runner.env.cwd)
        assert.equal("spec/fixtures/adder_spec.rb", runner.env.filename)
        assert.equal(1, runner.env.line)
        assert.equal("all", runner.scope)
        assert.are.same({ "rspec", "--format", "json" }, runner.cmd)
      end)
    end)

    context("with placeholder in cmd", function()
      it("injects args into the placeholder", function()
        helpers.view_file(specfile)

        local config = build_config()
        config.cmd = { "docker", "compose", "run", "whitesales", "script/runspecs.sh {}" }
        local _, runner = Runner.new("file", config)

        assert.are.same({
          "docker",
          "compose",
          "run",
          "whitesales",
          "script/runspecs.sh --format json spec/fixtures/adder_spec.rb"
        }, runner.cmd)
      end)
    end)

    context("with {files} placeholder in cmd", function()
      it("injects only files into the placeholder", function()
        helpers.view_file(specfile)

        local config = build_config()
        config.cmd = { "docker", "compose", "run", "whitesales", "script/runspecs.sh {files}" }
        local _, runner = Runner.new("file", config)

        assert.are.same({
          "docker",
          "compose",
          "run",
          "whitesales",
          "script/runspecs.sh spec/fixtures/adder_spec.rb"
        }, runner.cmd)
      end)
    end)

    context("with {flags} placeholder in cmd", function()
      it("injects only flags into the placeholder", function()
        helpers.view_file(specfile)

        local config = build_config()
        config.cmd = { "rspec", "{flags}" }
        local _, runner = Runner.new("file", config, { term = true })

        assert.are.same({
          "rspec",
          "--format documentation"
        }, runner.cmd)
      end)
    end)

    context("when called with scope `file`", function()
      context("when the buffer is loaded with an absolute path", function()
        it("normalizes the path to be relative to cwd", function()
          helpers.view_file(specfile)
          local bufnr = vim.api.nvim_get_current_buf()
          local absolute = vim.fn.fnamemodify(specfile, ":p")

          -- neovim sometimes loads a buffer with an absolute path; force that
          -- state so the spec is independent of the test runner's shortening.
          vim.api.nvim_buf_set_name(bufnr, absolute)
          finally(function()
            pcall(vim.api.nvim_buf_set_name, bufnr, specfile)
          end)

          local config = build_config()
          local err, runner = Runner.new("file", config)

          assert.falsy(err)
          assert.are.same({ "rspec", "--format", "json", "spec/fixtures/adder_spec.rb" }, runner.cmd)
        end)
      end)

      context("when the file is a spec file", function()
        it("it creates a runner for the current file", function()
          helpers.view_file(specfile)

          local config = build_config()
          local err, runner = Runner.new("file", config)

          assert.falsy(err)
          assert.equal("file", runner.scope)
          assert.are.same({ "rspec", "--format", "json", "spec/fixtures/adder_spec.rb" }, runner.cmd)
        end)
      end)

      context("when the file is a sourcefile with an existing specfile", function()
        it("it creates a runner for the specfile file", function()
          helpers.view_file(sourcefile)

          local config = build_config()
          local _, runner = Runner.new("file", config)

          assert.equal("file", runner.scope)
          assert.are.same({ "rspec", "--format", "json", specfile }, runner.cmd)
        end)
      end)

      context("when the file is a sourcefile without an existing specfile", function()
        it("it throws an error", function()
          helpers.view_file(nospecfile)

          local config = build_config()
          local err = Runner.new("file", config)
          assert.equal("No spec file for current file.", err)
        end)
      end)
    end)
  end)


  describe("#spec_for", function()
    context("when called for a spec file", function()
      it("returns given filename", function()
        assert.equal(specfile, Runner.spec_for(specfile))
      end)
    end)

    context("when called for a source file with an existing spec", function()
      it("returns an alternate specfile", function()
        assert.equal(specfile, Runner.spec_for(sourcefile))
      end)
    end)

    context("when called for a source file with an non-existent spec", function()
      it("returns an alternate specfile", function()
        assert.falsy(Runner.spec_for("spec/non-existent.rb"))
      end)
    end)
  end)

  describe("#find_nearest", function()
    -- spec/fixtures/adder_spec.rb layout (1-based lines):
    --   3  RSpec.describe Adder do
    --   4    describe '#add' do
    --   5      context 'when adding two numbers' do
    --   6        it 'returns a sum' do
    --   7          result = Adder.add(1, 2)
    --   ...
    --   12        it 'makes a mistake' do
    --   ...
    --   18        it 'makes a mistake again' do
    context("when the cursor is inside an `it` block body", function()
      it("returns the line of that `it`", function()
        helpers.view_file(specfile, 7) -- inside `it 'returns a sum'`
        assert.equal(6, Runner.find_nearest())
      end)

      it("returns the line of the second `it` when cursor is in it", function()
        helpers.view_file(specfile, 13) -- inside `it 'makes a mistake'`
        assert.equal(12, Runner.find_nearest())
      end)
    end)

    context("when the cursor is inside the enclosing describe/context", function()
      it("returns the first nested example's line", function()
        -- line 11 is the blank line between the first two `it` blocks; the
        -- cursor sits inside the `context` body but outside any `it`.
        helpers.view_file(specfile, 11)
        local line = Runner.find_nearest()
        assert.truthy(line)
        assert.equal(6, line) -- first `it` in iteration order
      end)
    end)

    context("when the cursor is above the nested examples", function()
      -- Characterization: walking parents from line 1 reaches the file root,
      -- whose first match is `describe '#add'` on line 4. This documents the
      -- existing "run up to the nearest enclosing block" semantics rather
      -- than a stricter nil-return; it is not the focus of this change.
      it("returns the first enclosing block's line", function()
        helpers.view_file(specfile, 1)
        assert.equal(4, Runner.find_nearest())
      end)
    end)

    context("when the buffer has no rspec blocks at all", function()
      it("returns nil", function()
        helpers.view_file(sourcefile) -- spec/fixtures/adder.rb: no describe/it
        assert.falsy(Runner.find_nearest())
      end)
    end)
  end)

  describe("#new", function()
    context("when called with scope `nearest`", function()
      it("builds a command targeting the nearest example's line", function()
        helpers.view_file(specfile, 7) -- inside `it 'returns a sum'` (line 6)

        local config = build_config()
        local err, runner = Runner.new("nearest", config)

        assert.falsy(err)
        assert.equal("nearest", runner.scope)
        assert.are.same({ "rspec", "--format", "json", "spec/fixtures/adder_spec.rb:6" }, runner.cmd)
      end)

      it("returns an error when the buffer is not a specfile", function()
        helpers.view_file(sourcefile)

        local config = build_config()
        local err = Runner.new("nearest", config)
        assert.equal("Not a specfile.", err)
      end)
    end)
  end)
end)
