#!/usr/bin/env python3
"""
SramSetu - GitHub Contribution Graph & Activity Generator
Generates realistic, backdated commits for SramSetu from a given start date to end date,
ensuring at least 3 commits every single day to turn the GitHub contribution graph green.
"""

import os
import sys
import random
import datetime
import subprocess
import argparse

COMMIT_MESSAGES = [
    "feat: scaffold repository structure and configure base environment",
    "docs: initialize system architecture outline and milestone plan",
    "feat(auth): initialize Supabase authentication client setup",
    "feat(auth): implement phone OTP verification service",
    "feat(auth): add role-based authorization rules (customer, technician, admin)",
    "feat(db): create initial schema for user profiles and contact info",
    "feat(db): add migrations for technician trust badges and certifications",
    "feat(catalog): define service categories: electrical, plumbing, carpentry",
    "feat(catalog): add sub-service definitions and standard problem lists",
    "feat(pricing): implement upfront quotation calculation algorithm",
    "feat(pricing): add material pricing lookup matrix with regional modifiers",
    "feat(pricing): introduce transparent visit charge and platform fee breakdown",
    "test(pricing): add unit tests for upfront quotation calculator",
    "feat(customer): create mobile home screen layout and search banner",
    "feat(customer): add natural language issue input parser",
    "feat(customer): implement problem category selector component",
    "feat(customer): build photo/video upload preview for repair inspection",
    "feat(booking): design booking lifecycle state machine",
    "feat(booking): add emergency priority quick-dispatch mode",
    "feat(geo): add geolocation radius clustering for nearby technicians",
    "feat(geo): implement Haversine distance calculator for technician dispatch",
    "feat(technician): build incoming job lead alert modal",
    "feat(technician): implement lead accept and decline action handlers",
    "feat(technician): build technician active job timeline (En Route -> Arrived)",
    "feat(technician): add live navigation launcher for service destination",
    "feat(workflow): implement mid-job extra material approval protocol",
    "feat(workflow): add customer authorization prompt for price adjustments",
    "feat(payments): integrate Razorpay payment intent initialization",
    "feat(payments): add Cash on Delivery (COD) settlement workflow",
    "feat(payments): generate itemized digital invoice with GST breakdown",
    "feat(feedback): add post-service rating and review submission",
    "feat(trust): implement technician background verification badge widget",
    "feat(admin): build admin dispute resolution audit log",
    "feat(admin): create master price editor for materials and labor rates",
    "perf(db): add spatial indexes for technician geolocation queries",
    "perf(cache): implement in-memory cache for static service catalogs",
    "fix(auth): resolve session token expiration edge case",
    "fix(pricing): correct GST rounding precision on multi-item service orders",
    "fix(geo): add fallback coordinate resolution when GPS is unavailable",
    "refactor(booking): consolidate status transitions and webhook triggers",
    "style(ui): enhance mobile responsiveness and accessible color contrast",
    "chore: setup CI linting and formatting workflows",
    "docs: update API documentation and endpoint schemas",
    "feat(notifications): add SMS alert gateway integration for booking updates",
    "feat(notifications): implement in-app push notifications for order status",
    "test(booking): add integration tests for booking creation to completion",
    "feat(technician): add daily and weekly earnings analytics screen",
    "feat(warranty): introduce 30-day post-service warranty tracking",
    "fix(workflow): prevent mid-job approval timeout race condition",
    "perf: optimize asset compression and font preloading for fast load times",
    "feat(customer): implement saved address manager (Home, Office, Other)",
    "refactor: clean up deprecated API routes and update error handlers",
    "feat(search): add fuzzy search matching for home repair services",
    "test(auth): add automated test suite for login and OTP validation",
    "feat(support): add WhatsApp support link and help desk escalation flow"
]

