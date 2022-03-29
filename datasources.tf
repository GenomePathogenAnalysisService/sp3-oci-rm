# Random string
resource "random_string" "deploy_id" {
  length  = 5
  special = false
  upper   = false
  number  = false
}

data "template_cloudinit_config" "headnode" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.headnode_cloud_init.rendered
  }
}
data "template_file" "headnode_cloud_init" {
  template = file("${path.module}/scripts/headnode-cloud-config.template.yaml")

  vars = {
    bootstrap_root_sh_content   = base64gzip(data.template_file.bootstrap_root.rendered)
    bootstrap_ubuntu_sh_content = base64gzip(data.template_file.bootstrap_ubuntu.rendered)
    stack_info_content          = base64gzip(data.template_file.stack_info.rendered)
    install_kubernetes_sh_content  = base64gzip(data.template_file.install_kubernetes.rendered)
    install_sp3_sh_content      = base64gzip(data.template_file.install_sp3.rendered)
    install_nginx_sh_content    = base64gzip(data.template_file.install_nginx.rendered)
    install_s3bucket_sh_content    = base64gzip(data.template_file.install_s3bucket.rendered)
    oraclek8s_yaml_content    = base64gzip(data.template_file.oraclek8s.rendered)
    install_custom_nextflow_sh_content    = base64gzip(data.template_file.install_custom_nextflow.rendered)
    cleanup_pods_yaml_content    = base64gzip(data.template_file.cleanup_pods.rendered)
  }
}

# data "template_cloudinit_config" "bastion" {
#   gzip          = true
#   base64_encode = true

#   part {
#     filename     = "cloud-config.yaml"
#     content_type = "text/cloud-config"
#     content      = data.template_file.bastion_cloud_init.rendered
#   }
# }

# data "template_file" "bastion_cloud_init" {
#   template = file("${path.module}/scripts/bastion-cloud-config.template.yaml")

#   vars = {

#   }
# }

data "template_file" "bootstrap_root" {
  template = file("${path.module}/scripts/bootstrap_root.sh")

  vars = {
    sp3_file_mount_ip = oci_file_storage_mount_target.file_storage_mount_sp3_target.ip_address
  }
}
data "template_file" "bootstrap_ubuntu" {
  template = file("${path.module}/scripts/bootstrap_ubuntu.sh")

  # Variables parsed into bootstrap_ubuntu.sh as it is encoded in to Cloud-Init
  vars = {
    deployment_id = local.Sp3_deploy_id
    tenancy_id    = var.tenancy_ocid
  }
}

data "template_file" "stack_info" {
  template = file("${path.module}/scripts/stack_info.json")

  # Variables parsed into stack_info.json as it is encoded in to Cloud-Init
  vars = {
    deployment_id      = local.Sp3_deploy_id
    compartment_id     = local.Sp3_cid
    tenancy_id         = var.tenancy_ocid
    load_balancer_id   = local.Sp3_lb_id
    sp3_url            = local.Sp3_lb_url
    priv_subnet_id     = local.Privsn001_id
    ad                 = local.Sp3_ad
    worker_shape       = var.worker_shape
    worker_image       = var.worker_image
    worker_ocpus       = local.is_flexible_worker_shape ? var.worker_ocpus : 0
    worker_ram         = local.is_flexible_worker_shape ? var.worker_ram : 0
    worker_min         = var.worker_min
    worker_max         = var.worker_max
    worker_use_scratch = var.worker_use_scratch
    worker_timeout     = var.worker_timeout
    worker_max_create  = var.worker_max_create
  }
}

data "template_file" "install_sp3" {
  template = file("${path.module}/scripts/install_sp3.sh")

  vars = {
    Sp3_gitrepo_secret_id = local.Sp3_gitrepo_secret_id
    Sp3_deploy_1k         = var.deploy_1k
  }
}

data "template_file" "install_nginx" {
  template = file("${path.module}/scripts/install_nginx.sh")

  vars = {
    install_certs                    = var.install_certs
    Gpas_dev_ox_ac_uk_ssl_secret_id  = local.Gpas_dev_ox_ac_uk_ssl_secret_id
    Gpas_dev_ox_ac_uk_priv_secret_id = local.Gpas_dev_ox_ac_uk_priv_secret_id
    Sp3_env_name                     = local.Sp3_env_name
  }
}

data "template_file" "install_kubernetes" {
  template = file("${path.module}/scripts/install_kubernetes.sh")

  vars = {
    oke_cluster_id  = oci_containerengine_cluster.oke_containerengine_cluster.id
    kubectlVersion = var.kubectl_version
  }
}

data "template_file" "install_s3bucket" {
  template = file("${path.module}/scripts/install_s3bucket.sh")

  vars = {
    Gpas_dev_ox_ac_uk_s3_secret_id    = var.Gpas_dev_ox_ac_uk_s3_secret_id
    Gpas_dev_ox_ac_uk_s3_bucket_names  = var.Gpas_dev_ox_ac_uk_s3_bucket_names
  }
}

data "template_file" "oraclek8s" {
  template = file("${path.module}/scripts/oraclek8s.yaml")

  vars = {
    nfs_ip = oci_file_storage_mount_target.file_storage_mount_oke_target.ip_address
    nfs_mnt_tgt_id = oci_file_storage_mount_target.file_storage_mount_oke_target.id
  }
}

data "template_file" "install_custom_nextflow" {
  template = file("${path.module}/scripts/install_custom_nextflow.sh")
}

data "template_file" "cleanup_pods" {
  template = file("${path.module}/scripts/cleanup_pods.yaml")
  vars = {
    cronjob_apiversion = var.oke_dp_kubernetes_version == "v1.20.11" ? "batch/v1beta1" : "batch/v1"
  }
}

locals {
  is_flexible_worker_shape = contains(local.compute_flexible_shapes, var.worker_shape)
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

resource "random_shuffle" "compute_ad" {
  input        = data.oci_identity_availability_domains.ads.availability_domains[*].name
  result_count = length(data.oci_identity_availability_domains.ads.availability_domains[*].name)
}

locals {
  ad_random = random_shuffle.compute_ad.result[0]
  Sp3_ad    = var.randomise_ad ? local.ad_random : var.ad
}
