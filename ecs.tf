# ECS Cluster
resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-cluster"
}

# Task Definition
resource "aws_ecs_task_definition" "medusa_task" {
  family                   = "medusa-task"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = "512"
  memory                  = "1024"
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "medusa-container",
      image     = "medusajs/medusa:latest",
      portMappings = [
        {
          containerPort = 9000,
          hostPort      = 9000
        }
      ],
      environment = [
        {
          name  = "DATABASE_URL",
          value = "postgres://medusa_user:adarsh6772@medusa-db.c18issk8o78n.eu-north-1.rds.amazonaws.com:5432/medusa-db"
        }
      ]
    }
  ])
}

# ECS Fargate Service
resource "aws_ecs_service" "medusa_service" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa_cluster.id
  task_definition = aws_ecs_task_definition.medusa_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = [
      "subnet-0f5e5d72842cbd701",
      "subnet-0f21371ecc142b78b",
      "subnet-005fd3d264a1e85bc"
    ]
    assign_public_ip = true
    security_groups  = ["sg-096fcc1e31d4c96bb"]
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]
}
