#!/bin/bash
# Script to run git_workflow_automation.py 30 times with a 300ms delay between runs

echo "Starting automated PR creation process..."
echo "Will run git_workflow_automation.py 30 times with a 300ms delay between runs"

# Check if the Python script exists
if [ ! -f "git_workflow_automation.py" ]; then
    echo "Error: git_workflow_automation.py not found!"
    exit 1
fi

# Check if the script is executable
if [ ! -x "git_workflow_automation.py" ]; then
    echo "Making git_workflow_automation.py executable..."
    chmod +x git_workflow_automation.py
fi

# Loop 30 times
for i in {1..30}; do
    echo "Run $i of 30: Starting..."
    
    # Run the Python script
    # You can add any command line arguments here if needed
    # For example: ./git_workflow_automation.py --merge
    ./git_workflow_automation.py
    ./git_workflow_automation.py --merge
    
    # Check if this is the last iteration
    if [ $i -lt 30 ]; then
        echo "Run $i of 30: Completed. Waiting 300ms before next run..."
        # Sleep for 300ms (0.3 seconds)
        sleep 0.2
    else
        echo "Run $i of 30: Completed."
    fi
done

echo "All 30 runs completed successfully!"
