data:extend({
    {
        type = "string-setting",
        name = "tsx-behaviour",
        setting_type = "runtime-global",
        default_value = "switch-to-manual",
        allowed_values = {"switch-to-manual", "apply-custom-conditions"},
    },
    {
        type = "bool-setting",
        name = "tsx-personaltrainonly",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "tsx-removetemps",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "int-setting",
        name = "tsx-searchradius",
        setting_type = "runtime-global",
        default_value = 20
    },
    {
        type = "bool-setting",
        name = "tsx-rendertarget",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "tsx-openschedule",
        setting_type = "runtime-global",
        default_value = true
    },
})