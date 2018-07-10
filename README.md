# Github/Travis CI webhook forwarder

An HTTP proxy application that accepts webhook requests from Github and triggers a build in Travis CI.

## Usage

    GITHUB_SECRET=secret \
      GITHUB_ACCESS_TOKEN=token \
      REPO_SLUG=pact-foundation%2Fpact-ruby-standalone \
      COMMIT_MESSAGE="Triggered by gem release webhook" \
      BUILD_SCRIPT="./script/release-from-travis.sh" \
      bundle exec rackup
