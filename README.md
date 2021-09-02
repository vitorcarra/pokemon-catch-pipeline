<<<<<<< HEAD
# Pokemon Catches Data Pipeline

* This is a sample project to practice end-to-end data project;
* Terraform is used to deploy infrastructure;
* Kafka is the tool used to receive pokemon catches events;
* Target Database is Elasticsearch;
* Data visualization tool is Kibana.

## Disclaimer
* This project is not considering the best security practices;
* You can use this project to practice and learning how to connect the tools but not for prodution;
* In order to run this idea in production, please consider adding more safety configurition on each service;
* When you run terraform, it will create entire infrastructure and events will start to be generated;
* You can go ahead and open up Elasticsearch, create an index pattern and add some Kibana visualization;
* Enjoy and have fun while learning!

## Requirements
* terraform
* aws cli version 2
* python3

## Manual Configuration
* Set up ~./credentials file
* export AWS_PROFILE=<your_profile>
* export AWS_REGION=<your_region>

## Setup
```
git clone git@github.com:vitorcarra/pokemon-catch-pipeline.git
```

### Terraform Deploy

* Rename terraform.tfvars.template to terraform.tfvars
* Modify terraform.tfvars with your values

```
terraform init
terraform validate
terraform plan -var-file terraform.tfvars
terraform apply -var-file terraform.tfvars
```

Terraform
=========

- Website: https://www.terraform.io
- Forums: [HashiCorp Discuss](https://discuss.hashicorp.com/c/terraform-core)
- Documentation: [https://www.terraform.io/docs/](https://www.terraform.io/docs/)
- Tutorials: [HashiCorp's Learn Platform](https://learn.hashicorp.com/terraform)
- Certification Exam: [HashiCorp Certified: Terraform Associate](https://www.hashicorp.com/certification/#hashicorp-certified-terraform-associate)

<img alt="Terraform" src="https://www.terraform.io/assets/images/logo-hashicorp-3f10732f.svg" width="600px">

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.


=======
# pokemon-catch-pipeline
>>>>>>> e037989... first commit
