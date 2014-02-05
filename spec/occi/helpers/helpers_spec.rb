module Occi
  module Helpers

    def hash_or_nil_helper(json_string)
      return nil if json_string.blank?
      hash = JSON.parse(json_string)
      hash.inject({}){ |memo,(k,v)| memo[k.to_sym] = v; memo }
    end

  end
end
