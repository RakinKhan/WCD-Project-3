# Variable block for Security Group ports.
variable "ingress_ports" {
  type        = list(number)
  default     = [22, 80, 443]
  description = "SSH, HTTP, HTTPS ports for Ingress"
}