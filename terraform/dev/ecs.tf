module "cluster" {
  source = "../templates/"

  
  ecs_cluster_name = "dev-cluster"
}