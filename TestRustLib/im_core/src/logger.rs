pub trait LoggerCallback {
    fn on_message(&self, message: String);
}

pub struct Logger<'a> {
    name: String,
    callback: Option<Box<dyn FnMut() + 'a>>,
}

pub unsafe fn new_logger<'a>() -> Box<Logger<'a>> {
    Box::new(Logger {
        name: String::from("test"),
        callback: None,
    })
}

impl<'a> Logger<'a> {
    pub fn warning(&self, message: String) {
        println!("[{}][warning] {}", self.name, message)
    }

    pub fn info(&self, message: String) {
        println!("[{}][info] {}", self.name, message)
    }

    pub fn set_callback(&mut self, callback: impl FnMut() + 'a) {
        self.callback = Some(Box::new(callback))
    }
}
