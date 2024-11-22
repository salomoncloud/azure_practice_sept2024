variable "nic" {
  type    = string
  default = "nic01-lablvl1"
}

variable "vm1" {
  type    = string
  default = "vmlvl1"
}

variable "vnet" {
  type    = string
  default = "vnet-lablvl1"
}

variable "pip" {
  type    = string
  default = "pip-lvl1"
}

variable "snet" {
  type    = string
  default = "snet-lvl1"
}

variable "cidr-vnet" {
  type    = string
  default = "10.100.0.0/16"
}

variable "cidr-snet" {
  type    = string
  default = "10.100.1.0/24"
}

variable "rglvl1" {
  type    = string
  default = "salomon-lablvl2"
}

variable "location" {
  type    = string
  default = "East US 2"
}

variable "admin" {
  type    = string
  default = "salomon.lubin@cgi.com"
}