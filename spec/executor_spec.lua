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

      Executor.execute(runner, config, state):wait()

      local output = state.output

      assert(output)
      assert(#output.examples, 3)
      assert.equal(3, output.summary.example_count)
      assert.equal(2, output.summary.failure_count)
    end)
  end)
end)
