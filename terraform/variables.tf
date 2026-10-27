variable "subscription_id" {
  description = "Identifiant de l'abonnement Azure for Students"
  type        = string
}

variable "location" {
  description = "Région Azure autorisée pour l'abonnement et où les tailles de VM sont disponibles"
  type        = string
  default     = "austriaeast"
}
