hostre = /^computers\./

before :host_name => hostre do
    @title = "My IT Blog"
    SassExt.set_color :page_colorbase => [0x65, 0x43, 0x65]
end
