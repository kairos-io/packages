#!/bin/bash
# Free disk space on a GitHub-hosted Ubuntu runner.
#
# The luet builds in build.yaml and pr.yaml do not fit in the space a
# hosted amd64 image leaves free, so the toolchains they never use are
# removed first. The arm64 images do not ship most of this, which is why
# build-arm64.yaml has no equivalent step.
#
# Every removal is best-effort: the package lists differ between image
# versions, and a name that is no longer shipped must not fail the build.

largest_packages() {
  echo "Listing top largest packages"
  dpkg-query -Wf '${Installed-Size}\t${Package}\t${Status}\n' |
    awk '$NF == "installed" { print $1 "\t" $2 }' |
    sort -nr |
    head -n 30
  echo
}

largest_packages
df -h
echo

sudo apt-get remove -y '^llvm-.*|^libllvm.*' || true
sudo apt-get remove --auto-remove android-sdk-platform-tools || true
sudo apt-get purge --auto-remove android-sdk-platform-tools || true
sudo rm -rf /usr/local/lib/android
sudo apt-get remove -y '^dotnet-.*|^aspnetcore-.*' || true
sudo rm -rf /usr/share/dotnet
sudo apt-get remove -y '^mono-.*' || true
sudo apt-get remove -y '^ghc-.*' || true
sudo apt-get remove -y '.*jdk.*|.*jre.*' || true
sudo apt-get remove -y 'php.*' || true
sudo apt-get remove -y hhvm || true
sudo apt-get remove -y powershell || true
sudo apt-get remove -y firefox || true
sudo apt-get remove -y monodoc-manual || true
sudo apt-get remove -y msbuild || true
sudo apt-get remove -y microsoft-edge-stable || true
sudo apt-get remove -y '^google-.*' || true
sudo apt-get remove -y azure-cli || true
sudo apt-get remove -y '^mongo.*-.*|^postgresql-.*|^mysql-.*|^mssql-.*' || true
sudo apt-get remove -y '^gfortran-.*' || true
sudo apt-get remove -y '^gcc-*' || true
sudo apt-get remove -y '^g++-*' || true
sudo apt-get remove -y '^cpp-*' || true
sudo apt-get autoremove -y
sudo apt-get clean
echo

largest_packages
sudo rm -rfv build || true
df -h
