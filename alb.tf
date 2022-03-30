module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = aws_vpc.Main.id
  subnets            = [aws_subnet.publicsubnets1.id, aws_subnet.privatesubnets1.id]
  security_groups    = [aws_security_group.sg_bastion_host.id, aws_security_group.sg_bastion_host.id]

  #access_logs = {
  #  bucket = "my-alb-logs"
  #}

  target_groups = [
    {
      name             = "tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = aws_instance.BastionHost.id
          port = 80
        },
        {
          target_id = aws_instance.Jenkins.id
          port = 8080
        },
		{
          target_id = aws_instance.App.id
          port = 8081
        }
      ]
    }
  ]
}  

resource "aws_lb_target_group_attachment" "tg" {
    target_group_arn = aws_lb_target_group.tg.arn
 
 # target to attach to this target group
    target_id        = "arn:aws:elasticloadbalancing:us-east-1:463178143075"
	#aws_lb_target_group.tg.id

    #  If the target type is alb, the targeted Application Load Balancer must have at least one listener whose port matches the target group port.
    port             = 80
}
