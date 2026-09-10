variable "fleet_management_auth" {
    description = "token for fleetmanagement. Not optional"
}

variable "grafana_cloud_access_policy_token" {
    description = "allows terraform to do its stuff"
}

variable "stack_slug" {
    description = "name of the stack we're messing with"
    default = "somerfordcje"
}