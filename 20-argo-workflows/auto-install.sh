#!/bin/sh

set -e

# Set your environment variables here
ARGO_WORKFLOWS_NAMESPACE="argo-workflows"
ARGO_WORKFLOWS_NAME="cluster"

#############################
## Do not modify anything from this line
#############################

# Print environment variables
echo -e "\n=============="
echo -e "ENVIRONMENT VARIABLES:"
echo -e " * ARGO_WORKFLOWS_NAMESPACE: $ARGO_WORKFLOWS_NAMESPACE"
echo -e " * ARGO_WORKFLOWS_NAME: $ARGO_WORKFLOWS_NAME"
echo -e "==============\n"

# Check if the user is logged in 
if ! oc whoami &> /dev/null; then
    echo -e "Check. You are not logged. Please log in and run the script again."
    exit 1
else
    echo -e "Check. You are correctly logged in. Continue..."
    if ! oc project &> /dev/null; then
        echo -e "Current project does not exist, moving to project Default."
        oc project default 
    fi
fi

# Deploy the Argo Workflows instance
echo -e "\n[1/2]Deploy the Argo Workflows instance"
oc process -f 20-argo-workflows/01-cluster.yaml \
    -p ARGO_WORKFLOWS_NAMESPACE=$ARGO_WORKFLOWS_NAMESPACE \
    -p ARGO_WORKFLOWS_NAME="$ARGO_WORKFLOWS_NAME" | oc apply -f -

# Wait for DeploymentConfig
echo -n "Waiting for pods ready..."
while [[ $(oc get pods -l app.kubernetes.io/name=${ARGO_WORKFLOWS_NAMESPACE}-server -n $ARGO_WORKFLOWS_NAMESPACE -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *"False"* ]]; do echo -n "." && sleep 1; done; echo -n -e "  [OK]\n"

ARGO_WORKFLOWS_ROUTE=$(oc get routes $ARGO_WORKFLOWS_NAME -n $ARGO_WORKFLOWS_NAMESPACE --template="https://{{.spec.host}}")

# Create the Argo Workflows ConsoleLink
echo -e "\n[2/2]Create the Argo Workflows ConsoleLink"
oc process -f 20-argo-workflows/02-consolelink.yaml \
    -p ARGO_WORKFLOWS_ROUTE=$ARGO_WORKFLOWS_ROUTE \
    -p ARGO_WORKFLOWS_NAMESPACE=$ARGO_WORKFLOWS_NAMESPACE \
    -p ARGO_WORKFLOWS_NAME="$ARGO_WORKFLOWS_NAME" | oc apply -f -

echo ""
echo -e "Argo Workflows information:"
echo -e "\t* URL: $ARGO_WORKFLOWS_ROUTE"
