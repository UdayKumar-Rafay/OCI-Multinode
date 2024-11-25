tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaaa3ghjcqbrbzmssbzhxzhxf24rpmuyxbaxwcj2axwoqkpd56ljkq"
region           = "us-phoenix-1"
#region           = "us-sanjose-1"
compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaaaa3ghjcqbrbzmssbzhxzhxf24rpmuyxbaxwcj2axwoqkpd56ljkq"
#source_ocid = "ocid1.image.oc1.us-sanjose-1.aaaaaaaa4yordxo2tmdu4m44m4dcerf2dus6njepplqp7qwbsz3v4jbmcnwa"  # ubuntu sanjose
source_ocid  = "ocid1.image.oc1.phx.aaaaaaaabs7vrxje4vil2yaijt3rwuk6ylnxnlza5p3ovj7t7kwrqih3bfta"    # ubuntu phx region
#source_ocid  = "ocid1.image.oc1..aaaaaaaa7fil4t3bbhs2k3gkhiaaaaafe2y4i4h4r4v5jo7uznsrwszk3vaq"     #rocky9
#source_ocid  = "ocid1.image.oc1..aaaaaaaadtufrazz35ibwem457v76aoodxa347zoj2lmrpbxnmgpovvcgn5a"     #almalinux

instance_state = "RUNNING"
boot_volume_backup_policy = "disabled" # gold, silver, bronze, disabled
network_security_group_id="ocid1.networksecuritygroup.oc1.phx.aaaaaaaaezjtuknlibftz5mafcyzuokx745z4kvyerethezfq2lokvgltyda"
subnet_id="ocid1.subnet.oc1.phx.aaaaaaaay3bdnbnek22wxpjwn5fwli6kpfmi3n2dtj5soexyflcaievm4ogq" #phx subnet
#subnet_id="ocid1.subnet.oc1.us-sanjose-1.aaaaaaaawqbfwyruyhedpkdzzuyz6a2cznsggyh7yldfuzfrc2tz3xnnoezq"   #old sanjose
#subnet_id = "ocid1.subnet.oc1.us-sanjose-1.aaaaaaaak6t3fflipsvkj3ztakhwqrh6udqot6rxptmczmyg2vy3rg3erpvq"  
public_ip="NONE"
availability_domain="PaOl:PHX-AD-3"
#availability_domain= "PaOl:US-SANJOSE-1-AD-1"
shape="VM.Standard.E4.Flex"

###############Please change the configurations below as per the usage############################
worker_instance_count=1
conjurer_url="https://s3-us-west-1.amazonaws.com/dev-rafay-conjurer/vasu-tb/publish/conjurer-linux-amd64.tar.bz2"
worker_instance_display_name = "manish-scale"
user_ocid        = "ocid1.user.oc1..aaaaaaaai2r6n7wriasubzlrfedekgfm5dk4bmaj4qs6pnynm4khnefxxunq"
private_key_path = "/Users/manish/.oci/oci_api_key.pem"
fingerprint      = "cc:7a:1a:ca:31:7c:a9:88:e0:9e:d3:70:af:62:6d:ec"

ssh_public_keys = <<EOT
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPsQbQ0CsFWteJliE41FNiChdWAtQOUwDJRnXWjX2L61JxQCfS8+V7R/1pbFwU5d7IZf6YxnWYwjf8BfODgyScN2HezzbLELOBFeMI6YHylLrdf5uIK7Ci+00GMXKOuxii7D7kh4kwUz4U4rvrpAEmywUWNomobWzdvM/uCW285C9pqA/Kfl17OOE38L1t39vdf6So7c8KI12V7X6QvLTIhHqJt2FPMSptRD4jnrTQEi+2DYKb8+WB6wOqNVYVVpglOkV0O9tDFYGSuUfV++aaNArnKjNXSB/dSilIE4+6GURd+/APwmsM9IfV7XxLLAYn1swp3719HtEFd0zsL6/gHwPBcXru2q6J8Zll5BeGYBXUS+j66WS7T8yYdCIDcAHLa4yyNtGlHWBY8E1WPelp6FBWYdnBN3vjXbueOMeo4UJPnAI3s2Hb9qsedLXaYix7lY17wqFUQOJ5pvKszaHMPDuTDDYDVECV9JCNTKauSIVlw5KjLe8XJ7cSxsrqH/uXkKz9/oQcZDUMCXi4eFu9UhzLVbgcByMTfkUKaW4eE+BJ17rU4f9RiKAaTDjPuyxtAl0crGnYUmh30ZvH4GHuRddgK7EFzdyGa1pqEJ5XVXqWlyHVGFidvholqRUAn3YmUwWnglEerBgw9vVlsHmzUZifhpWNVaeGtZonNf72zQ== manish@Rafaysystemss-MacBook-Pro.local
EOT

ssh_private_key_file="/Users/manish/.ssh/id_rsa"
ssh_username="ubuntu"
private_key_password="rafay"

# volume_count=3
# new_worker_instance_count=3