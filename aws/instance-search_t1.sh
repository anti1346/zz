#!/bin/bash

function list_ec2_regions {
    echo -e "\nAWS Regions:"
    aws lightsail get-regions --query "regions[].[name, displayName]" --output table
    echo ""
}

function list_ec2_instances {
    echo -e "\nEC2 Instances:"
    aws ec2 describe-instances --query "Reservations[].Instances[].{InstanceID:InstanceId, State:State.Name, Type:InstanceType, PrivateIP:PrivateIpAddress, PublicIP:PublicIpAddress}" --output table
    echo ""
}

function list_s3_buckets {
    echo -e "\nS3 Buckets:"
    aws s3api list-buckets --query "Buckets[].Name" --output table
    echo ""
}

function list_alb_listeners {
    echo -e "\nALB Listeners:"
    aws elbv2 describe-load-balancers --query "LoadBalancers[].{LoadBalancerName:LoadBalancerName, Listeners:Listeners}" --output table
    echo ""
}

function list_rds_instances {
    echo -e "\nRDS Instances:"
    aws rds describe-db-instances --query "DBInstances[].{DBInstanceIdentifier:DBInstanceIdentifier, Engine:Engine, Status:DBInstanceStatus}" --output table
    echo ""
}



#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
echo -e "\nAvailable regions: Seoul, Singapore, Virginia, Regions\n"
read -p "Enter the region: " region

case $region in
    "Seoul")
        region="ap-northeast-2"
        ;;
    "Singapore")
        region="ap-southeast-1"
        ;;
    "Virginia")
        region="us-east-1"
        ;;
    "Regions")
        list_ec2_regions
        exit 1
        ;;
    *)
        echo "Invalid region. Exiting."
        exit 1
        ;;
esac

while true; do
    echo ""
    read -p "Do you want to list? (ec2, s3, elb, rds): " list_services

    aws configure set region $region

    case $list_services in
        "ec2")
            list_ec2_instances
            ;;
        "s3")
            list_s3_buckets
            ;;
        "elb")
            list_alb_listeners
            ;;
        "rds")
            list_rds_instances
            ;;
        *)
            echo "Invalid option. Please choose from ec2, s3, elb, or rds."
            ;;
    esac

    read -p "Do you want to continue? (y/n): " continue
    if [[ $continue != "y" ]]; then
        break
    fi
done
