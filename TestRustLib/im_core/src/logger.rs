pub struct Logger {
    name: String,
}

pub fn new_logger() -> Box<Logger> {
    Box::new(Logger {
        name: String::from("test"),
    })
}

impl Logger {
    pub fn warning(&self, message: String) {
        println!("[{}][warning] {}", self.name, message)
    }

    pub fn info(&self, message: String) {
        println!("[{}][info] {}", self.name, message)
    }
}