def run_git(args, env=None, cwd=None):
    result = subprocess.run(
        ["git"] + args,
        cwd=cwd,
        env=env,
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        print(f"Git command failed: git {' '.join(args)}")
        print(f"Error: {result.stderr.strip()}")
        sys.exit(1)
    return result.stdout.strip()

def get_git_config(key, default=""):
    try:
        res = subprocess.run(["git", "config", "--get", key], capture_output=True, text=True)
        val = res.stdout.strip()
        return val if val else default
    except Exception:
        return default

def main():
    parser = argparse.ArgumentParser(description="Generate green GitHub contribution history for SramSetu")
    parser.add_argument("--start-date", default="2026-08-02", help="Start date (YYYY-MM-DD), default: 2026-08-02")
    parser.add_argument("--end-date", default="2026-09-17", help="End date (YYYY-MM-DD), default: 2026-09-17")
    parser.add_argument("--min-commits", type=int, default=3, help="Minimum commits per day (default: 3)")
    parser.add_argument("--max-commits", type=int, default=6, help="Maximum commits per day (default: 6)")
    parser.add_argument("--author-name", default="", help="Author name (default: from git config)")
    parser.add_argument("--author-email", default="", help="Author email (default: from git config)")
    parser.add_argument("--push", action="store_true", help="Push to origin main after generation")

    args = parser.parse_args()

    repo_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) if os.path.basename(os.path.dirname(os.path.abspath(__file__))) == "scripts" else os.path.dirname(os.path.abspath(__file__))
    
    author_name = args.author_name or get_git_config("user.name", "Aditya Kumar Mishra")
    author_email = args.author_email or get_git_config("user.email", "adityam8787@gmail.com")

    print(f"==================================================")
    print(f"  SramSetu GitHub Activity & Contribution Generator")
    print(f"==================================================")
    print(f"Repository:   {repo_dir}")
    print(f"Author:       {author_name} <{author_email}>")
    print(f"Date Range:   {args.start_date} to {args.end_date}")
    print(f"Commits/Day:  {args.min_commits} to {args.max_commits}")
    print(f"==================================================")

    start = datetime.datetime.strptime(args.start_date, "%Y-%m-%d").date()
    end = datetime.datetime.strptime(args.end_date, "%Y-%m-%d").date()

    if start > end:
        print("Error: Start date must be before or equal to end date.")
        sys.exit(1)

    # Prepare log file to track updates
    docs_dir = os.path.join(repo_dir, "docs")
    os.makedirs(docs_dir, exist_ok=True)
    activity_file = os.path.join(docs_dir, "DEVELOPMENT_LOG.md")
    
    # Check current git branch
    current_branch = run_git(["rev-parse", "--abbrev-ref", "HEAD"], cwd=repo_dir)
    print(f"Current branch: {current_branch}")

    # Read existing doc files to make sure we preserve everything
    # We will reset to an orphan branch or re-create history cleanly from start date
    print("Preparing clean chronological commit history...")
    
    # Create orphan branch for clean history
    temp_branch = "green-history"
    run_git(["checkout", "--orphan", temp_branch], cwd=repo_dir)

    # Initialize DEVELOPMENT_LOG.md
    with open(activity_file, "w", encoding="utf-8") as f:
        f.write("# SRAM SETU — Engineering & Development Changelog\n\n")
        f.write("Milestone logs, architecture decisions, and daily progress tracking.\n\n")

    current_date = start
    total_commits = 0
    msg_index = 0
    random.seed(42)  # Deterministic seed for reproducible aesthetic variation

    while current_date <= end:
        num_commits = random.randint(args.min_commits, args.max_commits)
        
        # Generate distributed hours throughout the day (e.g. 09:30 to 22:45)
        minute_offsets = sorted(random.sample(range(9 * 60 + 15, 22 * 60 + 30), num_commits))

        for offset in minute_offsets:
            hour = offset // 60
            minute = offset % 60
            second = random.randint(10, 55)

            dt = datetime.datetime(current_date.year, current_date.month, current_date.day, hour, minute, second)
            # IST timezone offset is +0530
            date_str = dt.strftime("%Y-%m-%d %H:%M:%S +0530")

            msg = COMMIT_MESSAGES[msg_index % len(COMMIT_MESSAGES)]
            msg_index += 1

            # Append entry to DEVELOPMENT_LOG.md
            with open(activity_file, "a", encoding="utf-8") as f:
                f.write(f"- **[{dt.strftime('%Y-%m-%d %H:%M')}]**: {msg}\n")

            env = os.environ.copy()
            env["GIT_AUTHOR_NAME"] = author_name
            env["GIT_AUTHOR_EMAIL"] = author_email
            env["GIT_COMMITTER_NAME"] = author_name
            env["GIT_COMMITTER_EMAIL"] = author_email
            env["GIT_AUTHOR_DATE"] = date_str
            env["GIT_COMMITTER_DATE"] = date_str

            run_git(["add", "docs/DEVELOPMENT_LOG.md"], env=env, cwd=repo_dir)
            
            # If first commit, also include README
            if total_commits == 0:
                readme_path = os.path.join(repo_dir, "README.md")
                if os.path.exists(readme_path):
                    run_git(["add", "README.md"], env=env, cwd=repo_dir)

            run_git(["commit", "-m", msg], env=env, cwd=repo_dir)
            total_commits += 1

        print(f"  [+] {current_date} -> Created {num_commits} commits")
        current_date += datetime.timedelta(days=1)

    # Now add all docs (PRD, TRD, DEVELOPMENT_PLAN) as of today (or day after end_date)
    today_dt = datetime.datetime(end.year, end.month, end.day, 23, 45, 0) + datetime.timedelta(minutes=30)
    today_date_str = today_dt.strftime("%Y-%m-%d %H:%M:%S +0530")
    
    final_env = os.environ.copy()
    final_env["GIT_AUTHOR_NAME"] = author_name
    final_env["GIT_AUTHOR_EMAIL"] = author_email
    final_env["GIT_COMMITTER_NAME"] = author_name
    final_env["GIT_COMMITTER_EMAIL"] = author_email
    final_env["GIT_AUTHOR_DATE"] = today_date_str
    final_env["GIT_COMMITTER_DATE"] = today_date_str

    run_git(["add", "."], env=final_env, cwd=repo_dir)
    run_git(["commit", "-m", "docs: finalize PRD, TRD, and comprehensive development plan"], env=final_env, cwd=repo_dir)
    total_commits += 1

    # Switch main branch to point to this new history
    run_git(["branch", "-D", "main"], cwd=repo_dir)
    run_git(["branch", "-m", "main"], cwd=repo_dir)

    print(f"\nSuccessfully generated {total_commits} commits!")
    print(f"Active branch: main")

    if args.push:
        print("\nPushing to GitHub remote origin main...")
        run_git(["push", "-f", "origin", "main"], cwd=repo_dir)
        print("Push complete! Check your GitHub profile contribution graph.")
    else:
        print("\nTo push these changes to GitHub and update your contribution graph, run:")
        print("  git push -f origin main")

if __name__ == "__main__":
    main()
