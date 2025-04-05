# Python PR Automation Script

This repository contains a Python script that automates the process of creating pull requests with random changes to a dummy file.

## What the Script Does

The `create_pr.py` script automates the following workflow:

1. Creates a new branch with a timestamp-based name (e.g., `auto-update-20250405175251`)
2. Selects a random dummy user (famous Bollywood actor) for the commit
3. Generates a new time-based file (e.g., `dummy_file_20250405183006.txt`) with random content
4. Commits the changes as the selected dummy user
5. Pushes the branch to the remote repository
6. Creates a pull request from the new branch to the main branch, including the dummy user's name
7. Optionally merges the pull request automatically (as the admin user)
8. Returns to the main branch

This approach avoids merge conflicts by creating a unique file for each PR, rather than modifying the same file repeatedly. It also simulates activity from multiple users by using different dummy users for each commit.

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

3. Optional parameters:
   ```bash
   # Specify a different base branch
   ./create_pr.py --base develop
   
   # Create and automatically merge the PR
   ./create_pr.py --merge
   
   # Specify merge method (merge, squash, or rebase)
   ./create_pr.py --merge --merge-method rebase
   
   # Only merge an existing PR by number
   ./create_pr.py --pr-number 5 --merge-method squash
   ```

## Features

- **Dummy Users**: Uses a pool of 5 famous Bollywood actors as dummy users for commits
- **Unique File Creation**: Creates a new time-based file for each PR to avoid merge conflicts
- **Flexible Authentication**: The script can use either GitHub CLI (if installed) or PyGithub for authentication
- **Command-line Arguments**: Supports customizing the base branch, merge options, and more
- **PR Creation and Merging**: Can create PRs and optionally merge them in a single command
- **Merge Existing PRs**: Can merge existing PRs by providing the PR number
- **Multiple Merge Methods**: Supports different merge strategies (merge, squash, rebase)
- **Error Handling**: Provides clear error messages if any step fails
- **Random Content Generation**: Creates unique content for each PR
- **Git Config Management**: Temporarily changes Git user configuration for commits and restores it afterward

## Limitations

- **Auto-Merge**: Some repositories may not have auto-merge enabled, which can cause merge operations to fail if the PR is not immediately mergeable.

## Customization

You can modify the script to:

- Change the naming convention for branches
- Modify the random content generation logic
- Customize commit messages and PR titles/descriptions
- Change which files are modified
- Add additional command-line arguments for more flexibility

## Example Output

### Creating a PR

```
Creating new branch: auto-update-20250405175251
Using dummy user: Shah Rukh Khan <srk@bollywood.com>
Generating random content for dummy_file_20250405175251.txt
Committing changes
Restoring original Git config: prash-kr-meena <social.prash@gmail.com>
Pushing branch to remote
Creating pull request
Creating pull request using GitHub CLI...
Pull request #3 created successfully: https://github.com/username/repo/pull/3
Process completed successfully!
Pull request URL: https://github.com/username/repo/pull/3
```

### Creating and Merging a PR

```
Creating new branch: auto-update-20250405175251
Using dummy user: Deepika Padukone <deepika@bollywood.com>
Generating random content for dummy_file_20250405175251.txt
Committing changes
Restoring original Git config: prash-kr-meena <social.prash@gmail.com>
Pushing branch to remote
Creating pull request
Creating pull request using GitHub CLI...
Pull request #3 created successfully: https://github.com/username/repo/pull/3
Waiting 5 seconds before attempting to merge...
Attempting to merge PR #3...
Pull request #3 merged successfully!
✓ Merged pull request #3 ([Deepika Padukone] Add dummy_file_20250405175251.txt with automated content)
✓ Deleted branch auto-update-20250405175251
Process completed successfully!
Pull request URL: https://github.com/username/repo/pull/3
```

### Merging an Existing PR

```
Attempting to merge PR #5...
Pull request #5 merged successfully!
✓ Merged pull request #5 ([Amitabh Bachchan] Add dummy_file_20250405180112.txt with automated content)
✓ Deleted branch auto-update-20250405180112
