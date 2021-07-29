# Network Security Group for the Bastion


resource "oci_core_network_security_group" "bastion_nsg" {
  display_name   = "${local.Sp3_env_name}-bastion-nsg"
  vcn_id         = local.Sp3_vcn_id
  compartment_id = local.Sp3_cid
}

locals {
  bastion_nsg_id = oci_core_network_security_group.bastion_nsg.id
}
