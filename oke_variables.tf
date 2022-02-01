#Cluster
variable "oke_dp_kubernetes_version" { default = "v1.20.11" }
variable "oke_dp_node_count" { default = 3 }
variable "oke_node_shape" { default = "VM.Standard2.1" }
variable "oke_node_ocpus" { default = 1 }
variable "oke_node_ram" { default = 16 }


#file storage
variable "file_storage_work_path" { default = "/work" }
variable "file_storage_data_path" { default = "/data" }
#variable node_pool_ssh_public_key { default = "" }