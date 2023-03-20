#!/bin/bash

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if JQ is installed
if ! command_exists jq; then
    echo "JQ is not installed. Please install it before running this script."
    echo "On Ubuntu/Debian-based systems, you can install it with the command:"
    echo "sudo apt-get install jq"
    exit 1
fi

# Check if pipeline definition file is provided
if [ -z "$1" ]; then
    echo "Please provide a path to the pipeline definition JSON file as the first argument."
    exit 1
fi

# Check if pipeline definition file exists
if [ ! -f "$1" ]; then
    echo "The pipeline definition file $1 does not exist."
    exit 1
fi

# Parse command line arguments
while [ $# -gt 0 ]
do
key="$1"

case $key in
    -c|--configuration)
    BUILD_CONFIGURATION="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--owner)
    OWNER="$2"
    shift # past argument
    shift # past value
    ;;
    -b|--branch)
    BRANCH="$2"
    shift # past argument
    shift # past value
    ;;
    -r|--repo)
    REPO="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--poll-for-source-changes)
    POLL_FOR_SOURCE_CHANGES="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    echo "Unknown option $1"
    exit 1
    ;;
esac
done

# Read the pipeline definition file into a variable
PIPELINE_JSON=$(cat "$1")

# Validate that the metadata property exists
if ! echo "$PIPELINE_JSON" | jq '.metadata' >/dev/null; then
    echo "The pipeline definition file does not contain the metadata property."
    exit 1
fi

# Remove the metadata property
PIPELINE_JSON=$(echo "$PIPELINE_JSON" | jq 'del(.metadata)')

# Increment the pipeline's version property by 1
PIPELINE_JSON=$(echo "$PIPELINE_JSON" | jq '.version += 1')

# Update the Source action's configuration properties
if [ -n "$OWNER" ]; then
    PIPELINE_JSON=$(echo "$PIPELINE_JSON" | jq --arg owner "$OWNER" '.stages[0].actions[0].configuration.Owner = $owner')
fi

if [ -n "$BRANCH" ]; then
    PIPELINE_JSON=$(echo "$PIPELINE_JSON" | jq --arg branch "$BRANCH" '.stages[0].actions[0].configuration.Branch = $branch')
fi

if [ -n "$REPO" ]; then
    PIPELINE_JSON=$(echo "$PIPELINE_JSON" | jq --arg repo "$REPO" '.stages[0].actions[0].configuration.Repo = $repo')
fi

if [ -n "$POLL_FOR_SOURCE_CHANGES" ]; then
    PIPELINE_JSON=$(echo "$PIPELINE_JSON" | jq --argjson poll_for_source_changes "$POLL_FOR_SOURCE_CHANGES" '.stages[0].actions[0].configuration.PollForSourceChanges = $poll_for_source_changes')
fi


for (( i=0; i<$num_actions; i++ ))
do
action_name=$(echo $actions | jq -r ".[$i].Name")
echo "Filling environment variables for $action_name action"


env_var_str=$(echo ${env_vars[$i]} | jq -c .)

updated_actions=$(echo $updated_actions | jq ".[$i].Configuration.EnvironmentVariables = $env_var_str")
done

new_pipeline=$(echo $pipeline | jq 'del(.metadata) | .version += 1 | .stages[0].actions = '"$updated_actions")

filename="pipeline-$(date +"%Y-%m-%d").json"

echo $new_pipeline > $filename

echo "New pipeline definition written to $filename"
