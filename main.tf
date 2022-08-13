module "my-app-prod" {
  source      = "./my-app"
  environment = "production"
}

module "my-app-dev" {
  source      = "./my-app"
  environment = "development"
}
