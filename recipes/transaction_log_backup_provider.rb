mssqlserver_alwayson_transaction_log node['description'] do
  file_path node['file_path']
  database node['database']
  action :backup
end