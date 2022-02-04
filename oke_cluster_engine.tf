
resource oci_containerengine_cluster oke_containerengine_cluster {
  compartment_id = local.Sp3_cid
  endpoint_config {
    is_public_ip_enabled = "true"
    nsg_ids = [
    ]
    subnet_id = oci_core_subnet.oke_api_subset.id
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
      oci_core_subnet.oke_lb_subset.id,
    ]
  }
  vcn_id = oci_core_vcn.oke_cluster_vcn.id
}

locals {
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.oke_node_shape)
}

resource oci_containerengine_node_pool oke_containerengine_node_pool {
  cluster_id     = oci_containerengine_cluster.oke_containerengine_cluster.id
  compartment_id = local.Sp3_cid
  initial_node_labels {
    key   = "name"
    value = "oke_containerengine_node_pool"
  }
  kubernetes_version = "v1.20.11"
  name               = "oke genomics node pool"
  node_config_details {
    nsg_ids = [
    ]
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ads.availability_domains
      iterator = ad
      content {
        availability_domain = ad.value.name
        subnet_id           = oci_core_subnet.oke_nodes_subset.id
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
    boot_volume_size_in_gbs = "100"
    image_id                = "ocid1.image.oc1.uk-london-1.aaaaaaaaynapo7ejseprjcze5x3qedw5shivmw4kbyi4pmrhkqopht43acka"
    source_type             = "IMAGE"
  }
}
