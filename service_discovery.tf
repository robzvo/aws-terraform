# Stand-in for the UUID segment CloudFormation extracted from AWS::StackId.
resource "random_id" "namespace_suffix" {
  byte_length = 6
}

# AWS::ServiceDiscovery::PrivateDnsNamespace ServiceDiscoveryNamespace
resource "aws_service_discovery_private_dns_namespace" "agent" {
  name = local.service_discovery_namespace_name
  vpc  = aws_vpc.agent.id

  properties {
    dns_properties {
      soa {
        ttl = var.service_discovery_soa_ttl
      }
    }
  }
}
