#!/bin/sh

set -e
set -x

export CHART_DIR=$1
export INPUT_USER_EMAIL=$2
export INPUT_USER_NAME=$3
export INPUT_PULL_REQUEST_REVIEWERS=$4

if [ -z "$CHART_DIR" ]
then
  echo "Helm chart path must be defined"
  return -1
fi

#if [ $INPUT_DESTINATION_HEAD_BRANCH == "main" ] || [ $INPUT_DESTINATION_HEAD_BRANCH == "master"]
#then
#  echo "Destination head branch cannot be 'main' nor 'master'"
#  return -1
#fi

if [ -z "$INPUT_PULL_REQUEST_REVIEWERS" ]
then
  PULL_REQUEST_REVIEWERS=$INPUT_PULL_REQUEST_REVIEWERS
else
  PULL_REQUEST_REVIEWERS='-r '$INPUT_PULL_REQUEST_REVIEWERS
fi

echo "Setting git variables"
echo $API_TOKEN_GITHUB | gh auth login --with-token
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"

echo "Fork Kubesphere git repository"
gh repo fork kubesphere/helm-charts --clone

export INPUT_DESTINATION_HEAD_BRANCH=helm-chart
echo "Copying contents to git repo"
cd helm-charts

echo "Setting git variables in helm-charts"
echo $API_TOKEN_GITHUB | gh auth login --with-token
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"
git checkout -b "$INPUT_DESTINATION_HEAD_BRANCH"
cp -r ./../$CHART_DIR "src/main"

export INPUT_DESTINATION_BASE_BRANCH=master
echo "Adding git commit"
git add .
if git status | grep -q "Changes to be committed"
then
  git commit --message "Helm chart PR from $GITHUB_REPOSITORY:$GITHUB_SHA"
  echo "Pushing git commit"
  git push --set-upstream origin helm-chart
  git push https://$GITHUB_REPOSITORY_OWNER:$API_TOKEN_GITHUB$@github.com/$GITHUB_REPOSITORY_OWNER/helm-charts.git helm-chart
  echo "Creating a pull request"
  gh pr create -t "$GITHUB_REPOSITORY Helm Chart" \
               -b "Automatic Helm Chart Release from $GITHUB_REPOSITORY:$GITHUB_SHA by github workflow" \
               --base $INPUT_DESTINATION_BASE_BRANCH \
               --head $INPUT_DESTINATION_HEAD_BRANCH \
               --repo kubesphere/helm-charts \
               --reviewer  $PULL_REQUEST_REVIEWERS 
else
  echo "No changes detected"
fi
