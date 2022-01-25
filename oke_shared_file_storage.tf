
# ------ Create File Storage File System
resource oci_file_storage_file_system work_fss {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name = "File System for Work"
}

resource oci_file_storage_file_system data_fss {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name = "File System for Data"
}


# ------ Create File Storage Export
resource oci_file_storage_export file_storage_work_export {
  export_set_id = oci_file_storage_export_set.file_storage_export_work_set.id
  file_system_id = oci_file_storage_file_system.work_fss.id
  path           = var.file_storage_work_path
}

resource oci_file_storage_export file_storage_work_export_2 {
  export_set_id = oci_file_storage_export_set.file_storage_export_work_set_2.id
  file_system_id = oci_file_storage_file_system.work_fss.id
  path           = var.file_storage_work_path
}

resource oci_file_storage_export file_storage_data_export {
  export_set_id = oci_file_storage_export_set.file_storage_export_data_set.id
  file_system_id = oci_file_storage_file_system.data_fss.id
  path           = var.file_storage_data_path
}

resource oci_file_storage_export file_storage_data_export_2 {
  export_set_id = oci_file_storage_export_set.file_storage_export_data_set_2.id
  file_system_id = oci_file_storage_file_system.data_fss.id
  path           = var.file_storage_data_path
}


# ------ Create File Export Sets
resource oci_file_storage_export_set file_storage_export_work_set {
    display_name = "File Storage Export for Work"
    mount_target_id = oci_file_storage_mount_target.file_storage_mount_sp3_target.id
}

resource oci_file_storage_export_set file_storage_export_work_set_2 {
    display_name = "File Storage Export for Work"
    mount_target_id = oci_file_storage_mount_target.file_storage_mount_sp3_target.id
}

resource oci_file_storage_export_set file_storage_export_data_set {
    display_name = "File Storage Export for Data"
    mount_target_id = oci_file_storage_mount_target.file_storage_mount_oke_target.id
}

resource oci_file_storage_export_set file_storage_export_data_set_2 {
    display_name = "File Storage Export for Data"
    mount_target_id = oci_file_storage_mount_target.file_storage_mount_oke_target.id
}


# ------ Create Mount Targets
resource oci_file_storage_mount_target file_storage_mount_sp3_target {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name = "File Storage Mount Target for SP3"
  subnet_id = oci_core_subnet.Privsn001.id
  #ip_address = "10.0.1.86"
  nsg_ids = [
  ]
}

resource oci_file_storage_mount_target file_storage_mount_oke_target {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name = "File Storage Mount Target for OKE"
  subnet_id = oci_core_subnet.oke_nodes_subset.id
  #ip_address = "10.0.10.86"
  nsg_ids = [
  ]
}