# Demo and Tests

This directory contains demo and test scripts. Scripts `*.test.ps1` are invoked
by [Invoke-Build](https://github.com/nightroman/Invoke-Build).

Example PowerShell commands

- Ensure *PowerShelf* scripts are in the path.
- Change to this demo folder.

Invoke all tests in *Assert-SameFile.test.ps1*:

    Invoke-Build * Assert-SameFile.test.ps1

Invoke the test *MissingSample* in *Assert-SameFile.test.ps1*:

    Invoke-Build MissingSample Assert-SameFile.test.ps1
