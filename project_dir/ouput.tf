output "vpc_id" {
  
  value = module.vpc.vpc.id
}
/* output "instance_ip" {
  
  value = aws_instance.instance.private_ip
} */

output "private_subnet_ids" {

  value = module.vpc.private_subnet
}

output "public_subnet_ids" {
  
  value = module.vpc.public_subnet
}

output "tg_arn" {
  
  value = module.alb.tg.arn
}