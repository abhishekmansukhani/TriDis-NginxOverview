# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = ""
    client_id       = ""
    client_secret   = ""
    tenant_id       = ""
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
        name = "Rancher_IPsec500"
        priority = 1040
        direction = "Inbound"
        access = "Allow"
        protocol = "Udp"
        source_port_range = "*"
        destination_port_range = "500"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name = "Rancher_IPsec4500"
        priority = 1050
        direction = "Inbound"
        access = "Allow"
        protocol = "Udp"
        source_port_range = "*"
        destination_port_range = "4500"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_public_ip" "virtual_network_gateway_public_ip" {
    name = "VirtualNetworkGatewayPublicIP"
    location = "${azurerm_resource_group.example.location}"
    resource_group_name = "${azurerm_resource_group.example.name}"
    public_ip_address_allocation = "Dynamic"
}

#
# ToDo:
#
#resource "null_resource" "virtual_network_gateway" {
#    provisioner "local-exec" {
#        command = "powershell -noprofile -command \"$ErrorActionPreference = 'Stop'; Set-PsDebug -Strict; .\\Invoke-AzureRmVirtualNetworkGatewayCreation.ps1\""
#    }
#    depends_on = ["${azure_virtual_network.example}",
#                  "${azurerm_subnet.gateway}"
#                  "${azurerm_public_ip.virtual_network_gateway_public_ip}"]
#}

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
    vm_size = "Standard_A0"

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
        admin_password = ""
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path = "/home/example/.ssh/authorized_keys"
            key_data = ""
        }
    }
}