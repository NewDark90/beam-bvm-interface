# beam-bvm-interface
A rust crate for referencing all of the Beam Virtual Machine methods and structs for dapps.

## Requirements

Most of the dependencies in order to build the Beam projects.
- Git
- Clang
- Boost

Other Dependencies:
- Bindgen (https://rust-lang.github.io/rust-bindgen/requirements.html)
- Powershell


## How to use
Run build.ps1 in order to build the project. You'll need to provide the specific git tag you'd like to build. 

The tags "beam-X.X.X" will automatically display for ease of entry, but any tag will be valid. 

If it works, you should have generated a crate library that looks like this: 

![image](https://user-images.githubusercontent.com/12650208/158047523-c16e109a-8fa8-4911-864f-5262cd3221be.png)

