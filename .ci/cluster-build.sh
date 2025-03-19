#!/bin/bash

set -x

TOKEN="eyJhbGciOiJIUzUxMiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0NzQzYTkzMC03YmJiLTRkZGQtOTgzMS00ODcxNGRlZDc0YjUifQ.eyJpYXQiOjE3NDA3ODQ1NzYsImp0aSI6ImNjZGM1ZGI0LTM0ODEtNGM0OC04MGRjLTUzYWI2ZmZhZGM1YiIsImlzcyI6Imh0dHBzOi8vc3NvLnJlZGhhdC5jb20vYXV0aC9yZWFsbXMvcmVkaGF0LWV4dGVybmFsIiwiYXVkIjoiaHR0cHM6Ly9zc28ucmVkaGF0LmNvbS9hdXRoL3JlYWxtcy9yZWRoYXQtZXh0ZXJuYWwiLCJzdWIiOiJmOjUyOGQ3NmZmLWY3MDgtNDNlZC04Y2Q1LWZlMTZmNGZlMGNlNjpyaC1lZS1sYmFycnkiLCJ0eXAiOiJPZmZsaW5lIiwiYXpwIjoiY2xvdWQtc2VydmljZXMiLCJub25jZSI6Ijk5YzkzNjM4LTJmNzctNDNiMy1iNmE1LWZhZTNiMjBlYzM2OSIsInNpZCI6IjU0YzI3MzdlLTI4ZWUtNDZlNy1iZWMxLWVhODYxYTUwYzk5YSIsInNjb3BlIjoib3BlbmlkIGJhc2ljIGFwaS5pYW0uc2VydmljZV9hY2NvdW50cyByb2xlcyB3ZWItb3JpZ2lucyBjbGllbnRfdHlwZS5wcmVfa2MyNSBvZmZsaW5lX2FjY2VzcyJ9.hSRPEv9hrHxa0QXyMHFTM00-s07NIsbkM8WJsc70OiPHvHKfvlp7DClV87PslKhce7SRQzfoa8icTi_5lUxe5w"
CLUSTER_NAME="osd-classic-101"
WIF_CONFIG_NAME="$CLUSTER_NAME"
VPC_NAME="$CLUSTER_NAME-vpc"
GCP_PROJECT="example-gcp-project"
MASTER_SUBNET_NAME="$CLUSTER_NAME-master-subnet"
WORKER_SUBNET_NAME="$CLUSTER_NAME-worker-subnet"

ocm logout

sleep 15

ocm login --token="$TOKEN"

sleep 15

ocm whoami

sleep 15

ocm gcp delete wif-config "$WIF_CONFIG_NAME" || true

sleep 30

ocm gcp create wif-config \
  --name="$WIF_CONFIG_NAME" \
  --project="$GCP_PROJECT" \
  --mode="auto"

sleep 300

ocm create cluster $CLUSTER_NAME \
  --provider=gcp \
  --debug \
  --vpc-name=$VPC_NAME \
  --region=us-central1 \
  --control-plane-subnet=$MASTER_SUBNET_NAME \
  --compute-subnet=$WORKER_SUBNET_NAME \
  --wif-config=$WIF_CONFIG_NAME \
  --subscription-type=marketplace-gcp \
  --marketplace-gcp-terms=true \
  --compute-machine-type=n2-standard-8 \
  --enable-autoscaling=true \
  --max-replicas=12 \
  --min-replicas=3 \
  --multi-az \
  --ccs \
  --flavour=osd-4 \
  --version=4.18.3 \
  --machine-cidr=10.0.0.0/8 \
  --pod-cidr=172.128.0.0/14 \
  --service-cidr=172.127.0.0/16 \
  --private=false


# --compute-nodes=3 \
# --vpc-project-id=example-gcp-project \
# --host-prefix=24 \