class Evil::Client
  # Relative paths builder
  #
  # Builds paths by chaining method in OO style.
  #
  # Every instance or class method is treated as a part of relative path
  # (you can use latin letters, digits and underscores only).
  # It returns new instance with a corresponding part being added to the path.
  #
  #     Path.users
  #     # => <Path @parts=["users"]>
  #
  # Use brackets `[]` to insert dynamic parts or utf symbols to the path.
  #
  #     Path.users[1].sms
  #     # => <Path @parts=["users", "1", "sms"]>
  #
  #     Path["духовные-скрепы"][1]
  #     # => <Path @parts=["духовные-скрепы", "1"]>
  #
  # [#finalize!] returns the resulting path:
  #
  #     Path.users[1].sms.finalize!
  #     # => "users/1/sms"
  #
  # @api private
  #
  class Path
    # Returns a new instance of the class with a dynamic part added to the path
    #
    # @param [#to_s] part
    #
    # @return [Evil::Client::Path]
    #
    def call(part)
      self.class.new(@parts + [part])
    end
    alias_method :[], :call

    # Returns the resulting path
    #
    # @return [String]
    #
    def finalize!
      @parts.join("/")
    end

    protected

    # Изменяет текущий объект путем добавления к нему части адреса
    #
    # @param [#to_s] part
    #
    # @return [Evil::Client::Path]
    #
    def call!(part)
      @parts << part
      self
    end

    private

    REGULAR = /^\w+$/

    def initialize(parts = [])
      @parts = parts
    end

    def method_missing(name, *args)
      (name[REGULAR] && args.empty?) ? call(name) : super
    end

    def respond_to_missing?(name, *)
      !!name[REGULAR]
    end

    def self.method_missing(*args)
      new.public_send(*args)
    end

    def self.respond_to_missing?(name, *)
      !!name[REGULAR] || instance_methods.include?(name)
    end
  end
end
