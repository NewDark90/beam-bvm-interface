<#
    
#>
param (
    # height of largest column without top bar
    [switch]$currentBranch = $false
)

$originalDir = Get-Location;
$versionRegex = "(\d+)\.(\d+)\.(\d+)"
$selectedTag = ""

try {

    Set-Location "${PSScriptRoot}\beam"
    Invoke-Expression -Command "git fetch --all"

    if (!$currentBranch)
    {
        $tags = Invoke-Expression -Command "git tag --list"
        $tags | Select-String "beam-$versionRegex" | Write-Output 

        while ($selectedTag -notin $tags)
        {
            $selectedTag = Read-Host "Input a git tag from the beam repository to build"
        }
        Invoke-Expression -Command "git checkout tags/$selectedTag"
    }
    else {
        $selectedTag = "current-branch"
    }

    $buildRoot =  "../build/$selectedTag"

    New-Item -ItemType Directory -Force -Path "$buildRoot/src/"
    Remove-Item "$buildRoot/src/*" -Recurse -Force

    $rawLine = "pub type c_void = ::core::ffi::c_void; pub type c_char = i8;"
    Invoke-Expression -Command "bindgen ""./bvm/Shaders/common.h"" -o ""../build/$selectedTag/src/lib.rs"" --module-raw-line ""root"" ""$rawLine"" --no-layout-tests --enable-cxx-namespaces --distrust-clang-mangling --use-core --ctypes-prefix ""root"" -- -x c++ -I ""$Env:BOOST_ROOT"" -I ""./"" -U _MSC_VER"
    Copy-Item -Path "../cargo.bvm-template.toml" -Destination "$buildRoot/cargo.toml" -Force

    $versionMatch = ($selectedTag | Select-String $versionRegex)
    if ($versionMatch.Matches.Success)
    {
        (Get-Content "$buildRoot/cargo.toml").replace('{VERSION}', $versionMatch.Matches) | Set-Content "$buildRoot/cargo.toml"
    }
    else 
    {
        Write-Host "Could not derive a version from the tag. Cargo.toml does not have a valid version in place."
    }

}
catch {
    Write-Host $_
}
finally {
    Set-Location $originalDir
}
