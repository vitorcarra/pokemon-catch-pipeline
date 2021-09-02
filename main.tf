provider "aws" {
    region = var.aws_region
    profile = var.aws_profile
}

# module "iam" {
#     source = "./iam"
    
#     project_name = var.project_name
# }

module "network" {
    source = "./network"

    project_name = var.project_name
    region = var.aws_region
}

# module "lambda_layer_local" {
#   source = "terraform-aws-modules/lambda/aws"

#   create_layer        = true
#   layer_name          = "${var.project_name}-pandas-layer-dockerfile"
#   compatible_runtimes = ["python3.7"]

#   source_path = "${path.module}/lambda/pandas_layer"
#   hash_extra  = "extra-hash-to-prevent-conflicts-with-module.package_dir"

# #   build_in_docker = true
# #   runtime         = "python3.7"
# #   docker_pip_cache      = true
# #   docker_image      = "lambci/lambda:build-python3.7"
# #   # docker_file = "${path.module}/lambda/pandas_layer/Dockerfile"
# #   docker_build_root = "${path.module}/lambda/pandas_layer"
# }

module "lambda_layer" {
    source = "./lambda"

    project_name = var.project_name
}


module "lambda" {
    source = "terraform-aws-modules/lambda/aws"

    create_function = true

    function_name = "pokemon-events-generator"
    description   = "Lambda function to generate pokemons catch around the world"
    handler       = "pokemon_events_generator.lambda_handler"
    runtime       = "python3.7"

    source_path = [
        "${path.module}/lambda/pokemon_events_generator/",
        {
            pip_requirements = "${path.module}/lambda/pokemon_events_generator/requirements.txt"
            prefix_in_zip    = "vendor"
        }
    ]

    vpc_subnet_ids = tolist([module.network.private_subnet_group_id1, module.network.private_subnet_group_id2])
    vpc_security_group_ids = [module.network.vpc_security_group_ids[0]]
    attach_network_policy = true

    layers = [
        module.lambda_layer.lambda_layer_arn
    ]

    environment_variables = {
      "kafka_broker" = module.kafka.bootstrap_brokers_tls,
      "kafka_topic" = "pokemon-catches-topic"
    }

    timeout = 120
}

module "kafka" {
    source = "./kafka"

    project_name = var.project_name
    kafka_sg = module.network.vpc_security_group_ids[0]
    subnet_az1 = module.network.private_subnet_group_id1
    subnet_az2 = module.network.private_subnet_group_id2
}

module "ec2" {
    source = "./ec2"
    project_name = var.project_name
    security_group_id = module.network.vpc_security_group_ids[0]
    subnet_id = module.network.public_subnet_group_id1
    kafka_topic = "pokemon-catches-topic"
    zookeeper_connect_string = module.kafka.zookeeper_connect_string
    region = var.aws_region
    kafka_bootstrap_servers = module.kafka.bootstrap_brokers_tls
    elastichost = module.elasticsearch.es_endpoint
}

module "elasticsearch" {
    source = "./elasticsearch"
    default_sg = module.network.vpc_security_group_ids[0]
    private_subnet_group_id1 = module.network.private_subnet_group_id1
    private_subnet_group_id2 = module.network.private_subnet_group_id2
    public_subnet_group_id1 = module.network.public_subnet_group_id1
    allow_ip_address = var.allow_ip_address
}

# cloudwatch trigger lambda
resource "aws_cloudwatch_event_rule" "every_ten_seconds" {
  name                = "every-ten-seconds"
  description         = "Fires every 10 seconds"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "check_every_ten_seconds" {
  rule      = "${aws_cloudwatch_event_rule.every_ten_seconds.name}"
  target_id = "lambda"
  arn       = "${module.lambda.lambda_function_arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda.lambda_function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.every_ten_seconds.arn}"
}