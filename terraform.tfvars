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
# worker_instance_count=1
conjurer_url="https://s3-us-west-1.amazonaws.com/dev-rafay-conjurer/vasu-tb/publish/conjurer-linux-amd64.tar.bz2"
worker_instance_display_name = "uday-test"
user_ocid        = "ocid1.user.oc1..aaaaaaaaa4ti2tydptuldp45hwy5e7bgspmmyfu4zl57xop2gj6lq44pttga"
private_key_path = "/Users/uday/.oci/oci_private_key.pem"
fingerprint      = "40:6b:d0:ce:28:7a:5c:bf:36:f9:93:cb:8b:66:4e:87"

ssh_public_keys = <<EOT
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDiurh+OZi4YYLxDOuoiDPl/hCxVRfnNjPy58WZw22WIdbKcBcIEL+hY3VSTFNZJ82RD9lEoS5U1+Yg3k92OOhvgAmTeH3/U5y0ZzHjuqwt9LsgjnqYQ/Yc5Hp/hiAmsmNNnlp7EqtV5r6fGE9GZjiSswdixxXiDA1yi1lozSGfC/njlVq8ZC6fUnkdAyuEh2GhE9/ck+FFsTBrayOcZClQonw2oDBVk3RVbNiHQodEYeaL+74avB3CVoi/mKCB79f9GOCo744qYEFQ7cCPH4LosVP5eUEd2MJs81jGlzq745yZ0tPyTDAlgXC+YKmiKv6ucCYzThsHlmruLMty+gfR9TyfCiq7cKJCkvY2YX1SIkLemy7Qa/ybgH9addTDMbuP2HhUhMPQ+Cm57ahx/uFecY0FHVPJJBEW8w8y1vonxxR8tumxDVpZYqaYZ/gsTeh7o/Cawzdqvm0HYIkI0je18EM7BmGBHFSw/N1LjuC63tdjqNrDTmPvfmZrk0sXD+pAfzkisdF9wBk6MaFZ054rTATPZmvEmnW8/KpCRwH6pxnWtY/vkQ9YykO1eor7KPkbORk5+JhTzDH1mSx4vSdNt1FMo6Ed40SGB5QguIudLHdDbdgjgeYiEwc97c+QIrIR6l1cp8y9+kOjXHGwBkSP4gfyq5LateNDeTlRfCfPKQ== uday.kumar@rafay.co
EOT

ssh_private_key_file="/Users/uday/.ssh/id_rsa"
ssh_username="ubuntu"
private_key_password="rafay"

# volume_count=3
# new_worker_instance_count=3