local Browser = require("rspec-runner.browser")

describe("Browser", function()
  describe("#diagnostics_from_backtrace", function()
    it("parses backtrace into diagnostic entries", function()
      local backtrace = {
        "./spec/fixtures/adder_spec.rb:15:in 'block (4 levels) in <top (required)>'",
        "/usr/lib/file.so:8:in 'block (4 levels) in <top (required)>'",
        "not a correct backtrae /usr/lib/file:12",
      }

      local result = Browser.diagnostics_from_backtrace(backtrace)

      assert(#result, 2)
    end)
  end)
end)
