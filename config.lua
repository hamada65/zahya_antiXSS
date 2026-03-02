-- zahya_antiXSS Configuration
-- Loaded before checker.lua via shared_script

AntiXSSConfig = {
    -- Allowed HTML tags (whitelist). Tags not in this list are stripped.
    allowed_tags = {
        font = true,
        i = true,
        b = true,
        u = true,
        strong = true,
        span = true,
        div = true,
        p = true,
        br = true,
        img = true,
    },

    -- Resources that skip sanitization (by GetCurrentResourceName)
    -- Use ["name"] = true or { "name1", "name2" }
    skipped_scripts = {
        -- ["my_trusted_ui"] = true,
    },

    -- When true, prints found dangerous content to console (client F8)
    debug = false,
}
