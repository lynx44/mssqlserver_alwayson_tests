mssqlserver_alwayson_hadr_endpoint node['description'] do
  nodes node['nodes']
  action :create
end