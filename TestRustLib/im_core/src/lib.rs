mod bridge;
pub mod logger;
pub mod protos;
// use logger::*;
// #[cxx::bridge(namespace = "im::core")]
// mod ffi {
//     extern "Rust" {
//         type Logger;

//         fn new_logger() -> Box<Logger>;
//         fn waring(&self, message: String);
//     }
// }

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        unsafe {
            let logger = crate::logger::new_logger();
            logger.warning("Hello world".to_string());
            logger.info("Hello world".to_string());
        }
    }
}
