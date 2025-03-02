local helpers = require("spec.helpers")
local Runner = require("rspec-runner.runner")

local filename = "spec/fixtures/adder_spec.rb"

describe("Runner", function()
  describe("#setup", function()
    it("creates a new runner", function()
      helpers.view_file(filename, 8)

      local runner = Runner:new("all")

      assert.equal(vim.fn.getcwd(), runner.cwd)
      assert.equal(filename, runner.filename)
      assert.equal(8, runner.line)
      assert.equal("all", runner.scope)
    end)
  end)
end)
