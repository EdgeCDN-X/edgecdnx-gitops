#!/bin/bash

# Color definitions
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
NC='\033[0m' # No Color

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_location() {
    local ip=$1
    if [[ "$ip" == "74.220.27.251" ]]; then
        echo -e "\033[32m${ip} - NYC\033[0m"
    elif [[ "$ip" == "74.220.26.197" ]]; then
        echo -e "\033[32m${ip} - FRA1\033[0m"
    else
        echo -e "\033[32m${ip} - Unknown\033[0m"
    fi
}

print_color "$GREEN" "╔════════════════════════════════════════════════════════════╗"
print_color "$GREEN" "║           ROUTING TEST - Geolocation Resolution            ║"
print_color "$GREEN" "╚════════════════════════════════════════════════════════════╝"
echo
print_color "$YELLOW" "This test will verify if the domain is correctly routed to:"
print_color "$GREEN" "  ✓ NYC    - 74.220.27.251"
print_color "$GREEN" "  ✓ FRA1   - 74.220.26.197"
echo

sleep 5

print_color "$YELLOW" "Running test for $1. This test will check if the domain is correctly resolved to the expected IP address."
cmd="dig $1 +short @74.220.25.73"
echo "Running command: $cmd"
result=$(eval $cmd)
print_location "$result"

read -p "Press enter to continue with the next test..."
echo -e "\n\n\n"

print_color "$YELLOW" "Resolving the same domain and we pretend we're coming from the IP address 85.50.20.0/22"
cmd="dig $1 +subnet=85.50.20.0/22 +short @74.220.25.73"
echo "Running command: $cmd"
result=$(eval $cmd)
print_location "$result"

read -p "Press enter to continue with the next test..."
echo -e "\n\n\n"


print_color "$YELLOW" "In the next test we're killing the caches in Fra1. We expect we will be redirected to NYC and not to Fra1."
export KUBECONFIG="/Users/tbo/Projects/tbotech/cdn/terraform/edgecdnx-demo/configs/kubeconfig-fra1-c1.yaml"
kubens edgecdnx-cache
kubectl delete pods -l app.kubernetes.io/name=ingress-nginx --force --grace-period=0

echo "Pods killed, lets sleep for 15 seconds to make sure healthchecks fail and we get redirected to NYC."
read -p "Press enter to continue..."
echo -e "\n\n\n"

echo "Resolving the same domain again, we expect to be redirected to NYC and not to Fra1."
cmd="dig $1 +short @74.220.25.73"
echo "Running command: $cmd"
result=$(eval $cmd)
print_location "$result"

print_color "$YELLOW" "Lets wait until pods come back in FRA1 and then we will check if we are redirected to FRA1 again."
read -p "Press enter to continue..."
echo -e "\n\n\n"

print_color "$YELLOW" "Resolving the same domain again, we expect to be redirected to FRA1 and not to NYC."
cmd="dig $1 +short @74.220.25.73"
echo "Running command: $cmd"
result=$(eval $cmd)
print_location "$result"