# CI/CD

Releases are created automatically by GitHub Actions, see [.githuv/ci_build.yml](.githuv/ci_build.yml). Here is a checklist for testing the CI/CD.

* Testing goes best when you make hot fixes on the main branch. Check with the team that you are allowed to do this.
* Do a commit on main that has a commit message starting with `fix:`. The following should happen:
  * The pipeline succeeds - this checks all authorizations are in place.
  * A commit with a message starting with `chore:` has been added automatically.
  * The extra commit updates files `classes/BuildInfo.properties` and `CHANGELOG.md`.
  * These files should have trustworthy contents - speaks for itself.
  * On GitHub, there is a tag for the new version that starts with `v`. For example if the new release is `3.2.1` then the tag should be `v3.2.1`. You can get this tag using `git fetch v3.2.1` on the command line. After that, the new commit is in `FETCH_HEAD`, so you can check it out with `git checkout FETCH_HEAD`.
  * The docker image for the release has been created on http://www.dockerhub.com. The `latest` tag should have been updated - creation time should be the current time. Depending on the type of release, the `3.2.1`, the `3.2` or the `3` tags should be the current date.
  * Check on dockerhub that tags that should not have been updated do not have the current time as creation time.
  * Run the docker image using `docker run -p 8080:8080 wearefrank/webformulierenverwerker:3.2.1`. Check the name of the docker container you started using `docker ps -a`. Login to the docker container using `docker exec -it <container name> bash`. Check that `/opt/frank/resources/BuildInfo.property` contains the right version and the right date.
* Check a breaking change like above. A commit message has a header, a body and a footer. Have the word `BREAKING` in the footer. This should update the major version.
* Do a commit with \[skip ci\] in the commit message before the `:`. It should not make a release and it should not push a docker image.
* Make a pull request. Check that no release is made and that no docker image is pushed.