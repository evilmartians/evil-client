class Evil::Client
  # Построитель относительного имени ресурса (URN - unified resource name),
  # который может относитсья к различным API
  # @see https://ru.wikipedia.org/wiki/URN
  #
  # Любой метод (объекта или класса) без восклицательных знаков интерпретируется
  # как часть имени и возвращает обновленный URN с добавленной частью.
  #
  # Метод [#call] (с алиасом +[]+) используется для вставки в адрес
  # динамической части (также возвращает обновленный URN).
  #
  # Метод [#finalize!] без аргументов возвращает итоговую строку URN
  #
  #     URN.users[1].sms.finalize! # => "users/1/sms"
  #
  # @api private
  #
  class URN
    # Добавляет динамическую часть к адресу и возвращает обновленный адрес
    #
    # @param [#to_s] part
    #
    # @return [Evil::Client::URN]
    #
    def call(part)
      self.class.new(@parts + [part])
    end
    alias_method :[], :call

    # Возвращает сформированную строку адреса URN
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
    # @return [Evil::Client::URN]
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
