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

    Set-Location "${PSScriptRoot}\..\beam"
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

    $rawLine = "#![cfg_attr(not(feature = ""std""), no_std)]"
    $rawModLine = "pub type c_void = ::core::ffi::c_void; pub type c_char = u8;"
    $bindgenCommand = [String]::Join(" ", 
        "bindgen ""./bvm/Shaders/common.h""", #file target that has our needed types
        "-o ""../build/$selectedTag/src/lib.rs""", #file to build
        "--no-layout-tests", #no need
        "--enable-cxx-namespaces", #use c++
        "--distrust-clang-mangling", 
        "--raw-line ""$rawLine""",
        "--use-core", #prefers non-std types
        "--module-raw-line ""root"" ""$rawModLine""", #specifically types out void and c_char instead of std
        "--ctypes-prefix ""root""", #non-std types given root prefix to go with module-raw-line
        "--with-derive-default", #Adds struct defaults
        "-- -x c++ -I ""$Env:BOOST_ROOT"" -I ""./"" -U _MSC_VER" #Clang parameters
    );
    Invoke-Expression -Command $bindgenCommand
    Copy-Item -Path "../build-template/*" -Destination "$buildRoot/" -Recurse -Force

    $versionMatch = ($selectedTag | Select-String $versionRegex)
    if ($versionMatch.Matches.Success)
    {
        (Get-Content "$buildRoot/Cargo.toml").replace('{VERSION}', $versionMatch.Matches) | Set-Content "$buildRoot/Cargo.toml"
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
