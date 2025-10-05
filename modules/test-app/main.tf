locals {
  rendered_app_py = file("${path.module}/app.py")
  rendered_deployment = templatefile("${path.module}/deployment.yaml", { name_prefix = var.name_prefix })
  rendered_configmap = templatefile("${path.module}/configmap.yaml", { name_prefix = var.name_prefix, app_py = indent(4, local.rendered_app_py) })
  manifests = join("\n---\n", [local.rendered_configmap, local.rendered_deployment])
}

resource "local_file" "manifests" {
  count    = var.enabled ? 1 : 0
  content  = local.manifests
  filename = "${path.module}/rendered-${var.name_prefix}-test.yaml"
}

resource "null_resource" "apply" {
  count = var.enabled ? 1 : 0
  provisioner "local-exec" {
    command = <<EOT
set -e
aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}
kubectl apply -f ${local_file.manifests[0].filename}
EOT
  }
  triggers = {
    manifest_sha = var.enabled ? md5(local.manifests) : ""
  }
}

output "manifests_file" {
  value = var.enabled ? local_file.manifests[0].filename : ""
}
