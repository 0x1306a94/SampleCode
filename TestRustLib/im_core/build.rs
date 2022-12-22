#[allow(unused_must_use)]
fn main() {
    cxx_build::bridge("src/bridge.rs")
        .flag_if_supported("-std=c++14")
        .compile("im_core_cxxbridge");

    println!("cargo:rerun-if-changed=src/bridge.rs");

    // cxx_build::bridge("src/lib.rs");
    // println!("cargo:rerun-if-changed=src/lib.rs");

    use protobuf_codegen::Codegen;

    Codegen::new()
        .pure()
        .cargo_out_dir("generated_with_pure")
        .input("src/protos/api.proto")
        .include("src/protos")
        .run_from_script();

    use std::env;
    let out_dir = env::var("OUT_DIR").unwrap();

    println!("out_dir: {}", out_dir);
}
