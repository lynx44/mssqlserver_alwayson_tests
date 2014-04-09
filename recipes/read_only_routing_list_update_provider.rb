mssqlserver_alwayson_read_only_routing_list node['description'] do
  primary_node node['primary_node']
  routing_list node['routing_list']
  availability_group node['availability_group']
  action :update
end