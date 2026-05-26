# terraform - after provisioning, write to SSM
#
#
data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["public-subnet-a", "public-subnet-b"]
  }
}

resource "aws_ssm_parameter" "ecs_subnets" {
  name  = "/myapp/ecs/subnets"
  type  = "StringList"
  value = join(",", data.aws_subnets.public.ids)
}

resource "aws_ssm_parameter" "ecs_security_group" {
  name  = "/myapp/ecs/ephemeral/security_group"
  type  = "String"
  value = aws_security_group.ephemeral.id
}
