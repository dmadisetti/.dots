name: "build isos"

jobs:
  build-iso:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - id: provision
      uses: ./.github/runner
    - run: | echo shell ${{ steps.provision.outputs.shell }}

