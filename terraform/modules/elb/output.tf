output "alb_arn" { value = aws_lb.alb.arn }
output "target_group_arn" { value = aws_lb_target_group.alb_tg.arn }
output "alb_sg_id" { value = aws_security_group.alb_sg.id }
