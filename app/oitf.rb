hostre = /^oitf\./

before :host_name => hostre do
    @default_tag = :writing
    @blog_title  = "An Oak in the Fall"
    SassExt.set_color :page_colorbase => [0x12, 0x12, 0x12]
end

