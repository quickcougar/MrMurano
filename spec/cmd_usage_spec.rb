require 'fileutils'
require 'open3'
require 'pathname'
require 'cmd_common'

RSpec.describe 'murano usage', :cmd, :needs_password do
  include_context "CI_CMD"

  before(:example) do
    @project_name = rname('usageTest')
    out, err, status = Open3.capture3(capcmd('murano', 'solution', 'create', @project_name, '--save'))
    expect(err).to eq('')
    expect(out.chomp).to match(/^[a-zA-Z0-9]+$/)
    expect(status.exitstatus).to eq(0)
  end
  after(:example) do
    out, err, status = Open3.capture3(capcmd('murano', 'solution', 'delete', @project_name))
    expect(out).to eq('')
    expect(err).to eq('')
    expect(status.exitstatus).to eq(0)
  end

  it "show usage" do
    out, err, status = Open3.capture3(capcmd('murano', 'usage'))
    expect(err).to eq('')
    olines = out.lines
    expect(olines[0]).to match(/^(\+-+){5}\+$/)
    expect(olines[1]).to match(/^\|\s+\| Quota\s+\| Daily\s+\| Monthly\s+\| Total\s+\|$/)
    expect(olines[2]).to match(/^(\+-+){5}\+$/)
    expect(olines[-1]).to match(/^(\+-+){5}\+$/)
    expect(status.exitstatus).to eq(0)
  end

end

#  vim: set ai et sw=2 ts=2 :
