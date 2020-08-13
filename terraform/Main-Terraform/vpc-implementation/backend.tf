terraform{
    backend "s3"{
        bucket = "test-bucket-jenkins-ak"
        key = "terraform.tfstate"
        region= "ap-south-1"
    }
}