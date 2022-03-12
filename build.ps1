$originalDir = Get-Location;

try {
    Invoke-Expression -Command "git submodule update"

    Write-Output $PSScriptRoot

    Set-Location "${PSScriptRoot}\beam"

    $tags = Invoke-Expression -Command "git tag --list"
    
    $versionRegex = "(\d+)\.(\d+)\.(\d+)"

    $tags | Select-String "beam-$versionRegex" | Write-Output 

    $selectedTag = ""

    while ($selectedTag -notin $tags)
    {
        $selectedTag = Read-Host "Input a git tag from the beam repository to build"
    }

    Invoke-Expression -Command "git checkout tags/$selectedTag"

    New-Item -ItemType Directory -Force -Path "../build/$selectedTag/src/"

    Invoke-Expression -Command "bindgen ""./bvm/Shaders/common.h"" -o ""../build/$selectedTag/src/lib.rs"" --no-layout-tests --enable-cxx-namespaces --distrust-clang-mangling -- -x c++ -I ""$Env:BOOST_ROOT"" -I ""./"""

}
catch {
    Write-Host $_
}
finally {
    Set-Location $originalDir
}
