
resource oci_containerengine_cluster oke_containerengine_cluster {
  compartment_id = local.Sp3_cid
  endpoint_config {
    is_public_ip_enabled = "true"
    nsg_ids = [
    ]
    # oke_api_subset
    subnet_id = oci_core_subnet.sp3_api_subset.id
  }
  image_policy_config {
    is_policy_enabled = "false"
  }
  kubernetes_version = var.oke_dp_kubernetes_version
  name               = "sp3_nextflow_cluster"
  options {
    admission_controller_options {
      is_pod_security_policy_enabled = "false"
    }
    service_lb_subnet_ids = [
      local.Pubsn001_id, 
    ]
  }
  vcn_id = local.Sp3_vcn_id
}

locals {
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.oke_node_shape)
}

data "template_file" "oke_node_cloudinit_content" {
  template = file("${path.module}/scripts/oke-node.template.sh")

  vars = {
  }
}

resource oci_containerengine_node_pool oke_containerengine_node_pool {
  cluster_id     = oci_containerengine_cluster.oke_containerengine_cluster.id
  compartment_id = local.Sp3_cid
  initial_node_labels {
    key   = "name"
    value = "oke_containerengine_node_pool"
  }
  kubernetes_version = "v1.21.5"
  name               = "oke genomics node pool"
  node_config_details {
    nsg_ids = [
    ]
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ads.availability_domains
      iterator = ad
      content {
        availability_domain = ad.value.name
        # oke_nodes_subset
        subnet_id           = local.Privsn001_id
      }
    }    
    size = var.oke_dp_node_count
  }
  node_shape = var.oke_node_shape
  dynamic "node_shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.oke_node_ram
      ocpus         = var.oke_node_ocpus
    }
  }
  node_source_details {
    boot_volume_size_in_gbs = var.oke_boot_vol_size_gb
    image_id                = "ocid1.image.oc1.uk-london-1.aaaaaaaaynapo7ejseprjcze5x3qedw5shivmw4kbyi4pmrhkqopht43acka"
    source_type             = "IMAGE"
  }
  node_metadata = {
    user_data = base64gzip(data.template_file.oke_node_cloudinit_content.rendered)
  }
}

# Create additional node pool for Autoscaler use
resource oci_containerengine_node_pool oke_ca_node_pool {
  cluster_id     = oci_containerengine_cluster.oke_containerengine_cluster.id
  compartment_id = local.Sp3_cid
  initial_node_labels {
    key   = "name"
    value = "oke_ca_node_pool"
  }
  kubernetes_version = "v1.21.5"
  name               = "oke genomics ca node pool"
  node_config_details {
    nsg_ids = [
    ]
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ads.availability_domains
      iterator = ad
      content {
        availability_domain = ad.value.name
        #oke_nodes_subset
        subnet_id           = local.Privsn001_id
      }
    }    
    size = var.oke_cluster_autoscaler_min_nodes
  }
  node_shape = var.oke_node_shape
  dynamic "node_shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.oke_node_ram
      ocpus         = var.oke_node_ocpus
    }
  }
  node_source_details {
    boot_volume_size_in_gbs = var.oke_boot_vol_size_gb
    image_id                = "ocid1.image.oc1.uk-london-1.aaaaaaaaynapo7ejseprjcze5x3qedw5shivmw4kbyi4pmrhkqopht43acka"
    source_type             = "IMAGE"
  }
  node_metadata = {
    user_data = base64gzip(data.template_file.oke_node_cloudinit_content.rendered)
  }
}
