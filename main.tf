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

    vpc_subnet_ids         = [module.network.private_subnet_group_id1, module.network.private_subnet_group_id2]
    attach_network_policy = true

    layers = [
        module.lambda_layer.lambda_layer_arn
    ]

    timeout = 120
}