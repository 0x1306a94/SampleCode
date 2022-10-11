use crate::logger;

use logger::*;

#[cxx::bridge(namespace = "im::core")]
mod ffi {
    extern "Rust" {
        type Logger;

        fn new_logger() -> Box<Logger>;
        fn warning(&self, message: String);
        fn info(&self, message: String);
    }
}
