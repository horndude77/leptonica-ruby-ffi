module Leptonica
    class PointerClass
        attr_reader :pointer
        def initialize(pointer)
            @pointer = pointer
            ObjectSpace.define_finalizer(self, PointerClass.release(pointer, self.class))
        end

        def self.release(pointer, clazz)
            proc {|id| clazz.release(pointer)}
        end
    end
end
