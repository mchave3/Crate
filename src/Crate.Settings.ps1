# specify the minimum required major PowerShell version that the build script should validate
[version]$script:requiredPSVersion = '7.4'

# Enable or disable unit tests during build
$script:EnableUnitTests = $false
