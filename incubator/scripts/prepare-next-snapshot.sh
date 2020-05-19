#!/usr/bin/env bash
set -euo pipefail

function adjust_next_development_version_in_poms {
  echo "Finding current maven version"
  CURRENT_MAVEN_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
  MAJOR_VER=$(echo ${CURRENT_MAVEN_VERSION} | cut -d '.' -f 1)
  MINOR_VER=$(echo ${CURRENT_MAVEN_VERSION} | cut -d '.' -f 2)
  NEXT_MINOR_VER=$((MINOR_VER + 1))
  NEXT_DEV_VERSION="$MAJOR_VER.$NEXT_MINOR_VER.0-SNAPSHOT"

  echo "Changing next dev version from $CURRENT_MAVEN_VERSION to $NEXT_DEV_VERSION in all pom.xml files"

  #https://stackoverflow.com/a/57766728
  if [[ "$OSTYPE" == "darwin"* ]]; then
    find . -name pom.xml -exec sed -i '' -e "s/$CURRENT_MAVEN_VERSION/$NEXT_DEV_VERSION/g" '{}' &> /dev/null \;
  else
    find . -name pom.xml -exec sed -i -e "s/$CURRENT_MAVEN_VERSION/$NEXT_DEV_VERSION/g" '{}' &> /dev/null \;
  fi

  echo "Adding to git changed pom.xml's"
  find . -name pom.xml -exec git add '{}' &> /dev/null \;
}
