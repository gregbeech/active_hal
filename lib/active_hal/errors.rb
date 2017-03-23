# frozen_string_literal: true
module ActiveHal
  class Error < StandardError
  end

  class ModelInvalid < Error
    attr_reader :model

    def initialize(model = nil)
      if model
        @model = model
        super("Model invalid: #{model.errors.full_messages.join(', ')}")
      else
        super('Model invalid')
      end
    end
  end

  class ModelNotSaved < Error
    attr_reader :model

    def initialize(message = nil, model = nil)
      @model = model
      super(message || 'Model not saved')
    end
  end
end
