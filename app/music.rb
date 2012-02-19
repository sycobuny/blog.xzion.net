hostre = /^music\./

before :host_name => hostre do
    @default_tag = :music
    @blog_title  = "My Music Blog"
    SassExt.set_color :page_colorbase => [0x12, 0x31, 0x23]
end
