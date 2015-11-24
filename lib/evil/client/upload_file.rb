require 'delegate'

class Evil::Client
  class UploadFile < SimpleDelegator
    def pos
      tempfile.pos
    end

    def pos=(value)
      tempfile.pos = value
    end
  end
end
