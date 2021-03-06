require 'MrMurano/version'
require 'MrMurano/Config-Migrate'
require 'highline/import'
require '_workspace'
#require 'tempfile'
#require 'erb'

RSpec.describe MrMurano::ConfigMigrate do
  include_context "WORKSPACE"
  before(:example) do
    @saved_pwd = ENV['MURANO_PASSWORD']
    ENV['MURANO_PASSWORD'] = nil
    @saved_cfg = ENV['MURANO_CONFIGFILE']
    ENV['MURANO_CONFIGFILE'] = nil

    $cfg = MrMurano::Config.new
    $cfg.load
    $cfg['net.host'] = 'bizapi.hosted.exosite.io'

    @lry = Pathname.new(@projectDir) + '.Solutionfile.secret'
    FileUtils.copy(File.join(@testdir, 'spec/fixtures/SolutionFiles/secret.json'), @lry.to_path)

    @mrt = MrMurano::ConfigMigrate.new

    @stdsaved = [$stdout, $stderr]
    $stdout, $stderr = [StringIO.new, StringIO.new]
  end

  after(:example) do
    $stdout, $stderr = @stdsaved
    ENV['MURANO_PASSWORD'] = @saved_pwd
    ENV['MURANO_CONFIGFILE'] = @saved_cfg
  end

  it "imports all" do
    @mrt.import_secret

    expect($cfg['solution.id']).to eq('ABCDEFG')
    expect($cfg['product.id']).to eq('HIJKLMNOP')
    expect($cfg['user.name']).to eq('test@user.account')
    pff = $cfg.file_at('passwords', :user)
    pwd = MrMurano::Passwords.new(pff)
    pwd.load
    expect(pwd.get$cfg['net.host'], $cfg['user.name']).to eq('gibblygook')
    expect($stdout.string).to eq('')
    expect($stderr.string).to eq('')
  end

  it "imports over" do
    $cfg['solution.id'] = '12'
    $cfg['product.id'] = 'awdfvs'
    $cfg['user.name'] = '3qrarvsa'
    $cfg = MrMurano::Config.new
    $cfg.load
    $cfg['net.host'] = 'bizapi.hosted.exosite.io'

    @mrt.import_secret

    expect($cfg['solution.id']).to eq('ABCDEFG')
    expect($cfg['product.id']).to eq('HIJKLMNOP')
    expect($cfg['user.name']).to eq('test@user.account')
    pff = $cfg.file_at('passwords', :user)
    pwd = MrMurano::Passwords.new(pff)
    pwd.load
    expect(pwd.get$cfg['net.host'], $cfg['user.name']).to eq('gibblygook')
    expect($stdout.string).to eq('')
    expect($stderr.string).to eq('')
  end

  it "Asks about password differences" do
    pff = $cfg.file_at('passwords', :user)
    pwd = MrMurano::Passwords.new(pff)
    pwd.set($cfg['net.host'], 'test@user.account', 'bob')
    pwd.save

    expect($terminal).to receive(:ask).with('A different password for this account already exists. Overwrite? N/y').and_return('y')

    @mrt.import_secret

    expect($cfg['solution.id']).to eq('ABCDEFG')
    expect($cfg['product.id']).to eq('HIJKLMNOP')
    expect($cfg['user.name']).to eq('test@user.account')
    pff = $cfg.file_at('passwords', :user)
    pwd = MrMurano::Passwords.new(pff)
    pwd.load
    expect(pwd.get$cfg['net.host'], $cfg['user.name']).to eq('gibblygook')
    expect($stdout.string).to eq('')
    expect($stderr.string).to eq('')
  end

end
#  vim: set ai et sw=2 ts=2 :
