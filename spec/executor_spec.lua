local Runner = require("rspec-runner.runner")
local executor = require("rspec-runner.executor")
local config = require("rspec-runner.config")
local runner_state = require("rspec-runner.state")

describe("Executor", function()
  describe("#execute", function()
    it("executes a runner", function()

      local runner = Runner:new("all")
      local state = runner_state.new()

      executor.execute(runner, config, state):wait()

      local output = state.output

      assert(output)
      assert(#output.examples, 2)
      assert.equal(2, output.summary.example_count)
      assert.equal(1, output.summary.failure_count)
    end)
  end)
end)
