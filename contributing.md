---
layout: page
title: How to contribute?
permalink: /contributing/
---

# Contributing Guidelines for WOLF-I project

[Set up your Git environment and clone the project](#set-up-your-git-environment-and-clone-the-project)

[Create a post](#create-a-post)

## Set up your Git environment and clone the project: <a id="set-up-your-git-environment-and-clone-the-project"></a>

Please follow the prerequisites to begin the project. 

- Install GIT on your system (e.g. Windows, macOS, Linux)
    - Windows: Download the Git for Windows installer from the [official Git Website](https://git-scm.com/download/win) 
    - macOS: Install Git using [Homebrew](https://brew.sh/)
    - Linux: The exact installation process may vary depending on your specific Linux distribution.
        - Debian/Ubuntu: `sudo apt update && sudo apt install git`
    - Verify installation: Open a terminal window and type `git --version`.

- In your terminal, navigate to the "WOLF-I" folder: `cd ~/Documents/wolf-i`

- Clone the project : `git clone https://github.com/CRESYM/WOLF-I.git`

- Verify you are on the main branch: `git status` should return `on branch main`


## Create a post <a id="create-a-post"></a>

- Please use the following [model template](/pages/templates/modelTemplate) and [test case template](/pages/templates/testCaseTemplate) for your reference.

- You can see the how your changes impact the website by running locally a static site generator such as Jekyll (for more information, see [testing-your-github-pages-site-locally-with-jekyll](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/testing-your-github-pages-site-locally-with-jekyll) )

- Verify your changes: 
    - `git status`: Check the status of your local repository to see what files have been modified, staged, or are untracked.
    - Code review : Review your changes to ensure quality and adherence to standards.
    - Testing     : Run any relevant tests to ensure your changes haven't introduced any regressions or errors.
- Preparing for push:
    - Before pushing any updates, authentify yourself using `git config --global user.email *you@example.com*` and `git config --global user.name *Your name*`
