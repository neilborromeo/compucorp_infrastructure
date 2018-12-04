variable "region" {
    default = "us-east-1"
}
variable "az_1" {
    default = "a"
}

variable "public_key_path" {
/*  description = <<END
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can connect.
Example: ~/.ssh/terraform.pub
END */
  default = "~/.ssh/compucorp.pub"
}

variable "environment" {
  type = "map"
  default = {
    "description" = "Environment short name to add to the instances names and so"
    "name" = "CompucorpStaging"
    "prefix" = "STG"
  }
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "compucorp_staging"
}

variable "amis" {
#Custom AMI
    default = {
        us-east-1 = "ami-02d82bad6ee99f275" # Ubuntu 16.04
    }
}

variable "aws_account_id" {
    description = "Used to create the S3 Policy in order to allow access for the ELB's to write logs into a bucket"
    default = "317463987914"
}
