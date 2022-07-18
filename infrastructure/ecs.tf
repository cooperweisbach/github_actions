locals {
  ecs_service_names = var.ecs_service_names
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "es-springboot-dev1-cluster"

}

resource "aws_ecs_task_definition" "sample-fargate" {
  family                   = "sample-fargate"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn = "arn:aws:iam::807583230527:role/sample_ecs_execution_role"
  task_role_arn = "arn:aws:iam::807583230527:role/sample_ecs_task_role"
  cpu                      = 256
  memory                   = 512
  container_definitions    = <<TASK_DEFINITION
    [
        {
            "name": "fargate-app", 
            "image": "public.ecr.aws/docker/library/httpd:latest", 
            "portMappings": [
                {
                    "containerPort": 80, 
                    "hostPort": 80, 
                    "protocol": "tcp"
                }
            ], 
            "essential": true, 
            "entryPoint": [
                "sh",
        "-c"
            ], 
            "command": [
                "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
            ]
        }
    ]
    TASK_DEFINITION
}

resource "aws_ecs_service" "sample-service" {
  count           = length(local.ecs_service_names)
  name            = "${local.ecs_service_names[count.index]}"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.sample-fargate.arn
  desired_count   = 1
  launch_type = "FARGATE"
  network_configuration {
    subnets = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]
  }
}