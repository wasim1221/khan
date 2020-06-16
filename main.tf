provider "aws" {
  region = "us-east-1"
  profile = "wasim"
}
resource "aws_instance" "webserver" {
  ami = "ami-098f16afa9edf40be"
  instance_type = "t2.micro"
  key_name = "wasim1111"
  security_groups = [ "wasim-3", ]

  tags = {
    Name = "khan"
  }
}


resource "aws_security_group" "wasim-3" {
  name        = "wasim-3"
  description = "Allow http and ssh inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_from_terraform"
  }
}

//CREATING THE EBS VOLUME

resource "aws_ebs_volume" "myvol" {
    availability_zone    = aws_instance.webserver.availability_zone
    size                = 5
    tags = {
        Name             = "myvol"
    }
}
//CREATING THE BUCKET

resource "aws_s3_bucket" "terra_s3" {
  bucket = "wasims3"
  acl    = "public-read"

tags = {
    Name        = "My bucket"
  }
}
 //CREATING THE CLOUDFRONT DISTRIBUTION

resource "aws_cloudfront_distribution" "cldfor" {
    origin{
        domain_name       = aws_s3_bucket.wasims3.bucket_regional_domain_name
        origin_id         = local.s3_origin_id
    }
    
    enabled               = true
    is_ipv6_enabled       = true

    default_cache_behavior {
        allowed_methods   = ["DELETE","PATCH","OPTIONS","POST","PUT","GET", "HEAD"]
        cached_methods    = ["GET", "HEAD"]
        target_origin_id  = local.s3_origin_id

        forwarded_values {
            query_string  = false

            cookies {
                forward   = "none"
            }
        }

        min_ttl                = 0
        default_ttl            = 3600
        max_ttl                = 86400
        compress               = true
        viewer_protocol_policy = "allow-all"
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }
}
