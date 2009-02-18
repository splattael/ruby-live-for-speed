module LFS
  module Parser
    module Packet
      module Helper

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def spare
            @spare ||= 0
            :"_sp#{@spare += 1}"
          end

          def first_byte_is(name)
            class_eval do
              define_method name do
                first_byte
              end

              define_method "#{name}=" do |arg|
                self.first_byte = arg
              end
            end
          end
        end

      end
    end
  end
end

