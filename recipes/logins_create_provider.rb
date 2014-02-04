mssqlserver_alwayson_logins 'create logins' do
  nodes node['nodes']
  service_username node['service_username']
  action :create
end