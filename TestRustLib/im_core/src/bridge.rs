use crate::logger;

use crate::protos::generated_with_pure::api::SetupParams;
use crate::protos::generated_with_pure::api::CMDID;
use logger::*;
use protobuf::Message;

#[cxx::bridge(namespace = "im::core")]
mod ffi {

    extern "Rust" {
        type Logger<'a>;
        unsafe fn new_logger<'a>() -> Box<Logger<'a>>;
        fn warning(&self, message: String);
        fn info(&self, message: String);

    }

    extern "Rust" {
        type Response;
        fn get_request_id(&self) -> i32;
        fn get_payload(&self) -> *const u8;
        fn get_payload_len(&self) -> usize;

    }

    extern "Rust" {
        unsafe fn send_request(request_id: i32, cmdid: i32, payload: *const u8, payload_len: usize);
        fn recive(timeout: i32) -> Box<Response>;
    }
}

pub struct Response {
    request_id: i32,
    payload: Vec<u8>,
    payload_len: usize,
}

impl Response {
    fn get_request_id(&self) -> i32 {
        return self.request_id;
    }

    fn get_payload(&self) -> *const u8 {
        return self.payload.as_ptr();
    }

    fn get_payload_len(&self) -> usize {
        return self.payload_len;
    }
}
pub unsafe fn send_request(request_id: i32, cmdid: i32, payload: *const u8, payload_len: usize) {
    let cmd: Option<CMDID> = protobuf::Enum::from_i32(cmdid);
    match cmd {
        Some(v) => match v {
            Setup => {
                let bytes = std::slice::from_raw_parts(payload, payload_len);
                let params = SetupParams::parse_from_bytes(bytes).unwrap();
                println!("cmdid: {} {}", cmdid, params);
            }
            _ => {}
        },
        _ => {}
    }
}

pub fn recive(timeout: i32) -> Box<Response> {
    let mut out_msg = SetupParams::new();
    out_msg.uid = "41050".to_string();
    out_msg.name = "KK".to_string();

    let out_bytes: Vec<u8> = out_msg.write_to_bytes().unwrap();
    let len = out_bytes.len();
    return Box::new(Response {
        request_id: 33,
        payload: out_bytes,
        payload_len: len,
    });
}
