#!/usr/bin/env python3
"""
Script to automate the process of creating a PR with random changes.
"""

import os
import random
import subprocess
import datetime
import time
import argparse
from github import Github
import json
import re

def run_command(command):
    """Run a shell command and return the output."""
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error executing command: {command}")
        print(f"Error: {result.stderr}")
        exit(1)
    return result.stdout.strip()

def generate_random_sentence():
    """Generate a random sentence for the dummy file content."""
    words = ["automated", "change", "update", "modification", "enhancement", 
             "improvement", "feature", "fix", "patch", "revision"]
    
    sentence = "This is an "
    
    # Add 5-10 random words
    word_count = random.randint(5, 10)
    for _ in range(word_count):
        random_index = random.randint(0, len(words) - 1)
        sentence += f"{words[random_index]} "
    
    sentence += f"at {datetime.datetime.now()}"
    return sentence

def get_repo_info():
    """Get the repository owner and name from the remote URL."""
    remote_url = run_command("git remote get-url origin")
    
    # Handle SSH URL format: git@github.com:username/repo.git
    if remote_url.startswith("git@"):
        parts = remote_url.split(':')[1].split('/')
        owner = parts[0]
        repo = parts[1].replace('.git', '')
    # Handle HTTPS URL format: https://github.com/username/repo.git
    elif remote_url.startswith("https://"):
        parts = remote_url.split('/')
        owner = parts[3]
        repo = parts[4].replace('.git', '')
    else:
        print(f"Unsupported remote URL format: {remote_url}")
        exit(1)
    
    return owner, repo

def generate_commit(file_path=None):
    """Generate a commit with random changes to a new time-based file."""
    # Create a new time-based file name if not provided
    if file_path is None:
        timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        file_path = f"dummy_file_{timestamp}.txt"
    
    # Create or update file with random content
    random_content = generate_random_sentence()
    print(f"Generating random content for {file_path}")
    
    with open(file_path, "w") as f:
        f.write(random_content)
    
    # Add and commit the changes
    print("Committing changes")
    run_command(f"git add {file_path}")
    commit_message = f"Add {file_path} with automated content"
    run_command(f'git commit -m "{commit_message}"')
    
    return file_path

def create_pull_request(branch_name, base_branch="main", file_path=None):
    """Create a pull request using GitHub CLI and return the PR number and URL."""
    file_name = file_path or "dummy_file.txt"
    pr_title = f"Add {file_name} with automated content"
    pr_body = (
        f"This pull request contains automated changes.\n\n"
        f"Changes made:\n"
        f"- Added new file: {file_name}\n\n"
        f"Automatically generated at {datetime.datetime.now()}"
    )
    
    # Check if GitHub CLI is installed
    result = subprocess.run("which gh", shell=True, capture_output=True, text=True)
    if result.returncode == 0:
        # Use GitHub CLI to create PR
        print("Creating pull request using GitHub CLI...")
        cmd = f'gh pr create --title "{pr_title}" --body "{pr_body}" --base {base_branch} --head {branch_name}'
        pr_output = run_command(cmd)
        
        # Extract PR URL and number
        pr_url_cmd = f'gh pr view {branch_name} --json url --jq .url'
        pr_url = run_command(pr_url_cmd)
        
        pr_number_cmd = f'gh pr view {branch_name} --json number --jq .number'
        pr_number = run_command(pr_number_cmd)
        print(f"Pull request #{pr_number} created successfully: {pr_url}")
        return pr_url, pr_number
    else:
        # Use PyGithub if GitHub CLI is not available
        print("GitHub CLI not found. Using PyGithub to create PR...")
        try:
            # Try to get token from GitHub CLI config
            token_cmd = "gh auth token"
            token = run_command(token_cmd)
        except:
            # If that fails, ask for token
            token = os.environ.get("GITHUB_TOKEN")
            if not token:
                token = input("Please enter your GitHub token: ")
        
        owner, repo_name = get_repo_info()
        g = Github(token)
        repo = g.get_repo(f"{owner}/{repo_name}")
        
        pr = repo.create_pull(
            title=pr_title,
            body=pr_body,
            head=branch_name,
            base=base_branch
        )
        print(f"Pull request #{pr.number} created successfully: {pr.html_url}")
        return pr.html_url, str(pr.number)

