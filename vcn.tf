locals {
  Sp3_vcn_id                       = oci_core_vcn.Sp3_VCN.id
  Sp3_VCN_dhcp_options_id          = oci_core_vcn.Sp3_VCN.default_dhcp_options_id
  Sp3_VCN_domain_name              = oci_core_vcn.Sp3_VCN.vcn_domain_name
  Sp3_VCN_default_dhcp_options_id  = oci_core_vcn.Sp3_VCN.default_dhcp_options_id
  Sp3_VCN_default_security_list_id = oci_core_vcn.Sp3_VCN.default_security_list_id
  Sp3_VCN_default_route_table_id   = oci_core_vcn.Sp3_VCN.default_route_table_id
}

# ------ Create Virtual Cloud Network
resource "oci_core_vcn" "Sp3_VCN" {
  # Required
  compartment_id = local.Sp3_cid
  cidr_block     = "10.0.0.0/16"
  # Optional
  dns_label    = local.Sp3_deploy_id
  display_name = local.Sp3_env_name
  depends_on   = [time_sleep.wait_compartment]
}

# ------ Create Internet Gateway
resource "oci_core_internet_gateway" "Sp3_Igw" {
  # Required
  compartment_id = local.Sp3_cid
  vcn_id         = local.Sp3_vcn_id
  # Optional
  enabled      = true
  display_name = "${local.Sp3_env_name}-igw"
}

locals {
  Sp3_Igw_id = oci_core_internet_gateway.Sp3_Igw.id
}

# ------ Create NAT Gateway
resource "oci_core_nat_gateway" "Sp3Ng001" {
  # Required
  compartment_id = local.Sp3_cid
  vcn_id         = local.Sp3_vcn_id
  # Optional
  display_name  = "${local.Sp3_env_name}-ngw"
  block_traffic = false
}

locals {
  Sp3Ng001_id = oci_core_nat_gateway.Sp3Ng001.id
}

# ------ Create Security List
# ------- Update VCN Default Security List
resource "oci_core_default_security_list" "Pubsl001" {
  # Required
  manage_default_resource_id = local.Sp3_VCN_default_security_list_id
  egress_security_rules {
    # Required
    protocol    = "all"
    destination = "0.0.0.0/0"
    # Optional
    destination_type = "CIDR_BLOCK"
  }
  ingress_security_rules {
    # Required
    protocol = "6"
    source   = "0.0.0.0/0"
    # Optional
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = "22"
      max = "22"
    }
  }

  # Optional
  display_name = "${local.Sp3_env_name}-pubsl001"
}

locals {
  Pubsl001_id = oci_core_default_security_list.Pubsl001.id
}


# ------ Create Security List
resource "oci_core_security_list" "Privsl001" {
  # Required
  compartment_id = local.Sp3_cid
  vcn_id         = local.Sp3_vcn_id
  egress_security_rules {
    # Required
    protocol    = "all"
    destination = "0.0.0.0/0"
    # Optional
    destination_type = "CIDR_BLOCK"
  }
  ingress_security_rules {
    # Required
    protocol = "6"
    source   = "10.0.0.0/16"
    # Optional
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = "22"
      max = "22"
    }
  }

  # Optional
  display_name = "${local.Sp3_env_name}-privsl001"
}

locals {
  Privsl001_id = oci_core_security_list.Privsl001.id
}

