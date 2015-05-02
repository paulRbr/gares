# Fork of https://raw.githubusercontent.com/rails/rails/master/activesupport/lib/active_support/core_ext/module/attribute_accessors.rb
class Module
  def mattr_reader(*syms)
    syms.each do |sym|
      raise NameError.new("invalid attribute name: #{sym}") unless sym =~ /^[_A-Za-z]\w*$/
      class_eval(<<-EOS, __FILE__, __LINE__ + 1)
        @@#{sym} = nil unless defined? @@#{sym}

        def self.#{sym}
          @@#{sym}
        end
      EOS

      class_eval(<<-EOS, __FILE__, __LINE__ + 1)
        def #{sym}
          @@#{sym}
        end
      EOS
      class_variable_set("@@#{sym}", yield) if block_given?
    end
  end
end
