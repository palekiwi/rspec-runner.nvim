local helpers = require("spec.spec_helpers")

local Runner = require("rspec-runner.runner")
local Executor = require("rspec-runner.executor")
local State = require("rspec-runner.state")

describe("Executor", function()
  describe("#execute", function()
    it("executes a runner", function()
      local _, runner = Runner.new("all", helpers.build_config())
      local state = State.new()
      local config = helpers.build_config()

      vim.wait(200, function()
        return Executor.execute(runner, config, state):is_closing()
      end)

      local output = state.output

      assert(output)
      assert.equal(#output.examples, 3)
      assert.equal(1, output.passed_count)
      assert.equal(2, output.failed_count)
    end)
  end)
end)
