pub mod chat;
pub(crate) mod headers;
pub mod responses;

pub use chat::ChatRequest;
pub use chat::ChatRequestBuilder;
pub use responses::ResponsesRequest;
pub use responses::ResponsesRequestBuilder;

use serde_json::Value;

pub(crate) fn merge_extra_body(payload: &mut Value, extra_body: Option<&Value>) {
    let Some(extra_body) = extra_body else {
        return;
    };
    let Some(extra_map) = extra_body.as_object() else {
        return;
    };
    let Some(payload_map) = payload.as_object_mut() else {
        return;
    };

    for (key, value) in extra_map {
        if payload_map.contains_key(key) {
            continue;
        }
        payload_map.insert(key.clone(), value.clone());
    }
}
