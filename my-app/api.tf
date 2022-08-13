resource "aws_ecs_cluster" "app" {
  name = "my-api-${var.environment}"
}

resource "aws_ecs_service" "api" {
  name            = "api-${var.environment}"
  task_definition = aws_ecs_task_definition.api.arn
  cluster         = aws_ecs_cluster.app.id
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.egress_all.id,
      aws_security_group.ingress_api.id,
    ]

    subnets = [
      aws_subnet.private_d.id,
      aws_subnet.private_e.id,
    ]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "api"
    container_port   = "8080"
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "api-${var.environment}"
  execution_role_arn       = aws_iam_role.api_task_execution_role.arn
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"


  container_definitions = <<EOF
  [
    {
      "name": "api",
      "image": "nginx",
      "portMappings": [
        {
          "containerPort": 8080
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "${var.region}",
          "awslogs-group": "/ecs/api-${var.environment}",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  EOF
}

resource "aws_cloudwatch_log_group" "api" {
  name = "/ecs/api-${var.environment}"
}

resource "aws_iam_role" "api_task_execution_role" {
  name               = "api-task-execution-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach the above policy to the execution role.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.api_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}
