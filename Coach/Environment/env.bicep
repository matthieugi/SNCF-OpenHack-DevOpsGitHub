var subnetName = 'desktops'
var addressPrefix = '10.0.0.0/16'
var storageAccountName = 'bootdiags${uniqueString(resourceGroup().id)}'
var subnetPrefix = '10.0.0.0/24'
var virtualNetworkName = 'OpenHackVNET'
var networkSecurityGroupName = 'default-NSG'
var location = 'West Europe'

var userList = [
  'sdumoulin'
]

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

resource securityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vn 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: securityGroup.id
          }
        }
      }
    ]
  }
}

module vm './vm.bicep' = [for user in userList: {
  name: 'vm${user}'
  params: {
    adminUsername: user
    adminPassword: 'SNCFOpenHack2022!'
    storageUri: stg.properties.primaryEndpoints.blob
    vnetName: vn.name
    location: location
    subnetName: subnetName
  }
}]
