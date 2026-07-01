logical_product_family  = "launch"
logical_product_service = "appcfg"
class_env               = "dev"
instance_env            = 1
instance_resource       = 1
resource_names_map      = { application = { name = "appcfgapp", max_length = 64 }, extension = { name = "appcfgext", max_length = 64 }, sns_topic = { name = "snstopic", max_length = 64 } }
tags                    = { environment = "test", module = "appconfig_extension_association" }
