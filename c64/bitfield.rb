module C64
  class Bitfield

    def self.new *names
      Class.new do

        const_set :BITFIELD_NAMES, names

        def initialize value
          @value = value
        end

        def to_i
          @value
        end

        def on_update name
        end

        def inspect
          fields = BITFIELD_NAMES.map { |n| "#{n}:#{self.send(n)}" }
          "Bitfield(#{fields.join(" ")})"
        end

        names.each_with_index do |name, bit|

          # accessor methods, 0 or 1
          define_method name do
            @value >> bit & 1
          end

          # predicate methods; true or false
          define_method "#{name}?" do
            send(name) == 1
          end

          # writer methods; boolean, or 0 or 1
          define_method "#{name}=" do |flag|
            if flag && flag != 0
              @value |= (1 << bit)
            else
              @value &= ~(1 << bit)
            end
            on_update name
          end

        end
      end
    end

  end
end
