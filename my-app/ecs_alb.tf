resource "aws_lb_target_group" "api" {
  name        = "${var.environment}-api"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.app_vpc.id

  health_check {
    enabled = true
    path    = "/"
  }

  depends_on = [aws_alb.api]
}

resource "aws_alb" "api" {
  name               = "${var.environment}-api-lb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_d.id,
    aws_subnet.public_e.id,
  ]

  security_groups = [
    aws_security_group.http.id,
    aws_security_group.https.id,
    aws_security_group.egress_all.id,
  ]

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_alb_listener" "api_http" {
  load_balancer_arn = aws_alb.api.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:811466563163:certificate/a85ced26-466c-49a3-917c-76e4511ece00"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

output "alb_url" {
  value = "https://${aws_alb.api.dns_name}"
}
