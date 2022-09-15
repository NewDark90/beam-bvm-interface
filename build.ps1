$originalDir = Get-Location;
$versionRegex = "(\d+)\.(\d+)\.(\d+)"
$selectedTag = ""

try {
    Invoke-Expression -Command "git submodule update"

    Set-Location "${PSScriptRoot}\beam"

    $tags = Invoke-Expression -Command "git tag --list"
    $tags | Select-String "beam-$versionRegex" | Write-Output 

    while ($selectedTag -notin $tags)
    {
        $selectedTag = Read-Host "Input a git tag from the beam repository to build"
    }
    $buildRoot =  "../build/$selectedTag"

    Invoke-Expression -Command "git checkout tags/$selectedTag"
    New-Item -ItemType Directory -Force -Path "$buildRoot/src/"
    Invoke-Expression -Command "bindgen ""./bvm/Shaders/common.h"" -o ""../build/$selectedTag/src/lib.rs"" --no-layout-tests --enable-cxx-namespaces --distrust-clang-mangling --allowlist-type Env.* --allowlist-function Env.* --allowlist-type Env.* -- -x c++ -I ""$Env:BOOST_ROOT"" -I ""./"""
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
