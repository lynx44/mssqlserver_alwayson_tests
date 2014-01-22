mssqlserver_alwayson_group node['alwayson']['name'] do
  databases node['alwayson']['databases']
  automated_backup_preference node['alwayson']['automated_backup_preference']
  nodes node['alwayson']['nodes']
  action :connect
end