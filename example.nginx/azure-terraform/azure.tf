variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_subscription_id" {}
variable "azure_tenant_id" {}

variable "virtual_machine_admin_password" {}
variable "virtual_machine_admin_ssh_key_data" {}

variable "virtual_machine_size" {
    default = "Standard_A0"
}

provider "azurerm" {
    client_id       = "${var.azure_client_id}"
    client_secret   = "${var.azure_client_secret}"
    subscription_id = "${var.azure_subscription_id}"
    tenant_id       = "${var.azure_tenant_id}"
}

resource "azurerm_resource_group" "example" {
    name     = "Example.Nginx"
    location = "East US"
}

resource "azurerm_virtual_network" "example" {
    name                = "VirtualNetwork"
    location            = "${azurerm_resource_group.example.location}"
    resource_group_name = "${azurerm_resource_group.example.name}"
    address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "default" {
    name = "Default"
    resource_group_name = "${azurerm_resource_group.example.name}"
    virtual_network_name = "${azurerm_virtual_network.example.name}"
    address_prefix = "10.0.0.0/25"
}

resource "azurerm_subnet" "gateway" {
    name = "GatewaySubnet"
    resource_group_name = "${azurerm_resource_group.example.name}"
    virtual_network_name = "${azurerm_virtual_network.example.name}"
    address_prefix = "10.0.0.240/28"
}

resource "azurerm_network_security_group" "example" {
    name = "NetworkSecurityGroup"
    location = "${azurerm_resource_group.example.location}"
    resource_group_name = "${azurerm_resource_group.example.name}"

    security_rule {
        name = "SSH"
        priority = 1010
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name = "HTTP"
        priority = 1020
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "80"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name = "HTTPS"
        priority = 1030
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "443"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name = "Rancher_8080"
        priority = 1040
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "8080"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_public_ip" "virtual_network_gateway_public_ip" {
    name = "VirtualNetworkGatewayPublicIp"
    location = "${azurerm_resource_group.example.location}"
    resource_group_name = "${azurerm_resource_group.example.name}"
    public_ip_address_allocation = "Dynamic"
}

resource "azurerm_storage_account" "disk_storage_account" {
    name = "diskxharymnarbectusphysi"
    location = "${azurerm_resource_group.example.location}"
    resource_group_name = "${azurerm_resource_group.example.name}"
    account_type = "Standard_LRS"
}

resource "azurerm_storage_container" "vhds_storage_container" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.example.name}"
    storage_account_name = "${azurerm_storage_account.disk_storage_account.name}"
    container_access_type = "private"
}

resource "azurerm_storage_account" "diag_storage_account" {
    name = "diagxharymnarbectusphysi"
    location = "${azurerm_resource_group.example.location}"
    resource_group_name = "${azurerm_resource_group.example.name}"
    account_type = "Standard_LRS"
}

resource "azurerm_availability_set" "example" {
    name = "AvailabilitySet"
    location = "${azurerm_resource_group.example.location}"
    resource_group_name = "${azurerm_resource_group.example.name}"
}

resource "azurerm_network_interface" "network_interface_moby1" {
    name = "moby11618"
    location = "${azurerm_resource_group.example.location}"
    resource_group_name = "${azurerm_resource_group.example.name}"

    internal_dns_name_label = "moby1"

    network_security_group_id = "${azurerm_network_security_group.example.id}"

    ip_configuration {
        name = "ipconfig1"
        subnet_id = "${azurerm_subnet.default.id}"
        private_ip_address_allocation = "Static"
        private_ip_address = "10.0.0.4"
    }
}

resource "azurerm_virtual_machine" "virtual_machine_moby1" {
    name = "moby1"
    location = "${azurerm_resource_group.example.location}"
    resource_group_name = "${azurerm_resource_group.example.name}"
    network_interface_ids = ["${azurerm_network_interface.network_interface_moby1.id}"]

    vm_size = "${var.virtual_machine_size}"

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "16.10"
        version = "latest"
    }

    storage_os_disk {
        name = "moby1"
        vhd_uri = "${azurerm_storage_account.disk_storage_account.primary_blob_endpoint}${azurerm_storage_container.vhds_storage_container.name}/moby1.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "moby1"
        admin_username = "example"
        admin_password = "${var.virtual_machine_admin_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path = "/home/example/.ssh/authorized_keys"
            key_data = "${var.virtual_machine_admin_ssh_key_data}"
        }
    }
}
