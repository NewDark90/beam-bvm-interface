# beam-bvm-interface
A rust crate for referencing all of the Beam Virtual Machine methods and structs for dapps

## What to expect

All of the code here has been auto generated with bindgen. The goal of this package is to be the lowest level direct interface with the Beam Virtual Machine. 

Documentation of the methods usable within the BVM can be found at the [BeamMW Shader-SDK wiki](https://github.com/BeamMW/shader-sdk/wiki)

## Installation

Install with cargo: 

`cargo install beam_bvm_interface`

## Compiling

This crate is not going to delve into the specifics of compiling for the BVM. The steps needed in order to compile at all are here for you though.
This assumes a workspace with a `contract` package, `app` package, and optional shared code in a `common` package.

1. Install `rustup` on your system. See rust installation instructions [here](https://forge.rust-lang.org/infra/other-installation-methods.html#other-ways-to-install-rustup).
2. Install rust toolchain:
  `$ rustup toolchain install stable`
3. Add wasm32-wasi target
  `$ rustup target add wasm32-wasi`
4. Compile the project
  `$ cargo build --target wasm32-wasi -r`
5. Compiled wasm files will be in `./target/wasm32-wasi/release` directory

After that you can use `app.wasm` and `contract.wasm` files in the same way you use it in Beam's contracts (see https://github.com/BeamMW/shader-sdk/wiki/Running-Beam-Shaders-using-CLI-Wallet).