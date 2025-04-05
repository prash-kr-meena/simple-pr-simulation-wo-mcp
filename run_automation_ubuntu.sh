#!/bin/sh
# Script to run git_workflow_automation.py 30 times with a 300ms delay between runs
# Ubuntu-compatible version

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

# Loop 30 times using a counter (more POSIX-compliant than {1..30})
i=1
while [ $i -le 30 ]; do
    echo "Run $i of 30: Starting..."
    
    # Run the Python script
    # You can add any command line arguments here if needed
    python3 git_workflow_automation.py
    
    # Check if this is the last iteration
    if [ $i -lt 30 ]; then
        echo "Run $i of 30: Completed. Waiting 300ms before next run..."
        # Sleep for 300ms (0.3 seconds) - using a more compatible approach
        # Some older versions of sleep don't support fractional seconds
        # This is a workaround that works on most systems
        sleep 0.3 2>/dev/null || (sleep 1 && echo "Note: Your system doesn't support fractional sleep, using 1 second instead")
    else
        echo "Run $i of 30: Completed."
    fi
    
    # Increment counter
    i=$((i + 1))
done

echo "All 30 runs completed successfully!"
