class Evil::Client
  #
  # Resolves rack-compatible response from schema for given settings
  # @private
  #
  class Resolver::Response < Resolver
    private

    PROCESSING_DONE = Object.new
    SKIP_RESPONSE   = Object.new

    def initialize(schema, settings, response)
      @__response__ = Array response
      super schema, settings, :responses, @__response__.first.to_i
    end

    def __call__
      super do
        catch(PROCESSING_DONE) do
          __blocks__.reverse_each do |block|
            catch(SKIP_RESPONSE) do
              throw(PROCESSING_DONE, instance_exec(*@__response__, &block))
            end
          end
          # We're here if 1) no blocks or 2) all blocks skipped processing
          raise ResponseError.new(@__schema__, @__settings__, @__response__)
        end
      end
    end

    def super!
      throw SKIP_RESPONSE
    end
  end
end
