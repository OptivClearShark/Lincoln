resource "aws_security_group" "splunk_instance" {
  name_prefix = "${var.project_name}-splunk-"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Splunk Web Interface"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Splunk Management Port"
  }

  ingress {
    from_port   = 9997
    to_port     = 9997
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Splunk Indexer Port"
  }
  tags = {
    Name = "${var.project_name}-splunk-sg"
  }
}
