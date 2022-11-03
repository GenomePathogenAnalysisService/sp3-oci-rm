#Cluster
variable oke_dp_kubernetes_version { default = "1.23.4" }
variable oke_dp_node_count { default = 3 }
variable oke_node_shape { default = "VM.Standard.E3.Flex" }
variable oke_node_ocpus { default = 6 }
variable oke_node_ram { default = 32 }
variable oke_boot_vol_size_gb { default = 256 }


#file storage
variable file_storage_work_path { default = "/work" }
variable file_storage_data_path { default = "/data" }
#variable node_pool_ssh_public_key { default = "" }

#Kubectl
variable "kubectl_version" { default = "v1.23.4" }

#Cluster Autoscaler
variable oke_cluster_autoscaler_min_nodes { default = 3 }
variable oke_cluster_autoscaler_max_nodes { default = 10 }

#Mount targets ADs
variable mount_ad { default = "IfHB:UK-LONDON-1-AD-1" }
