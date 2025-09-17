# PowerShelf demo and test scripts

Test scripts `*.test.ps1` are invoked by [Invoke-Build](https://github.com/nightroman/Invoke-Build).

**How to run tests**

- PowerShelf scripts are in the path.
- Change to this directory.

Invoke all tests in `Assert-SameFile.test.ps1`:

    Invoke-Build * Assert-SameFile.test.ps1

Invoke `MissingSample` in `Assert-SameFile.test.ps1`:

    Invoke-Build MissingSample Assert-SameFile.test.ps1
