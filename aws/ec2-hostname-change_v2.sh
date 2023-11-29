# #!/bin/bash

# set_hostname() {
#     local private_ip=$(ip route get 1.2.3.4 2>/dev/null | grep -Eo 'src [0-9.]+' | grep -Eo '[0-9.]+')
#     local instance_id=$(aws ec2 describe-instances --filters "Name=private-ip-address,Values=$private_ip" --query "Reservations[].Instances[].InstanceId" --output text)
#     # local instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
#     local serial_id=$(echo "$instance_id" | cut -c 3-7)
#     local region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
#     local hostname=$(aws --region "$region" ec2 describe-instances \
#         --instance-ids "$instance_id" \
#         --query "Reservations[].Instances[].Tags[?Key=='Name'].Value[]" \
#         --output text)

#     sudo hostnamectl set-hostname "$hostname"
#     # sudo hostnamectl set-hostname "$hostname-$serial_id"

#     echo -e "\nHostname set to $hostname\n"
# }

# set_hostname


# private_ip=$(ip route get 1.2.3.4 2>/dev/null | grep -Eo 'src [0-9.]+' | grep -Eo '[0-9.]+')
# instance_id=$(aws ec2 describe-instances --filters "Name=private-ip-address,Values=$private_ip" --query "Reservations[].Instances[].InstanceId" --output text)
# serial_id=$(echo $instance_id | cut -c 3-7)
# region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

# hostname=$(aws --region ${region} ec2 describe-instances \
#     --instance-ids ${instance_id} \
#     --query "Reservations[].Instances[].Tags[?Key=='Name'].Value[]" \
#     --output text)

# sudo hostnamectl set-hostname ${hostname}

# echo -e "\nHostname set to ${hostname}\n"





# #instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# echo -e "private ip: ${private_ip}\n"
# echo -e "instance id: ${instance_id}\n"
# echo -e "serial id: ${serial_id}\n"
# echo -e "aws region: ${region}\n"
