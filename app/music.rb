hostre = /^music\./

before :host_name => hostre do
    @title = "My Music Blog"
    SassExt.set_color :page_colorbase => [0x12, 0x31, 0x23]
end
