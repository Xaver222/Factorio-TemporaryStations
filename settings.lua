data:extend({
    {
        type = "string-setting",
        name = "tempstations-behaviour",
        setting_type = "runtime-global",
        default_value = "switch-to-manual",
        allowed_values = {"switch-to-manual", "apply-custom-conditions"},
    },
    {
        type = "bool-setting",
        name = "tempstations-personaltrainonly",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "tempstations-removetemps",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "int-setting",
        name = "tempstations-searchradius",
        setting_type = "runtime-global",
        default_value = 20
    },
    {
        type = "bool-setting",
        name = "tempstations-rendertarget",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "tempstations-openschedule",
        setting_type = "runtime-global",
        default_value = true
    },
})