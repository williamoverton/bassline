resource "random_id" "container_id" {
  keepers = {
    new = "${uuid()}"
  }

  byte_length = 8
}

resource "null_resource" "get_ecr_login" {

  triggers = {
    everytime = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "$(aws ecr get-login --no-include-email --region ${var.aws_region})"
  }

  depends_on = ["random_id.container_id"]
}

resource "null_resource" "build_container" {

  triggers = {
    everytime = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "docker build -t vault-${random_id.container_id.keepers.new} ${path.module}/src"
  }

  depends_on = ["null_resource.get_ecr_login"]
}

resource "null_resource" "tag_container" {

  triggers = {
    everytime = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "docker tag vault-${random_id.container_id.keepers.new} ${aws_ecr_repository.bl_vault_ecr_repo.repository_url}:latest"
  }

  depends_on = ["null_resource.build_container"]
}


resource "null_resource" "push_container" {

  triggers = {
    everytime = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.bl_vault_ecr_repo.repository_url}:latest"
  }

  depends_on = ["null_resource.tag_container"]
}