resource oci_core_security_list sp3_fss_access_sec_list {
  compartment_id = local.Sp3_cid
  display_name = "sp3_fss_access_sec_list"

  egress_security_rules {
    protocol    = "6"
    destination = "10.0.1.0/24"
    stateless   = false
    description = "Enable network connectivity to mount FSS."
    tcp_options {
        min = 111
        max = 111
    }
  }

  egress_security_rules {
    protocol    = "17"
    destination = "10.0.1.0/24"
    stateless   = false
    description = "Enable network connectivity to mount FSS."
    udp_options {
        min = 111
        max = 111
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = "10.0.1.0/24"
    stateless   = false
    description = "Enable network connectivity to mount FSS."
    tcp_options {
        min = 2048
        max = 2050
    }
  }

  egress_security_rules {
    protocol    = "17"
    destination = "10.0.1.0/24"
    stateless   = false
    description = "Enable network connectivity to mount FSS."
    udp_options {
        min = 2048
        max = 2048
    }
  }

  egress_security_rules {
    description = "TCP access custom add"
    protocol    = "6"
    destination    = "10.0.1.0/24"
    destination_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  egress_security_rules {
    description = "UDP access custom add"
    protocol    = "17"
    destination    = "10.0.1.0/24"
    destination_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "10.0.1.0/24"
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
    source    = "10.0.1.0/24"
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
    source    = "10.0.1.0/24"
    stateless = false
    tcp_options {
      source_port_range {
        min = 2048
        max = 2050
      }
    }
    description = "Enable network connectivity to mount FSS."
  }

  ingress_security_rules {
    description = "TCP access custom add"
    protocol    = "6"
    source    = "10.0.1.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = "UDP access custom add"
    protocol    = "17"
    source    = "10.0.1.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  vcn_id         = local.Sp3_vcn_id
}


# ------ Create Route Table
# ------- Update VCN Default Route Table
resource "oci_core_default_route_table" "Pubrt001" {
  # Required
  manage_default_resource_id = local.Sp3_VCN_default_route_table_id
  route_rules {
    destination_type  = "CIDR_BLOCK"
    destination       = "0.0.0.0/0"
    network_entity_id = local.Sp3_Igw_id
    description       = ""
  }
  # Optional
  display_name = "${local.Sp3_env_name}-pubrt001"
}

locals {
  Pubrt001_id = oci_core_default_route_table.Pubrt001.id
}


# ------ Create Route Table
resource "oci_core_route_table" "Privrt001" {
  # Required
  compartment_id = local.Sp3_cid
  vcn_id         = local.Sp3_vcn_id
  route_rules {
    destination_type  = "CIDR_BLOCK"
    destination       = "0.0.0.0/0"
    network_entity_id = local.Sp3Ng001_id
    description       = ""
  }
  route_rules {
    destination       = "all-lhr-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = local.sgw_id
  }
  # Optional
  display_name = "${local.Sp3_env_name}-privrt001"
}

locals {
  Privrt001_id = oci_core_route_table.Privrt001.id
}


# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Pubsn001" {
  # Required
  compartment_id = local.Sp3_cid
  vcn_id         = local.Sp3_vcn_id
  cidr_block     = "10.0.0.0/24"
  # Optional
  display_name               = "${local.Sp3_env_name}-pubsn001"
  dns_label                  = "pubsn01"
  security_list_ids          = [local.Pubsl001_id]
  route_table_id             = local.Pubrt001_id
  dhcp_options_id            = local.Sp3_VCN_dhcp_options_id
  prohibit_public_ip_on_vnic = false
}

locals {
  Pubsn001_id          = oci_core_subnet.Pubsn001.id
  Pubsn001_domain_name = oci_core_subnet.Pubsn001.subnet_domain_name
}

# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Privsn001" {
  # Required
  compartment_id = local.Sp3_cid
  vcn_id         = local.Sp3_vcn_id
  cidr_block     = "10.0.1.0/24"
  # Optional
  display_name               = "${local.Sp3_env_name}-privsn001"
  dns_label                  = "privsn001"
  security_list_ids          = [local.Privsl001_id, oci_core_security_list.sp3_fss_access_sec_list.id]
  route_table_id             = local.Privrt001_id
  dhcp_options_id            = local.Sp3_VCN_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}

locals {
  Privsn001_id          = oci_core_subnet.Privsn001.id
  Privsn001_domain_name = oci_core_subnet.Privsn001.subnet_domain_name
}
resource oci_core_service_gateway sgw001 {
  compartment_id = local.Sp3_cid
  
  display_name = "sgw001"
  freeform_tags = {
  }
  services {
    service_id = "ocid1.service.oc1.uk-london-1.aaaaaaaatwg7f5mnzoapfunl66n2qkp4ormiykqk3hiwksum63gcyjk7ysla"
  }
  vcn_id = local.Sp3_vcn_id
}
locals {
  sgw_id          = oci_core_service_gateway.sgw001.id
}