def merge_pull_request(pr_number, merge_method="squash"):
    """Merge a pull request using GitHub CLI."""
    print(f"Attempting to merge PR #{pr_number}...")
    
    # Check if GitHub CLI is installed
    result = subprocess.run("which gh", shell=True, capture_output=True, text=True)
    if result.returncode == 0:
        # Use GitHub CLI to merge PR
        try:
            # Try with --auto flag first
            try:
                cmd = f'gh pr merge {pr_number} --{merge_method} --delete-branch --auto'
                merge_output = run_command(cmd)
                print(f"Pull request #{pr_number} merged successfully!")
                print(merge_output)
                return True
            except:
                # If auto-merge fails, try without --auto flag
                try:
                    cmd = f'gh pr merge {pr_number} --{merge_method} --delete-branch'
                    merge_output = run_command(cmd)
                    print(f"Pull request #{pr_number} merged successfully!")
                    print(merge_output)
                    return True
                except Exception as e:
                    print(f"Error merging PR #{pr_number}: {str(e)}")
                    return False
        except Exception as e:
            print(f"Error merging PR #{pr_number}: {str(e)}")
            return False
    else:
        # Use PyGithub if GitHub CLI is not available
        print("GitHub CLI not found. Using PyGithub to merge PR...")
        try:
            # Try to get token from environment or prompt
            token = os.environ.get("GITHUB_TOKEN")
            if not token:
                token = input("Please enter your GitHub token: ")
            
            owner, repo_name = get_repo_info()
            g = Github(token)
            repo = g.get_repo(f"{owner}/{repo_name}")
            
            pr = repo.get_pull(int(pr_number))
            if merge_method == "squash":
                merge_result = pr.merge(merge_method="squash")
            elif merge_method == "rebase":
                merge_result = pr.merge(merge_method="rebase")
            else:
                merge_result = pr.merge()
                
            if pr.merged:
                print(f"Pull request #{pr_number} merged successfully!")
                
                # Delete the branch if possible
                try:
                    ref = repo.get_git_ref(f"heads/{pr.head.ref}")
                    ref.delete()
                    print(f"Branch {pr.head.ref} deleted.")
                except:
                    print(f"Could not delete branch {pr.head.ref}.")
                    
                return True
            else:
                print(f"Failed to merge PR #{pr_number}.")
                return False
        except Exception as e:
            print(f"Error merging PR #{pr_number}: {str(e)}")
            return False

def main():
    """Main function to create a branch, make changes, and create a PR."""
    parser = argparse.ArgumentParser(description="Create a PR with random changes to a dummy file.")
    parser.add_argument("--base", default="main", help="Base branch to create PR against (default: main)")
    parser.add_argument("--merge", action="store_true", help="Merge the PR after creation")
    parser.add_argument("--merge-method", choices=["merge", "squash", "rebase"], default="squash", 
                        help="Merge method to use (default: squash)")
    parser.add_argument("--pr-number", help="PR number to merge (if only merging an existing PR)")
    parser.add_argument("--file-path", default="dummy_file.txt", help="Path to the file to modify (default: dummy_file.txt)")
    args = parser.parse_args()
    
    # If only merging an existing PR
    if args.pr_number:
        merge_pull_request(args.pr_number, args.merge_method)
        return
        
    # Generate a branch name with current timestamp
    timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    branch_name = f"auto-update-{timestamp}"
    
    # Create and checkout a new branch
    print(f"Creating new branch: {branch_name}")
    run_command(f"git checkout -b {branch_name}")
    
    # Generate commit with changes to a new time-based file
    created_file = generate_commit()
    
    # Push the branch to remote
    print("Pushing branch to remote")
    run_command(f"git push -u origin {branch_name}")

    # Create a PR
    print("Creating pull request")
    pr_url, pr_number = create_pull_request(branch_name, args.base, created_file)
    
    # Return to the base branch
    run_command(f"git checkout {args.base}")
    
    # Merge the PR if requested
    if args.merge:
        print("Waiting 5 seconds before attempting to merge...")
        time.sleep(5)  # Wait a bit to ensure GitHub has processed the PR
        merge_pull_request(pr_number, args.merge_method)
    
    print("Process completed successfully!")
    print(f"Pull request URL: {pr_url}")

if __name__ == "__main__":
    main()
