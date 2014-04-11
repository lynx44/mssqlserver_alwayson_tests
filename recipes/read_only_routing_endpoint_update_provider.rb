mssqlserver_alwayson_read_only_routing_endpoint node['description'] do
  availability_group node['availability_group']
  node_name node['secondary_node']
  url node['url']
  action :update
end