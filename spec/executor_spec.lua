local Runner = require("rspec-runner.runner")
local Executor = require("rspec-runner.executor")
local config = require("rspec-runner.config")
local State = require("rspec-runner.state")

describe("Executor", function()
  describe("#execute", function()
    it("executes a runner", function()
      local runner = Runner.new("all", config)
      local state = State.new()

      Executor.execute(runner, config, state):wait()

      local output = state.output

      assert(output)
      assert(#output.examples, 2)
      assert.equal(2, output.summary.example_count)
      assert.equal(1, output.summary.failure_count)
    end)
  end)
end)
