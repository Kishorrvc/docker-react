# # Provision aws EB, S3 using Terraform
# provider "aws" {
#   region = "us-east-1"
# }

# resource "aws_s3_bucket" "ebs_react_bucket" {
#   bucket = "ebs-react-bucket"

#   tags = {
#     Name        = "ebs-react-bucket"
#     Environment = "Dev"
#   }
#   force_destroy = true
# }



# resource "aws_elastic_beanstalk_application" "react_app" {
#   name        = "beanstalk-react-app"
#   description = "React Application via Github actions"
#   tags = {
#     Name        = "beanstalk-react-app"
#     Environment = "Dev"
#   }
# }
# resource "aws_elastic_beanstalk_environment" "tfenvtest" {
#   name                = "beanstalk-react-app-env"
#   application         = aws_elastic_beanstalk_application.react_app.name
#   solution_stack_name = "64bit Amazon Linux 2015.03 v2.0.3 running Go 1.4"
#   #   setting {
#   #     namespace = "aws:autoscaling:launchconfiguration"
#   #     name      = "IamInstanceProfile"
#   #     value     = data.aws_iam_role.eb-role.name
#   #   }
# }

# resource "aws_iam_role" "ec2_role" {
#   name = "ec2-instance-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_instance_profile" "ec2_instance_profile" {
#   name = "ec2-instance-profile"
#   role = aws_iam_role.ec2_role.name
# }

# resource "aws_instance" "aws_instance" {
#   ami           = "ami-08982f1c5bf93d976"
#   instance_type = "t2.micro"

#   iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

#   tags = {
#     Name = "Terraform-EC2"
#   }
# }


# # resource "aws_iam_instance_profile" "ec2-role" {
# #   name = "aws-elasticbeanstalk-ec2-role"
# #   enti
# # }

# # resource "aws_iam_role" "eb-role" {
# #   name = "aws-elasticbeanstalk-service-role"
# # }

# resource "aws_iam_role" "eb_role" {
#   name = "elasticbeanstalk-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "web_tier" {
#   role       = aws_iam_instance_profile.ec2_instance_profile.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
# }

# resource "aws_iam_role_policy_attachment" "worker_tier" {
#   role       = aws_iam_instance_profile.ec2_instance_profile.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
# }

# resource "aws_iam_role_policy_attachment" "multicontainer_docker" {
#   role       = aws_iam_instance_profile.ec2_instance_profile.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
# }


# # data "aws_iam_role" "eb-role" {
# #   name = "aws-elasticbeanstalk-service-role"
# # }

# # resource "aws_iam_instance_profile" "ec2-role" {
# # }


provider "aws" {
  region = "us-east-1" # Change if needed
}

# 1. IAM Role (Trusted Entity = EC2)
resource "aws_iam_role" "eb_ec2_role" {
  name = "aws-elasticbeanstalk-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 2. Attach Required Elastic Beanstalk Policies
resource "aws_iam_role_policy_attachment" "web_tier" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "worker_tier" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "multicontainer_docker" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

# 3. Create Instance Profile (needed to attach role to EC2 instances)
resource "aws_iam_instance_profile" "eb_ec2_instance_profile" {
  name = "aws-elasticbeanstalk-ec2-role"
  role = aws_iam_role.eb_ec2_role.name
}

# S3 bucket for EB (to store application versions)
# resource "aws_s3_bucket" "ebs_react_bucket" {
#   bucket = "ebs-react-bucket"

#   tags = {
#     Name        = "ebs-react-bucket"
#     Environment = "Dev"
#   }
#   force_destroy = true
# }
# elasticbeanstalk-us-east-1-599117007570


# Reference the existing EB bucket
# Replace with the actual name (check S3 console)
data "aws_s3_bucket" "eb_bucket" {
  bucket = "elasticbeanstalk-us-east-1-599117007570"
  #   force_destroy = true
}

# 1. Update bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "eb_bucket_controls" {
  bucket = data.aws_s3_bucket.eb_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# 2. Enable ACLs (set bucket ACL)
resource "aws_s3_bucket_acl" "eb_bucket_acl" {
  bucket = data.aws_s3_bucket.eb_bucket.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.eb_bucket_controls]
}


# 1. IAM Role (Trusted Entity = Elastic Beanstalk service)
resource "aws_iam_role" "eb_service_role" {
  name = "aws-elasticbeanstalk-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 2. Attach Required Managed Policies
resource "aws_iam_role_policy_attachment" "enhanced_health" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

# resource "aws_iam_role_policy_attachment" "managed_updates" {
#   role       = aws_iam_role.eb_service_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
# }

# -----------------------
# 1. Elastic Beanstalk Application
# -----------------------
resource "aws_elastic_beanstalk_application" "react_app" {
  name        = "react-frontend"
  description = "React frontend running on Docker"
}

# -----------------------
# 2. Elastic Beanstalk Environment
# -----------------------
resource "aws_elastic_beanstalk_environment" "react_env" {
  name         = "react-frontend-env"
  application  = aws_elastic_beanstalk_application.react_app.name
  platform_arn = "arn:aws:elasticbeanstalk:us-east-1::platform/Docker running on 64bit Amazon Linux 2/4.3.1"

  #   solution_stack_name = "64bit Amazon Linux 2 v3.8.1 running Docker"
  # 🔹 check AWS EB docs for the latest Docker solution stack names in your region
  # "arn:aws:elasticbeanstalk:us-east-1::platform/Docker running on 64bit Amazon Linux 2/3.5.2"
  # "arn:aws:elasticbeanstalk:us-east-1::platform/Docker running on 64bit Amazon Linux 2/3.4.11"
  # ...

  # Preset: Free tier eligible = t2.micro instance
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  # Attach the EC2 Instance Profile
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  # Attach the Service Role
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "aws-elasticbeanstalk-service-role"
  }

  # Ensure environment is accessible
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }
}
