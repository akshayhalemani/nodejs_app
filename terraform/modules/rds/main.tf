resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-sg"
  description = "Security group for app servers"
  vpc_id = var.app_vpc_id

  ingress { 
    from_port = var.db_port; 
    to_port = var.db_port; 
    protocol = "tcp"; 
    cidr_blocks = ["10.10.0.0/16"] 
    }
}

resource "aws_db_subnet_group" "rds_sb_group" {
  name       = "${var.name}-db-subnet"
  subnet_ids = var.private_subnet_ids
}
resource "aws_db_instance" "app_rds" {
  identifier          = "${var.name}-db"
  engine              = var.engine
  version              = var.version
  instance_class      = var.instance_class
  allocated_storage   = var.allocated_storage
  storage_encrypted   = true
  multi_az            = true
  username            = var.username
  password            = var.password
  db_subnet_group_name = aws_db_subnet_group.rds_sb_group.name
  vpc_security_group_ids = aws_security_group.rds_sg.id
}
