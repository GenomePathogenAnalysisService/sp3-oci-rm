#This policy could be removed from each stack creation
#If a policy like this existed with wording like (I'm unsure of exact syntax):
#`Allow dynamic-group with tag <some tag> to ...`
#Then by adding a tag to the oci_identity_dynamic_group.HeadNode_DG.name and oci_identity_dynamic_group.Stack_DG.name
#to match this policy, they should get the access required without the extra policy
resource "oci_identity_policy" "HeadNode_Sandbox_Artifact_Policy" {
  #Lives in the sandbox compartment
  compartment_id = local.Sp3dev_sandbox_cid

  description = "Policy for Head Node and stack artifacts to access sandbox items in deployment ${local.Sp3_env_name}"

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.HeadNode_DG.name} to read all-artifacts in compartment id ${local.Sp3dev_sandbox_cid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.HeadNode_DG.name} to read secret-family in compartment id ${local.Sp3dev_sandbox_cid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.HeadNode_DG.name} to read objects in compartment id ${local.Sp3dev_sandbox_cid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.Stack_DG.name} to read buckets in compartment id ${local.Sp3dev_sandbox_cid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.Stack_DG.name} to manage objects in compartment id ${local.Sp3dev_sandbox_cid} where any {request.permission='OBJECT_CREATE', request.permission='OBJECT_OVERWRITE', request.permission='OBJECT_INSPECT', request.permission='OBJECT_READ'}",
  ]
  name = "${local.Sp3_env_name}_Stack_Sandbox_Access"
}

resource "oci_identity_dynamic_group" "Autoscaler_DG" {
  compartment_id = var.tenancy_ocid

  description   = "Group for Autoscaler in compartment ${local.Sp3_cid}"
  matching_rule = "ALL {instance.compartment.id = '${local.Sp3_cid}'}"
  name          = "${local.Sp3_env_name}_Autoscaler"
}


resource "oci_identity_policy" "Autoscaler_Comp_Policy" {
  #Lives in the stack compartment
  #Required
  compartment_id = local.Sp3_cid

  description = "Policy for Autoscaler and HeadNode access in compartment id ${local.Sp3_cid}"

  statements = [
  "Allow dynamic-group ${oci_identity_dynamic_group.Autoscaler_DG.name} to manage cluster-node-pools in compartment id ${local.Sp3_cid}",
  "Allow dynamic-group ${oci_identity_dynamic_group.Autoscaler_DG.name} to manage instance-family in compartment id ${local.Sp3_cid}",
  "Allow dynamic-group ${oci_identity_dynamic_group.Autoscaler_DG.name} to use subnets in compartment id ${local.Sp3_cid}",
  "Allow dynamic-group ${oci_identity_dynamic_group.Autoscaler_DG.name} to read virtual-network-family in compartment id ${local.Sp3_cid}",
  "Allow dynamic-group ${oci_identity_dynamic_group.Autoscaler_DG.name} to use vnics in compartment id ${local.Sp3_cid}",
  "Allow dynamic-group ${oci_identity_dynamic_group.Autoscaler_DG.name} to inspect compartments in compartment id ${local.Sp3_cid}",
  "Allow dynamic-group ${oci_identity_dynamic_group.HeadNode_DG.name} to manage all-resources in compartment id ${local.Sp3_cid}",
  ]

  name = "${local.Sp3_env_name}_Stack_Access"
}

resource "oci_identity_dynamic_group" "HeadNode_DG" {
  compartment_id = var.tenancy_ocid

  description   = "Group for Head Node in deployment ${local.Sp3_env_name}"
  matching_rule = "Any {Any {instance.id = '${local.Sp3Headnode_id}'}}"
  name          = "${local.Sp3_env_name}_HeadNode"
}

resource "oci_identity_dynamic_group" "Stack_DG" {
  compartment_id = var.tenancy_ocid

  description   = "All Compute instances in stack ${local.Sp3_env_name}"
  matching_rule = "Any {instance.compartment.id = '${local.Sp3_cid}'}"
  name          = "${local.Sp3_env_name}_Stack"
}


resource "oci_identity_compartment" "sp3_child_comp" {
  # If 'create child compartment' is true, create a new compartment else don't
  count = var.create_child_comp ? 1 : 0
  enable_delete  = true
  compartment_id = var.compartment_ocid
  description    = "Compartment for the SP3 Cluster with Deployment ID: ${local.Sp3_env_name}"
  name           = "deployment_${local.Sp3_env_name}"
}

resource time_sleep wait_compartment {
  depends_on        = [oci_identity_compartment.sp3_child_comp]
  create_duration   = "30s"
}

locals { 
  # If 'create child compartment' is true, use the new compartment otherwise use the parent
  Sp3_cid = var.create_child_comp ? oci_identity_compartment.sp3_child_comp[0].id : var.compartment_ocid
}
