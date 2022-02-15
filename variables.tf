variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_pub_key" {}
variable "bastion_shape" {}
variable "bastion_image" {}
variable "bastion_ocpus" { default = 1 }
variable "bastion_ram" { default = 16 }
variable "headnode_shape" {}
variable "headnode_image" {}
variable "headnode_ocpus" { default = 1 }
variable "headnode_ram" { default = 16 }
variable "bastion_boot_size" { default = 50 }
variable "hn_boot_size" { default = 120 }
variable "hn_data_size" { default = 1024 }
variable "hn_work_size" { default = 1024 }
variable "use_hp_vol" { default = true }
variable "randomise_ad" { default = true }
variable "ad" { default = "" }
variable "name_prefix" { default = "" }
variable "env_name" { default = "sp3" }
variable "deploy_test" { default = false }
variable "deploy_1k" { default = false }
variable "show_testing_others" { default = false }
variable "specify_prefix" { default = false }
variable "worker_shape" { default = "" }
variable "worker_image" { default = "" }
variable "worker_ocpus" { default = 1 }
variable "worker_ram" { default = 16 }
variable "worker_min" { default = 1 }
variable "worker_max" { default = 1 }
variable "worker_timeout" { default = 30 }
variable "worker_max_create" { default = 4 }
variable "worker_use_scratch" { default = false }
variable "create_child_comp" { default = true }
variable "install_certs" { default = true }
variable "create_dns" { default = true }
variable "custom_worker_img" { default = "" }
variable "select_cust_worker_img" { default = false }
# variable "environment_type" { default = "" }
variable "Gpas_dev_ox_ac_uk_s3_secret_id" { default ="ocid1.vaultsecret.oc1.uk-london-1.amaaaaaahe4ejdiakchjybgrmtefb34nclwavrtdee76qjnca7oob4s6udxa" }
variable "Gpas_dev_ox_ac_uk_s3_bucket_names" { default ="iCSRNlMgzHjZYDCREgFyKQDdDULAztAQ" }

locals {
  compute_flexible_shapes          = ["VM.Standard.E3.Flex", "VM.Standard.E4.Flex", "VM.Standard.A1.Flex", "VM.Optimized3.Flex", "VM.Standard3.Flex"]
  Sp3_deploy_id                    = random_string.deploy_id.result
  Sp3_gitrepo_secret_id            = "ocid1.vaultsecret.oc1.uk-london-1.amaaaaaahe4ejdia3ejrsbqkv6iz2ipwngjmteeduitufuu7u35sgxrx7wna"
  Gpas_dev_ox_ac_uk_ssl_secret_id  = "ocid1.vaultsecret.oc1.uk-london-1.amaaaaaahe4ejdia6tt7gcmvc34nidknpqmoh4vk46ljw3mz3wcn2zmzyz4a"
  Gpas_dev_ox_ac_uk_priv_secret_id = "ocid1.vaultsecret.oc1.uk-london-1.amaaaaaahe4ejdiajs225tzw7ymb4ym5qubkxichzueqnp2g2w2punjb2qoa"
  Gpas_dev_ox_ac_uk_dns_zone_id    = "ocid1.dns-zone.oc1..ab26ceb4f3e648a1800bb57bb433c2f6"
  Sp3dev_sandbox_cid               = "ocid1.compartment.oc1..aaaaaaaao4kpjckz2pjmlict2ssrnx45ims7ttvxghlluo2tcwv6pgfdlepq"
  Sp3_dns_suffix                   = "dev.gpas.ox.ac.uk"
}
