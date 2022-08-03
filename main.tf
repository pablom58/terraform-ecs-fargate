# ----- main.tf ----- #

# ----- VPC ----- #

module "vpc_module" {
  source               = "./vpc"
  name_prefix          = local.name_prefix
  billing_tag          = local.billing_tag
  vpc_cidr             = var.vpc_cidr
  max_subnets          = 4
  private_subnet_count = 2
  public_subnet_count  = 2
  private_cidrs        = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
  public_cidrs         = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

# ----- Security Groups ----- #

module "security_groups_module" {
  source        = "./security_groups"
  name_prefix   = local.name_prefix
  billing_tag   = local.billing_tag
  vpc_id        = module.vpc_module.vpc_id
  containers_sg = { for key, value in local.containers : key => { name = value.name, port = value.port, security_group = value.security_group } }
}

# ----- ALB ----- #

module "alb_module" {
  source              = "./alb"
  name_prefix         = local.name_prefix
  billing_tag         = local.billing_tag
  alb_vpc_id          = module.vpc_module.vpc_id
  alb_security_groups = [module.security_groups_module.alb_sg]
  alb_subnets         = module.vpc_module.public_subnets
  target_groups       = { for key, value in local.containers : key => { name = value.name, port = value.port, target_group = value.target_group } }
}

# ----- SSM ----- #

module "ssm_module" {
  source      = "./ssm"
  for_each    = local.containers
  name_prefix = local.name_prefix
  billing_tag = local.billing_tag
  container   = each.key
  ssm_secrets = each.value.ssm_secrets
}

# ----- ECR ----- #

module "ecr_module" {
  source              = "./ecr"
  name_prefix         = local.name_prefix
  billing_tag         = local.billing_tag
  max_image_versions  = 10
  containers_registry = { for key, value in local.containers : key => { name = value.name } }
}

# ----- ECS IAM ----- #

module "ecs_iam_module" {
  source      = "./ecs_iam"
  name_prefix = local.name_prefix
}

# ----- ECS ----- #

module "ecs_module" {
  source      = "./ecs"
  name_prefix = local.name_prefix
  billing_tag = local.billing_tag
}

# ----- ECS Tasks Definition ----- #

module "ecs_task_definition_module" {
  source                      = "./ecs_task_definition"
  name_prefix                 = local.name_prefix
  aws_region                  = var.aws_region
  ecs_task_execution_role_arn = module.ecs_iam_module.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.ecs_iam_module.ecs_task_role_arn
  task_definitions = { for key, value in local.containers : key => {
    name            = value.name,
    port            = value.port,
    task_definition = value.task_definition
    image           = "${module.ecr_module.ecr_image[value.name]}:${value.task_definition.image_tag}"
    secrets         = module.ssm_module[value.name].secrets
  } }
}

# ----- ECS Services ----- #

module "ecs_service_module" {
  source          = "./ecs_services"
  name_prefix     = local.name_prefix
  ecs_cluster_id  = module.ecs_module.ecs_cluster_id
  private_subnets = module.vpc_module.private_subnets
  services = { for key, value in local.containers : key => {
    name            = value.name
    port            = value.port
    task_definition = module.ecs_task_definition_module.task_definitions_arn[value.name]
    ecs_service     = value.ecs_service
    security_group  = module.security_groups_module.containers_sg[value.name]
    target_group    = module.alb_module.target_groups[value.name]
  } }
}

# ----- Autoscaling Module ----- #

module "ecs_autoscaling_module" {
  source           = "./ecs_autoscaling"
  name_prefix      = local.name_prefix
  ecs_cluster_name = module.ecs_module.ecs_cluster_name
  services = { for key, value in local.containers : key => {
    name            = value.name,
    ecs_autoscaling = value.ecs_autoscaling
    service_name    = module.ecs_service_module.service_name[value.name]
  } }
}