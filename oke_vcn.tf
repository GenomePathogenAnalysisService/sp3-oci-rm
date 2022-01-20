# ------ Create Virtual Cloud Network
resource oci_core_vcn oke_cluster_vcn {
  cidr_blocks = [
    "10.0.0.0/16",
  ]
  compartment_id = var.compartment_ocid
  display_name = "oke cluster vcn"
  dns_label    = "okeoxcluster"
}


# ------ Create Internet Gateway
resource oci_core_internet_gateway oke_cluster_internet_gateway {
  compartment_id = var.compartment_ocid
  display_name = "Internet gateway for oke cluster"
  enabled      = "true"
  vcn_id = oci_core_vcn.oke_cluster_vcn.id
}


# ------ Create NAT Gateway 
resource oci_core_nat_gateway oke_cluster_ngw {
  block_traffic  = "false"
  compartment_id = var.compartment_ocid
  display_name = "oke cluster ngw"
  vcn_id       = oci_core_vcn.oke_cluster_vcn.id
}


# ------ Create Service Gateway 
resource oci_core_service_gateway oke_service_gateway {
  compartment_id = var.compartment_ocid
  display_name = "Service gateway for oke cluster"
  services {
    service_id = "ocid1.service.oc1.uk-london-1.aaaaaaaatwg7f5mnzoapfunl66n2qkp4ormiykqk3hiwksum63gcyjk7ysla"
  }
  vcn_id = oci_core_vcn.oke_cluster_vcn.id
}


# ------ Create Security List
resource oci_core_security_list oke_node_sec_list {
  compartment_id = var.compartment_ocid
  display_name = "oke-node-sec-list"
  egress_security_rules {
    description      = "Access to Kubernetes API Endpoint"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Worker Nodes access to Internet"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Kubernetes worker to control plane communication"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "ICMP Access from Kubernetes Control Plane"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    destination      = "all-lhr-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }
  freeform_tags = {
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.0.0/28"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Inbound SSH traffic to worker nodes"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    #icmp_options = <<Optional value not found in discovery>>
    protocol    = "all"
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "TCP access from Kubernetes Control Plane"
    #icmp_options = <<Optional value not found in discovery>>
    protocol    = "6"
    source      = "10.0.0.0/28"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  vcn_id = oci_core_vcn.oke_cluster_vcn.id
}

resource oci_core_security_list oke_k8sApiEndpoint_cluster_sec_list {
  compartment_id = var.compartment_ocid
  display_name = "oke-k8sApiEndpoint-cluster-security-list"
  egress_security_rules {
    description      = "Path discovery"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "All traffic to worker nodes"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    destination      = "all-lhr-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
  }
  freeform_tags = {
  }
  ingress_security_rules {
    description = "Kubernetes worker to control plane communication"
    protocol    = "6"
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "External access to Kubernetes API endpoint"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    protocol    = "6"
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  vcn_id = oci_core_vcn.oke_cluster_vcn.id
}

resource oci_core_security_list oke_nodes_fss_access_sec_list {
  compartment_id = var.compartment_ocid
  display_name = "oke_nodes_fss_access_sec_list"

  egress_security_rules {
    protocol    = "6"
    destination = "10.0.10.0/24"
    stateless   = false
    description = "Enable network connectivity to mount FSS."
    tcp_options {
        min = 111
        max = 111
    }
  }

  egress_security_rules {
    protocol    = "17"
    destination = "10.0.10.0/24"
    stateless   = false
    description = "Enable network connectivity to mount FSS."
    udp_options {
        min = 111
        max = 111
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = "10.0.10.0/24"
    stateless   = false
    description = "Enable network connectivity to mount FSS."
    tcp_options {
        min = 2048
        max = 2050
    }
  }

  egress_security_rules {
    protocol    = "17"
    destination = "10.0.10.0/24"
    stateless   = false
    description = "Enable network connectivity to mount FSS."
    udp_options {
        min = 2048
        max = 2048
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "10.0.10.0/24"
    stateless = false
    tcp_options {
      source_port_range {
        min = 111
        max = 111
      }
    }
    description = "Enable network connectivity to mount FSS."
  }

  ingress_security_rules {
    protocol  = "17"
    source    = "10.0.10.0/24"
    stateless = false
    udp_options {
      source_port_range {
        min = 111
        max = 111
      }
    }
    description = "Enable network connectivity to mount FSS."
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "10.0.10.0/24"
    stateless = false
    tcp_options {
      source_port_range {
        min = 2048
        max = 2050
      }
    }
    description = "Enable network connectivity to mount FSS."
  }

  vcn_id = oci_core_vcn.oke_cluster_vcn.id
}

# ------ Create Subnets 
resource oci_core_subnet oke_lb_subset {
  cidr_block    = "10.0.20.0/24"
  compartment_id = var.compartment_ocid
  dhcp_options_id = oci_core_vcn.oke_cluster_vcn.default_dhcp_options_id
  dns_label       = "lbsubnet"
  prohibit_internet_ingress  = "false"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_vcn.oke_cluster_vcn.default_route_table_id
  security_list_ids = [
    oci_core_vcn.oke_cluster_vcn.default_security_list_id,
  ]
  vcn_id = oci_core_vcn.oke_cluster_vcn.id
}

resource oci_core_subnet oke_api_subset {
  cidr_block     = "10.0.0.0/28"
  compartment_id = var.compartment_ocid
  dhcp_options_id = oci_core_vcn.oke_cluster_vcn.default_dhcp_options_id
  dns_label       = "apisubnet"
  prohibit_internet_ingress  = "false"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_vcn.oke_cluster_vcn.default_route_table_id
  security_list_ids = [
    oci_core_security_list.oke_k8sApiEndpoint_cluster_sec_list.id,
  ]
  vcn_id = oci_core_vcn.oke_cluster_vcn.id
}

resource oci_core_subnet oke_nodes_subset {
  cidr_block = "10.0.10.0/24"
  compartment_id = var.compartment_ocid
  dhcp_options_id = oci_core_vcn.oke_cluster_vcn.default_dhcp_options_id
  dns_label       = "nodesubnet"
  prohibit_internet_ingress  = "true"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.oke_routetable.id
  security_list_ids = [
    oci_core_security_list.oke_node_sec_list.id,
    oci_core_security_list.oke_nodes_fss_access_sec_list.id
  ]
  vcn_id = oci_core_vcn.oke_cluster_vcn.id
}


# ------ Create Routetable
resource oci_core_route_table oke_routetable {
  compartment_id = var.compartment_ocid
  display_name = "oke private routetable for genomics cluster"
  route_rules {
    description       = "traffic to OCI services"
    destination       = "all-lhr-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.oke_service_gateway.id
  }
  route_rules {
    description       = "traffic to the internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.oke_cluster_ngw.id
  }
  vcn_id = oci_core_vcn.oke_cluster_vcn.id
}

