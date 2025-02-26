local rspec_runner = require("lua.rspec-runner.init")

local filename = "spec/fixtures/adder_spec.rb"

describe("Runner", function()
  describe("find_nearest", function()
    it("finds the name of the test nearest to cursor", function()
      vim.api.nvim_command(string.format("view +8 %s", filename))

      local result = rspec_runner.run("nearest")
      local expected = "returns a sum"

      assert.equal(expected, result.example)
    end)
  end)
end)
