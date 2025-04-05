# Python PR Automation Script

This repository contains a Python script that automates the process of creating pull requests with random changes to a dummy file.

## What the Script Does

The `create_pr.py` script automates the following workflow:

1. Creates a new branch with a timestamp-based name (e.g., `auto-update-20250405175251`)
2. Generates random content for `dummy_file.txt`
3. Commits the changes with a descriptive commit message
4. Pushes the branch to the remote repository
5. Creates a pull request from the new branch to the main branch
6. Returns to the main branch

## Requirements

- Python 3.6+
- Git
- Virtual environment (recommended)
- Required Python packages (installed via `requirements.txt`):
  - PyGithub

## Setup

1. Create and activate a virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install the required packages:
   ```bash
   pip install -r requirements.txt
   ```

## How to Use

1. Make sure the script is executable:
   ```bash
   chmod +x create_pr.py
   ```

2. Run the script:
   ```bash
   ./create_pr.py
   ```

3. Optional: Specify a different base branch:
   ```bash
   ./create_pr.py --base develop
   ```

## Features

- **Flexible Authentication**: The script can use either GitHub CLI (if installed) or PyGithub for authentication
- **Command-line Arguments**: Supports customizing the base branch
- **Error Handling**: Provides clear error messages if any step fails
- **Random Content Generation**: Creates unique content for each PR

## Customization

You can modify the script to:

- Change the naming convention for branches
- Modify the random content generation logic
- Customize commit messages and PR titles/descriptions
- Change which files are modified
- Add additional command-line arguments for more flexibility

## Example Output

```
Creating new branch: auto-update-20250405175251
Generating random content for dummy_file.txt
Committing changes
Pushing branch to remote
Creating pull request
Creating pull request using GitHub CLI...
Pull request created successfully: https://github.com/username/repo/pull/3
Process completed successfully!
Pull request URL: https://github.com/username/repo/pull/3
