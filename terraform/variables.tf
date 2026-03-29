variable "function_name" {
  description = "OpenFaaS function name."
  type        = string
  default     = "hello-world"
}

variable "function_image" {
  description = "Public container image for the OpenFaaS function. OpenFaaS Community Edition rejects private images."
  type        = string
  default     = "replace-me/hello-world:latest"
}

variable "gateway_url" {
  description = "OpenFaaS gateway URL."
  type        = string
  default     = "http://127.0.0.1:8080"
}

variable "release_id" {
  description = "Value used to trigger a redeploy when the image or stack changes."
  type        = string
  default     = "manual"
}
