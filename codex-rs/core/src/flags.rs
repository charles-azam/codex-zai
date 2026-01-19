use env_flags::env_flags;

env_flags! {
    /// Fixture path for offline tests (see client.rs).
    pub CODEX_RS_SSE_FIXTURE: Option<&str> = None;
}

pub const ZAI_DEFAULT_MODEL: &str = "glm-4.7";
