require "#{Dir.pwd}/exceptions/inconsistency.rb"
require "#{Dir.pwd}/exceptions/sets_not_valid.rb"
module PLI
  class Data
    def sanitize_string(str)
      str.downcase.gsub(' ', '_')
    end
    def mono_dimensional_param(set, param_array, set_name)
      final_param = {}
      formatted_param = {}
      param_array.each{|key, val| formatted_param[sanitize_string(key.to_s)] = val}
      excluded_params = []
      formatted_param.keys.each{|set_element| excluded_params << set_element unless set.include?set_element.to_s}
      raise PLI::Exceptions::Inconsistency.new("#{excluded_params} are not in the #{set_name} set!") unless excluded_params.empty?
      set.each do |set_element|
        value = (formatted_param[set_element] || 0)
        raise TypeError.new("#{value} for #{set_element} is not numeric!") unless value.is_a?Numeric
        final_param[set_element] = value
      end
      final_param
    end
    def bi_dimensional_param(rows_set, cols_set, param_array, rows_name, cols_name, row_is_mandatory = true)
      final_param = {}
      formatted_param = {}
      param_array.each do |key, hash|
        key = key.to_s
        formatted_cols = {}
        hash.each do |sub_key, val|
          sub_key = sub_key.to_s
          raise PLI::Exceptions::Inconsistency.new("#{sub_key} is not in the #{cols_name} set!") unless cols_set.include?sub_key
          formatted_cols[sanitize_string(sub_key)] = val
        end
        raise PLI::Exceptions::Inconsistency.new("#{key} is not in the #{rows_name} set!") unless rows_set.include?key
        formatted_param[sanitize_string(key)] = formatted_cols
      end
      missing_rows = []
      rows_set.each do |row_name|
        if row_is_mandatory and (formatted_param[row_name].nil? or formatted_param[row_name].empty?)
          missing_rows << row_name
        else
          cols_set.each do |col_name|
              final_param[row_name] ||= {}
              formatted_param[row_name] ||= {}
              value = (formatted_param[row_name][col_name] || 0)
              raise TypeError.new("#{value} for [#{row_name},#{col_name}] is not numeric!") unless value.is_a?Numeric
              final_param[row_name][col_name] = value
          end
        end
      end
      raise PLI::Exceptions::Inconsistency.new("#{missing_rows} are missing!") unless missing_rows.empty?
      final_param
    end
  end
end