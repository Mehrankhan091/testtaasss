variable "webBucket" {
  
    type = map(string)
    default = {
      "devl" = "devel"
      "prod" = "prod"
      "stag" = "stag"
    }
}

variable "logBucket" {
  
    type = map(string)
    default = {
      "devl" = "devel"
      "prod" = "prod"
      "stag" = "stag"
    }
}