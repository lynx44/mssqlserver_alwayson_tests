shared_context 'templates' do
  before(:all) do
    make_template_directory
    files = Dir["#{source}/*"]
    FileUtils.cp_r(files, destination)
  end

  after(:all) do
    FileUtils.remove(Dir["#{destination}/*"])
  end

  def make_template_directory
    FileUtils.mkdir_p(destination)
  end

  def source
    @source ||= "#{File.expand_path('../../../mssqlserver_alwayson/templates/default/', __FILE__)}"
  end

  def destination
    @destination ||= File.expand_path('../../templates/default/', __FILE__)
  end
end