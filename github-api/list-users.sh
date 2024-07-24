#!/bin/bash

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token
USERNAME=$username
TOKEN=$token

# User and Repository information
REPO_OWNER=$1
REPO_NAME=$2

# Print the repository information for debugging
echo "Repository Owner: $REPO_OWNER"
echo "Repository Name: $REPO_NAME"

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Fetch the list of collaborators on the repository
    response=$(github_api_get "$endpoint")

    # Print the raw response for debugging
    echo "Raw API response: $response" >&2

    # Check for API errors
    if echo "$response" | jq -e 'has("message")' > /dev/null; then
        error_message=$(echo "$response" | jq -r '.message')
        echo "Error from GitHub API: $error_message" >&2
        return
    fi

    # Filter and display the list of collaborators with read access
    collaborators=$(echo "$response" | jq -r '.[] | select(.permissions.pull == true) | .login')
    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# Main script
echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
