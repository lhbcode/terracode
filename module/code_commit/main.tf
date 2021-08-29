resource "aws_codecommit_repository" "repo" {
  repository_name = var.repo_name
  description     = var.repo_description 
  default_branch  = var.default_branch 
}