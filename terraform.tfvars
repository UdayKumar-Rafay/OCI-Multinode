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
worker_instance_count=30
conjurer_url="https://s3-us-west-1.amazonaws.com/dev-rafay-conjurer/vasu-tb/publish/conjurer-linux-amd64.tar.bz2"
worker_instance_display_name = "venkat-mks-scale-w"
user_ocid        = "ocid1.user.oc1..aaaaaaaafhzursuerjrbf47c2velnmccb5dphambyhdnlvq2573d3qmoey2q"
private_key_path = "/Users/puvvada/.oci/oci_api_key.pem"
fingerprint      = "e4:c5:de:ca:ca:de:1d:c4:8c:31:ca:50:7f:03:1e:65"

ssh_public_keys = <<EOT
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwbuyRxLz9hwPY8cKZSMtn+QszQ9jcQTIS5LsPf49KLbunU8BUdaJpiQScg9+POxVrIb/9yxx62z86HpwoTLXvqyrIl7B+0cYQ91ErgG4NKLT/jj0JNEvwaVdVZYObpwhhnRSv6nq3EPQW8uNkltE0/oqr3+dxQXm1w+rLHzyLzJZRgxKL0XL/3bcqeo+zaTUjvgq2mR9k1PWGxu9xp71x8oGJTOpVKVSyWSl3r1nLHk3vSY86jQZbakXTSWEfQto5cvAKxGLVHHnk58hpySRmjZlWky4Lg0ieQrjdlQUIAcQTpyQT7eSB0sQOiQJ5aGBh4s3OS002Hsj8MsDt/oihNRhgQglC2pWeKsxVqe8Lp/TT3emWoVs2qs8ICbbxxxCp3hg3QS33n5/soOrb5g+hhQBhzeDuz4fi+ilhKuewwCNnJg7RIPYjHZfQ4ML2KzBqpPLUuwbcL3F+sgp+jY/MM5g9zw3PY7k6Sfsg0hypET/tU5iDyYNrZUT3kCpJSx8= puvvada@Venkats-MacBook-Pro.local
EOT

ssh_private_key_file="/Users/puvvada/.ssh/id_rsa"
ssh_username="ubuntu"
