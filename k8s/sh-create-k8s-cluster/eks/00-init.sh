#! /bin/bash 

#https://gist.github.com/vfarcic/3c9ddff3fd412e42175a2eceab049421

#see https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html

##This script use the AWS ROOT key to create a cje user/group/role and permission.
## It produces the required pem key as well as ASSES_KEY/SECRET_KEY 

#AWS ROOT KEY/SECRET 
export AWS_ACCESS_KEY_ID=XXX
export AWS_SECRET_ACCESS_KEY=XXXX




export AWS_DEFAULT_REGION=us-west-2
export ZONES=$(aws ec2 describe-availability-zones --region $AWS_DEFAULT_REGION | jq -r '.AvailabilityZones[].ZoneName' | tr '\n' ',' | tr -d ' ')
ZONES=${ZONES%?}
echo $ZONES




aws iam create-group --group-name cje2

aws iam attach-group-policy --group-name cje2 \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

aws iam attach-group-policy --group-name cje2 \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

aws iam attach-group-policy --group-name cje2 \
    --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess

aws iam attach-group-policy --group-name cje2 \
    --policy-arn arn:aws:iam::aws:policy/IAMFullAccess

aws iam create-user --user-name cje2

aws iam add-user-to-group --user-name cje2 --group-name cje2

aws iam create-access-key --user-name cje2 > cje2-creds


cat cje2-creds

export AWS_ACCESS_KEY_ID=$(cat cje2-creds |  jq -r '.AccessKey.AccessKeyId')

export AWS_SECRET_ACCESS_KEY=$(cat cje2-creds | jq -r '.AccessKey.SecretAccessKey')

aws ec2 create-key-pair --key-name cje2    | jq -r '.KeyMaterial' >cje2eks.pem

chmod 600 cje2eks.pem

ssh-keygen -y -f cje2eks.pem >cje2eks.pub




