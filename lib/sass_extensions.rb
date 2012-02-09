# This code was taken from https://gist.github.com/428874

module SassExt
    Sass::Script::Functions.send :include, self

    def self.variables(which)
        @variables ||= {
            :strings => {},
            :numbers => {},
            :colors  => {},
            :bools   => {},
            :lists   => {},
        }

        @variables[which]
    end

    def self.set_string(values = {})
        variables(:strings).merge! values
    end

    def self.set_number(values = {})
        variables(:numbers).merge! values
    end

    def self.set_color(values = {})
        variables(:colors).merge! values
    end

    def self.set_bool(values = {})
        variables(:bools).merge! values
    end

    def self.set_list(values = {})
        variables(:lists).merge! values
    end

    def string(value)
        Sass::Script::String.new(SassExt.variables(:strings)[:"#{value}"])
    end

    def number(value)
        Sass::Script::Number.new(SassExt.variables(:numbers)[:"#{value}"])
    end

    def color(value)
        Sass::Script::Color.new(SassExt.variables(:colors)[:"#{value}"])
    end

    def bool(value)
        Sass::Script::Bool.new(SassExt.variables(:bools)[:"#{value}"])
    end

    def list(value)
        Sass::Script::List.new(SassExt.variables(:lists)[:"#{value}"])
    end

    def page_colorbase()
        color(:page_colorbase)
    end
end
