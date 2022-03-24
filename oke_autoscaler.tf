
resource "kubernetes_service_account" "cluster_autoscaler_sa" {
  count = local.cluster_autoscaler_enabled ? 1 : 0

  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }
  automount_service_account_token = true # workaround to support ORM deprecated terraform providers

  depends_on = [oci_containerengine_node_pool.oke_ca_node_pool]
}

resource "kubernetes_cluster_role" "cluster_autoscaler_cr" {
  count = local.cluster_autoscaler_enabled ? 1 : 0

  metadata {
    name = "cluster-autoscaler"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["events", "endpoints"]
    verbs      = ["create", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/status"]
    verbs      = ["update"]
  }
  rule {
    api_groups     = [""]
    resource_names = ["cluster-autoscaler"]
    resources      = ["endpoints"]
    verbs          = ["get", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["watch", "list", "get", "patch", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "services", "replicationcontrollers", "persistentvolumeclaims", "persistentvolumes"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["watch", "list"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses", "csinodes"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch", "patch"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create"]
  }
  rule {
    api_groups     = ["coordination.k8s.io"]
    resource_names = ["cluster-autoscaler"]
    resources      = ["leases"]
    verbs          = ["get", "update"]
  }

  depends_on = [oci_containerengine_node_pool.oke_ca_node_pool]
}
resource "kubernetes_role" "cluster_autoscaler_role" {
  count = local.cluster_autoscaler_enabled ? 1 : 0

  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create", "list", "watch"]
  }
  rule {
    api_groups     = [""]
    resource_names = ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
    resources      = ["configmaps"]
    verbs          = ["delete", "get", "update", "watch"]
  }

  depends_on = [oci_containerengine_node_pool.oke_ca_node_pool]
}
resource "kubernetes_cluster_role_binding" "cluster_autoscaler_crb" {
  count = local.cluster_autoscaler_enabled ? 1 : 0
  metadata {
    name = "cluster-autoscaler"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-autoscaler"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }

  depends_on = [oci_containerengine_node_pool.oke_ca_node_pool]
}
resource "kubernetes_role_binding" "cluster_autoscaler_rb" {
  count = local.cluster_autoscaler_enabled ? 1 : 0

  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cluster-autoscaler"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }

  depends_on = [oci_containerengine_node_pool.oke_ca_node_pool]
}

resource "kubernetes_deployment" "cluster_autoscaler_deployment" {
  count = local.cluster_autoscaler_enabled ? 1 : 0

  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      app = "cluster-autoscaler"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "cluster-autoscaler"
      }
    }

    template {
      metadata {
        labels = {
          app = "cluster-autoscaler"
        }
        annotations = {
          "prometheus.io/scrape" = true
          "prometheus.io/port"   = 8085
        }
      }

      spec {
        service_account_name = "cluster-autoscaler"

        container {
          image = local.cluster_autoscaler_image
          name  = "cluster-autoscaler"

          resources {
            limits = {
              cpu    = "100m"
              memory = "300Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "300Mi"
            }
          }
          command = [
            "./cluster-autoscaler",
            "--v=${local.cluster_autoscaler_app_version}",
            "--stderrthreshold=info",
            "--cloud-provider=oci",
            "--max-node-provision-time=${local.cluster_autoscaler_max_node_provision_time}",
            "--nodes=${local.cluster_autoscaler_min_nodes}:${local.cluster_autoscaler_max_nodes}:${local.cluster_autoscaler_node_pool}",
            "--scale-down-delay-after-add=${local.cluster_autoscaler_scale_down_delay_after_add}",
            "--scale-down-unneeded-time=${local.cluster_autoscaler_scale_down_unneeded_time}",
            "--unremovable-node-recheck-timeout=${local.cluster_autoscaler_unremovable_node_recheck_timeout}",
            "--balance-similar-node-groups",
            "--balancing-ignore-label=displayName",
            "--balancing-ignore-label=hostname",
            "--balancing-ignore-label=internal_addr",
            "--balancing-ignore-label=oci.oraclecloud.com/fault-domain",
            "--skip-nodes-with-system-pods=false",
            "--skip-nodes-with-local-storage=false",
            "--scale-down-utilization-threshold=0.5"
          ]
          image_pull_policy = "Always"
          env {
            name  = "OKE_USE_INSTANCE_PRINCIPAL"
            value = "true"
          }
        }
      }
    }
  }

  depends_on = [oci_containerengine_node_pool.oke_ca_node_pool]
}


provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = local.cluster_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["ce", "cluster", "generate-token", "--cluster-id", local.cluster_id, "--region", local.cluster_region]
    command     = "oci"
  }
}

locals {
  cluster_autoscaler_supported_k8s_versions           = { "1.18" = "1.18.3-4", "1.19" = "1.19.1-4", "1.20" = "1.20.0-4", "1.21" = "1.21.1-1" } # There's no API to get that list. Need to be updated manually
  cluster_autoscaler_image                            = "lhr.ocir.io/oracle/oci-cluster-autoscaler:1.20.0-4"
  cluster_autoscaler_app_version                      = 4
  cluster_autoscaler_node_pool                        = oci_containerengine_node_pool.oke_ca_node_pool.id
  cluster_autoscaler_min_nodes                        = var.oke_cluster_autoscaler_min_nodes
  cluster_autoscaler_max_nodes                        = var.oke_cluster_autoscaler_max_nodes
  cluster_autoscaler_max_node_provision_time          = "15m"
  cluster_autoscaler_scale_down_delay_after_add       = "10m"
  cluster_autoscaler_scale_down_unneeded_time         = "10m"
  cluster_autoscaler_unremovable_node_recheck_timeout = "5m"
  cluster_autoscaler_enabled                          = var.oke_cluster_autoscaler_enabled
  cluster_endpoint       = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["certificate-authority-data"])
  cluster_id             = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][4]
  cluster_region         = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][6]

}

data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = oci_containerengine_cluster.oke_containerengine_cluster.id
  depends_on = [oci_containerengine_node_pool.oke_ca_node_pool]
}


