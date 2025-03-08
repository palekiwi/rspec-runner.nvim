local helpers = require("spec.spec_helpers")

local Decoder = require("rspec-runner.decoder")

describe("Decoder", function()
  describe("#decode", function()
    context("when given input string not containing valid json object", function()
      it("returns an empty list", function()
        local err, result = Decoder.decode('Some text without json')
        assert.falsy(err)
        assert.are.same(result, {})
      end)
    end)

    context("when given input string containing an invalid json object", function()
      it("returns an error message", function()
        local err, _ = Decoder.decode('{",,,}')
        assert.equal(err, "Invalid json")
      end)
    end)

    context("when given input string containing valid a json string", function()
      context("when the string contains valid examples", function()
        it("returns a list of examples ", function()

          local data = helpers.read_file("spec/fixtures/output.json")
          local err, result = Decoder.decode(data)

          assert.falsy(err)
          assert.equal(#result, 3)
        end)
      end)

      context("when the string contains invalid examples", function()
        it("returns a list of examples ", function()

          local data = '{"examples": [{"description":"desc"}] }'
          local err, _ = Decoder.decode(data)

          assert.equal("file_path: expected string, got nil" ,err)
        end)
      end)
    end)
  end)
end)
