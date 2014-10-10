# encoding: UTF-8

class Class
  # Allows the definition of methods on a class that will be available via
  # super.
  #
  # @example
  #     class Foo
  #       chainable do
  #         def hello
  #           "hello"
  #         end
  #       end
  #     end
  #
  #     class Foo
  #       def hello
  #         super + " Merb!"
  #       end
  #     end
  #
  #     Foo.new.hello #=> "hello Merb!"
  #
  # @param &blk A block containing method definitions that should be
  #   marked as chainable
  #
  # @return [Module] The anonymous module that was created.
  #
  # @note Taken from Extlib
  # @deprecated
  # @api private
  def chainable(&blk)
    mod = Module.new(&blk)
    include mod
    mod
  end

  # Defines class-level inheritable attribute reader. Attributes are available to subclasses,
  # each subclass has a copy of parent's attribute.
  #
  # @param *syms<Array[#to_s]> Array of attributes to define inheritable reader for.
  # @return [Array<#to_s>] Array of attributes converted into inheritable_readers.
  #
  # @api public
  #
  # @todo Do we want to block instance_reader via :instance_reader => false
  # @todo It would be preferable that we do something with a Hash passed in
  #   (error out or do the same as other methods above) instead of silently
  #   moving on). In particular, this makes the return value of this function
  #   less useful.
  def class_inheritable_reader(*ivars)
    instance_reader = ivars.pop[:reader] if ivars.last.is_a?(Hash)

    ivars.each do |ivar|
      self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.#{ivar}
          return @#{ivar} if defined?(@#{ivar})
          return nil      if self.object_id == #{self.object_id}
          ivar = superclass.#{ivar}
          return nil if ivar.nil?
          @#{ivar} = ivar.dup
        end
      RUBY

      unless instance_reader == false
        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{ivar}
            self.class.#{ivar}
          end
        RUBY
      end
    end
  end

  # Defines class-level inheritable attribute writer. Attributes are available to subclasses,
  # each subclass has a copy of parent's attribute.
  #
  # @param *syms<Array[*#to_s, Hash{:instance_writer => Boolean}]> Array of attributes to
  #   define inheritable writer for.
  # @option syms :instance_writer<Boolean> if true, instance-level inheritable attribute writer is defined.
  # @return [Array<#to_s>] An Array of the attributes that were made into inheritable writers.
  #
  # @api public
  #
  # @todo We need a style for class_eval <<-HEREDOC. I'd like to make it
  #   class_eval(<<-RUBY, __FILE__, __LINE__), but we should codify it somewhere.
  def class_inheritable_writer(*ivars)
    instance_writer = ivars.pop[:instance_writer] if ivars.last.is_a?(Hash)
    ivars.each do |ivar|
      self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.#{ivar}=(obj)
          @#{ivar} = obj
        end
      RUBY
      unless instance_writer == false
        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{ivar}=(obj) self.class.#{ivar} = obj end
        RUBY
      end
    end
  end

  # Defines class-level inheritable attribute accessor. Attributes are available to subclasses,
  # each subclass has a copy of parent's attribute.
  #
  # @param *syms<Array[*#to_s, Hash{:instance_writer => Boolean}]> Array of attributes to
  #   define inheritable accessor for.
  # @option syms :instance_writer<Boolean> if true, instance-level inheritable attribute writer is defined.
  # @return [Array<#to_s>] An Array of attributes turned into inheritable accessors.
  #
  # @api public
  def class_inheritable_accessor(*syms)
    class_inheritable_reader(*syms)
    class_inheritable_writer(*syms)
  end
end
