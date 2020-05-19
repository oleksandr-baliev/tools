#!/usr/bin/env bash
set -euo pipefail

if [ -n "$(git status --porcelain)" ]; then
  echo "STOP! There are changes in your local repo, please shelf them before continue or just comment out the check."
  git status --porcelain
  exit 1
fi

NEW_RELEASE_VERSION=$1

CURRENT_BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

GIT_COMMANDS_LOG_FILE=${GIT_COMMANDS_LOG_FILE:-"/tmp/automation-git-logs"}

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

# Cleanup log file if exists
rm -f $GIT_COMMANDS_LOG_FILE

create_new_release "$NEW_RELEASE_VERSION"

echo "Evertyhing is updated locally. Execute next git commands to make it alive."
cat $GIT_COMMANDS_LOG_FILE
rm $GIT_COMMANDS_LOG_FILE
