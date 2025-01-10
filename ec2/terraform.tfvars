region = "ap-northeast-1"

ec2_instances = {
  "ec2_001" = {
    instance_type          = "t2.micro"
    ami                    = "ami-08ce76bae392de7dc"
    key_name               = ""
    subnet_name              = "private1"
    vpc_security_group_names = ["ec2-sg"]
    tags = {
      Name        = "my-ec2-instance1",
      Environment = "dev"
    }
    user_data = "./userdata/ec2_userdata.sh"
  },
  "ec2_002" = {
    instance_type          = "t2.micro"
    ami                    = "ami-08ce76bae392de7dc"
    key_name               = ""
    subnet_name              = "private2"
    vpc_security_group_names = ["ec2-sg"]
    tags = {
      Name        = "my-ec2-instance2",
      Environment = "dev"
    }
    user_data = "./userdata/ec2_userdata.sh"
  }
}