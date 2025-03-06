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
        local runner = Runner.new("all", config)

        assert.equal(vim.fn.getcwd(), runner.cfg.cwd)
        assert.equal("./spec/fixtures/adder_spec.rb", runner.cfg.filename)
        assert.equal(1, runner.cfg.line)
        assert.equal("all", runner.cfg.scope)
        assert.are.same({ "rspec", "--format", "j" }, runner.cmd)
      end)
    end)

    context("when called with scope `file`", function()
      context("when the file is a spec file", function()
        it("it creates a runner for the current file", function()
          helpers.view_file(specfile)

          local config = build_config()
          local runner = Runner.new("file", config)

          assert.equal("file", runner.cfg.scope)
          assert.are.same({ "rspec", "--format", "j", "./spec/fixtures/adder_spec.rb" }, runner.cmd)
        end)
      end)

      context("when the file is a sourcefile with an existing specfile", function()
        it("it creates a runner for the specfile file", function()
          helpers.view_file(sourcefile)

          local config = build_config()
          local runner = Runner.new("file", config)

          assert.equal("file", runner.cfg.scope)
          assert.are.same({ "rspec", "--format", "j", specfile }, runner.cmd)
        end)
      end)

      context("when the file is a sourcefile without an existing specfile", function()
        it("it throws an error", function()
          helpers.view_file(nospecfile)

          local config = build_config()
          assert.has_error(function() Runner.new("file", config) end)
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
end)
