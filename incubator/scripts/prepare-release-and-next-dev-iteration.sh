#!/usr/bin/env bash
# Current script allows to automate cretiong of new release branch and prepare next development iteration
#  1. Creates locally release branch with update `pom.xml`'s. Assume our current maven version is `7.52.0-SNAPSHOT`
#      1. updates all existing pom.xml with release version - `7.52.0`
#      2. creates and checkout a release branch `release/7.52.0`
#      3. commits locally the branch
#      4. Checkout init branch
#  2. Creates locally next development branch
#      1. Executes [prepare-next-snapshot.sh](#prepare-next-snapshot.sh)
#      2. Commits changes to the current branch
#      **NOTE:** Commit message contains `[skip ci]` which skip CI Build in Gitlab

set -euo pipefail

GIT_COMMANDS_LOG_FILE=${GIT_COMMANDS_LOG_FILE:-"/tmp/automation-git-logs"}
CURRENT_BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

if [ -n "$(git status --porcelain)" ]; then
  echo "STOP! There are changes in your local repo, please shelf them before continue."
  git status --porcelain
  exit 1
fi

if [ "$(git rev-parse --abbrev-ref HEAD)" != "master" ]; then
  echo "Your branch IS NOT 'master'. You have to be on master branch before continue."
  exit 1
fi

function create_new_release() {
  echo "Preparing New release"

  NEW_RELEASE_VERSION=$1

  CURRENT_MAVEN_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
  NEW_RELEASE_VERSION=${NEW_RELEASE_VERSION:-$(echo ${CURRENT_MAVEN_VERSION} | cut -d '.' -f -3)}

  echo "Changing version from $CURRENT_MAVEN_VERSION to release one - $NEW_RELEASE_VERSION in all pom.xml files"

  #https://stackoverflow.com/a/57766728
  if [[ "$OSTYPE" == "darwin"* ]]; then
    find . -name pom.xml -exec sed -i '' -e "s/$CURRENT_MAVEN_VERSION/$NEW_RELEASE_VERSION/g" '{}' &> /dev/null \;
  else
    find . -name pom.xml -exec sed -i -e "s/$CURRENT_MAVEN_VERSION/$NEW_RELEASE_VERSION/g" '{}' &> /dev/null \;
  fi

  RELEASE_BRANCH="release/$NEW_RELEASE_VERSION"
  echo "Creating new release branch $RELEASE_BRANCH"
  git checkout -b ${RELEASE_BRANCH}

  echo "Adding changed pom.xml's and committing to ${RELEASE_BRANCH} branch"
  find . -name pom.xml -exec git add '{}' &> /dev/null \;

  git commit -m "Prepare release $NEW_RELEASE_VERSION"

  echo "git push -u origin ${RELEASE_BRANCH}" >> $GIT_COMMANDS_LOG_FILE

  echo "Switching back to current branch ${CURRENT_BRANCH_NAME}"
  git checkout ${CURRENT_BRANCH_NAME}
}

function create_new_dev_iteration() {
  echo "Preparing repo for the new dev iteration"

  CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"
  $CURRENT_DIR/prepare-next-snapshot.sh

  git commit -m "CUDA-0 Prepare for the next development iteration [skip ci]"
  echo "git push -u origin ${CURRENT_BRANCH_NAME}" >> $GIT_COMMANDS_LOG_FILE
}

# Cleanup log file if exists
rm -f $GIT_COMMANDS_LOG_FILE

create_new_release ""

create_new_dev_iteration

echo "Evertyhing is updated locally. Execute next git commands to make it alive."
cat $GIT_COMMANDS_LOG_FILE
rm $GIT_COMMANDS_LOG_FILE
