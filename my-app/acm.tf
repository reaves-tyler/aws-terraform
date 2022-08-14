# resource "aws_acm_certificate" "cert" {
#   domain_name       = "*.talyph.xyz"
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }
