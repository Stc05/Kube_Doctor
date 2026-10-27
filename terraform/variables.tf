variable "subscription_id" {
  description = "Identifiant de l'abonnement Azure for Students"
  type        = string
}

variable "location" {
  description = "Région Azure autorisée pour l'abonnement et où les tailles de VM sont disponibles"
  type        = string
  default     = "austriaeast"
}

variable "kubernetes_version" {
  description = "Version mineure de Kubernetes, couverte par le support standard d'AKS"
  type        = string
  default     = "1.35"
}

variable "node_count" {
  description = "Nombre de nœuds du cluster (2 x 2 vCPU, sous le quota régional de 6)"
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "Taille des nœuds, disponible en Austria East pour l'abonnement étudiant"
  type        = string
  default     = "Standard_B2s_v2"
}
