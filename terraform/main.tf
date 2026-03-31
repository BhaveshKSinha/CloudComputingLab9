terraform {
  required_version = ">= 1.5.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

resource "null_resource" "hello_world" {
  triggers = {
    function_name  = var.function_name
    function_image = var.function_image
    gateway_url    = var.gateway_url
    release_id     = var.release_id
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/.."
    interpreter = ["PowerShell", "-Command"]
    command     = "(Get-Content function/hello-world.yml -Raw).Replace('__FUNCTION_IMAGE__', '${self.triggers.function_image}') | Set-Content function/hello-world.rendered.yml; faas-cli template store pull python3-http; faas-cli deploy -f function/hello-world.rendered.yml -g ${self.triggers.gateway_url}"
  }

  provisioner "local-exec" {
    when        = destroy
    working_dir = "${path.module}/.."
    interpreter = ["PowerShell", "-Command"]
    command     = "faas-cli remove ${self.triggers.function_name} -g ${self.triggers.gateway_url}"
  }
}

output "function_name" {
  value = null_resource.hello_world.triggers.function_name
}

output "gateway_url" {
  value = null_resource.hello_world.triggers.gateway_url
}
