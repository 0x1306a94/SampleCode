#[allow(unused_must_use)]
fn main() {
    cxx_build::bridge("src/bridge.rs")
        .flag_if_supported("-std=c++14")
        .compile("im_core_cxxbridge");

    println!("cargo:rerun-if-changed=src/bridge.rs");

    // cxx_build::bridge("src/lib.rs");
    // println!("cargo:rerun-if-changed=src/lib.rs");
}
