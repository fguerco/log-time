# Welcome to Log Work!

Hi! With this project you can log your work automatically on JIRA based on your commits in your projects folder

## Dependencies

  - Ruby 2.6.3
  - Slop gem (https://github.com/leejarvis/slop)

## Setting up

First create a file named **config.json**

    {
      "username": "usually your email",
      "api_token": "your api token",
      "projects_dir": "/your/projects/dir"
    }

##  Running

    ./run.rb -y year -m month

for a complete list of parameters run ./run.rb -h

## Thank you!
