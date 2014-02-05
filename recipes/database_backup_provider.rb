mssqlserver_alwayson_database node['description'] do
  file_path node['file_path']
  database node['database']
  action :backup
end