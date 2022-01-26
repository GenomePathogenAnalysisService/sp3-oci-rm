
# ------ Create File Storage File System
resource oci_file_storage_file_system work_fss {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
  compartment_id      = var.compartment_ocid
  display_name = "File System for Work"
}

resource oci_file_storage_file_system data_fss {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
  compartment_id      = var.compartment_ocid
  display_name = "File System for Data"
}




# ------ Create File Storage Export
resource oci_file_storage_export file_storage_work_export_oke {
  export_set_id = oci_file_storage_export_set.file_storage_export_set_work_oke.id
  file_system_id = oci_file_storage_file_system.work_fss.id
  path           = var.file_storage_work_path
}

resource oci_file_storage_export file_storage_work_export_sp3 {
  export_set_id = oci_file_storage_export_set.file_storage_export_set_work_sp3.id
  file_system_id = oci_file_storage_file_system.work_fss.id
  path           = var.file_storage_work_path
}

resource oci_file_storage_export file_storage_data_export_oke {
  export_set_id = oci_file_storage_export_set.file_storage_export_set_data_oke.id
  file_system_id = oci_file_storage_file_system.data_fss.id
  path           = var.file_storage_data_path
}

resource oci_file_storage_export file_storage_data_export_sp3 {
  export_set_id = oci_file_storage_export_set.file_storage_export_set_data_sp3.id
  file_system_id = oci_file_storage_file_system.data_fss.id
  path           = var.file_storage_data_path
}


# ------ Create File Export Sets
resource oci_file_storage_export_set file_storage_export_set_work_oke {
    display_name = "File Storage Export for Work OKE"
    mount_target_id = oci_file_storage_mount_target.file_storage_mount_oke_target.id
}

resource oci_file_storage_export_set file_storage_export_set_work_sp3 {
    display_name = "File Storage Export for Work SP3"
    mount_target_id = oci_file_storage_mount_target.file_storage_mount_sp3_target.id
}

resource oci_file_storage_export_set file_storage_export_set_data_oke {
    display_name = "File Storage Export for Data OKE"
    mount_target_id = oci_file_storage_mount_target.file_storage_mount_oke_target.id
}

resource oci_file_storage_export_set file_storage_export_set_data_sp3 {
    display_name = "File Storage Export for Data Sp3"
    mount_target_id = oci_file_storage_mount_target.file_storage_mount_sp3_target.id
}


# ------ Create Mount Targets
resource oci_file_storage_mount_target file_storage_mount_sp3_target {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
  compartment_id      = var.compartment_ocid
  display_name = "File Storage Mount Target for SP3"
  subnet_id = oci_core_subnet.Privsn001.id
  #ip_address = "10.0.1.86"
  nsg_ids = [
  ]
}

resource oci_file_storage_mount_target file_storage_mount_oke_target {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
  compartment_id      = var.compartment_ocid
  display_name = "File Storage Mount Target for OKE"
  subnet_id = oci_core_subnet.oke_nodes_subset.id
  #ip_address = "10.0.10.86"
  nsg_ids = [
  ]
}