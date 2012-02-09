hostre = /^postgres\./

before :host_name => hostre do
    @title = "My IT Blog"
    SassExt.set_color :page_colorbase => [0x12, 0x34, 0x56]
end
