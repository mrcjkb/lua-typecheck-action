local lta = require('lua-typecheck-action')

describe('lua-typecheck-action', function()
  it('fixtures available', function()
    local fh = io.open('spec/fixtures/warning/lua/bad-types.lua')
    assert.not_nil(fh)
    fh:close()
  end)
  it('succeeds on no diagnostics', function()
    lta.run {
      workdir = 'spec/fixtures/ok',
    }
  end)
  it('fails on warning diagnostics', function()
    assert.error(function()
      lta.run {
        workdir = 'spec/fixtures/warning',
      }
    end)
  end)
end)
