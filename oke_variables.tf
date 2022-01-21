#Cluster
variable oke_dp_kubernetes_version { default = "v1.20.11" }
variable oke_dp_node_count { default = 3 }


#file storage
variable file_storage_work_path { default = "/work" }
variable file_storage_data_path { default = "/data" }
#variable node_pool_ssh_public_key { default = "" }