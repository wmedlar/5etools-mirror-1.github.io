#!/bin/bash

set -e

if [[ $# -eq 0 ]]; then
    echo "No arguments provided. Usage: generate-release-notes.sh <version>"
    exit 1
fi

version=$1

# Release version number without "v" prefix to match the format of changelog.json.
version_number="${version#v}"

# This parses the JSON blob for this specific version from changelog.json.
changelog="$(
    jq --arg version "$version_number" --compact-output \
    '.[] | select(.ver == $version)'                    \
    data/changelog.json
)"

if [[ -z "$changelog" ]]; then
    echo "Changelog entry for version $version does not exist."
    exit 1
fi

{
    # The "hub" tool reads all text up to the first empty line as the release title.
    # For changelog entries with a title, this is formatted as "<version> - <title>".
    # For changelog entries without a title, this is formatted as simply "<version>".
    echo -n "$version"
    jq -r 'if has("title") then ", \(.title | tojson) Edition" else "" end' <<< "$changelog"

    # Empty newline signifies the end of the release title.
    echo

    # Changelog items are already markdown, so no additional formatting needs to be done here.
    jq -r '.txt' <<< "$changelog"
}
