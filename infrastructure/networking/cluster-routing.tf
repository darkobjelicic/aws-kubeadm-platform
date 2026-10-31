resource "aws_internet_gateway" "cluster" {
    vpc_id = aws_vpc.cluster.id

    tags = {
        Name = "kubeadm-platform-igw"
    }
}

resource "aws_route_table" "cluster_public" {
    vpc_id = aws_vpc.cluster.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.cluster.id
    }

    tags = {
        Name = "kubeadm-platform-public"
    }
}

resource "aws_route_table_association" "cluster_public" {
    subnet_id      = aws_subnet.cluster_public.id
    route_table_id = aws_route_table.cluster_public.id
}

resource "aws_route_table" "cluster_private" {
    vpc_id = aws_vpc.cluster.id

    route {
        cidr_block           = "0.0.0.0/0"
        network_interface_id = aws_instance.cluster_nat.primary_network_interface_id
    }

    tags = {
        Name = "kubeadm-platform-private"
    }
}

resource "aws_route_table_association" "cluster_private" {
    subnet_id      = aws_subnet.cluster_private.id
    route_table_id = aws_route_table.cluster_private.id
}
