resource oci_file_storage_file_system oke_work_fss {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name = "File System for OKE Work"
}


resource oci_file_storage_mount_target oke_file_storage_mount_target {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name = "File Storage Mount Target for OKE Work"
  subnet_id = oci_core_subnet.oke_nodes_subset.id
  nsg_ids = [
  ]
}


resource oci_file_storage_export_set oke_file_storage_export_work_set {
    display_name = "File Storage Export for OKE"
    mount_target_id = oci_file_storage_mount_target.oke_file_storage_mount_target.id
}


resource oci_file_storage_export oke_file_storage_work_export {

  export_set_id = oci_file_storage_export_set.oke_file_storage_export_work_set.id
  file_system_id = oci_file_storage_file_system.oke_work_fss.id
  path           = var.file_storage_work_path
}






resource oci_file_storage_file_system oke_data_fss {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name = "File System for OKE Data"
}


resource oci_file_storage_export_set oke_file_storage_export_data_set {
    display_name = "File Storage Export for OKE Data"
    mount_target_id = oci_file_storage_mount_target.oke_file_storage_mount_target.id
}


resource oci_file_storage_export oke_file_storage_data_export {

  export_set_id = oci_file_storage_export_set.oke_file_storage_export_data_set.id
  file_system_id = oci_file_storage_file_system.oke_data_fss.id
  path           = var.file_storage_data_path
}



