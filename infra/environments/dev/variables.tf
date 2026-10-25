variable "location" {
  description = "Azure-Region für alle Ressourcen dieser Umgebung."
  type        = string
  default     = "switzerlandnorth"
}

variable "environment" {
  description = "Name der Umgebung, z.B. dev, test oder prod."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment muss dev, test oder prod sein."
  }
}

variable "workload" {
  description = "Kurzname des Workloads, wird in Ressourcennamen und Tags verwendet."
  type        = string
  default     = "lab"
}
