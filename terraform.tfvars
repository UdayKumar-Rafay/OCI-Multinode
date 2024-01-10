tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaaa3ghjcqbrbzmssbzhxzhxf24rpmuyxbaxwcj2axwoqkpd56ljkq"
region           = "us-phoenix-1"
compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaaaa3ghjcqbrbzmssbzhxzhxf24rpmuyxbaxwcj2axwoqkpd56ljkq"
source_ocid  = "ocid1.image.oc1.phx.aaaaaaaabs7vrxje4vil2yaijt3rwuk6ylnxnlza5p3ovj7t7kwrqih3bfta"
instance_state = "RUNNING"
boot_volume_backup_policy = "disabled" # gold, silver, bronze, disabled
network_security_group_id="ocid1.networksecuritygroup.oc1.phx.aaaaaaaaezjtuknlibftz5mafcyzuokx745z4kvyerethezfq2lokvgltyda"
subnet_id="ocid1.subnet.oc1.phx.aaaaaaaay3bdnbnek22wxpjwn5fwli6kpfmi3n2dtj5soexyflcaievm4ogq"
public_ip="NONE"
availability_domain="PaOl:PHX-AD-3"
shape="VM.Standard.E4.Flex"

###############Please change the configurations below as per the usage############################
worker_instance_count=4
conjurer_url="https://s3-us-west-1.amazonaws.com/dev-rafay-conjurer/vasu-tb/publish/conjurer-linux-amd64.tar.bz2"
cp_instance_display_name = "vyshak-mks-scale-c"
worker_instance_display_name = "vyshak-mks-scale-w"
user_ocid        = "ocid1.user.oc1..aaaaaaaahbct3ljbty35ws2qeqnn6ypwam6a5diajvcko3lmgbdmsq6rcofa"
private_key_path = "/Users/vyshak/Downloads/vyshak-01-03-15-26.pem"
fingerprint      = "5e:8d:98:b0:96:98:84:7b:84:c0:e5:a7:3d:92:8f:f5"

cp_node_ocpus=2
cp_node_memory_in_gbs=8
worker_node_ocpus=2
worker_node_memory_in_gbs=8

ssh_public_keys = <<EOT
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIBtTBvkc55o/iYaBWCsO7ac/68Mpnnk2Qcruku7aWphZc4VsqghxrugCzEnTjAgJr+U34vYx/OohGpEOiO2BXiMCYS1tdAgwRr3pLKhEGhAOtCW6OcEG6HcEaIOGCKn/yXAI6lmAU2LTd8SFY03Pfz81YO1NMlnojfbYrP6QKWxEMQNYckTDqZj0hlRo6zwSKQMYIoDCVFdKz2trefOrKGfzNJDipiEH53EDOIBoBu0EYnAq0p1Dui7sq6KjvNEkXWrEXMVzQQ3naCGQq7xtQfDGrTmGTRrdEmj0GRHOnfpR7HpzUHN1JTL9H5OJnMRfgofT/svIFub0v7wJ3BfdF ssh-key-2024-01-03
EOT

ssh_private_key_file="/Users/vyshak/Downloads/ssh-key-2024-01-03.key"
ssh_username="ubuntu"
