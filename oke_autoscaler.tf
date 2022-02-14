
locals {
  cluster_autoscaler_image                            = "lhr.ocir.io/oracle/oci-cluster-autoscaler:1.20.0-4"
  cluster_autoscaler_min_nodes_default                = 3
  cluster_autoscaler_max_nodes_default                = 30
}

