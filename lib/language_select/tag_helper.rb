module LanguageSelect
  class LanguageNotFoundError < StandardError;end
  module TagHelper
    def language_option_tags
      option_tags_options = {
          :selected => @options.fetch(:selected) { value(@object) },
          :disabled => @options[:disabled]
      }

      if priority_languages.present?
        priority_languages_options = language_options_for(priority_languages, false)

        option_tags = options_for_select(priority_languages_options, option_tags_options)
        option_tags += html_safe_newline + options_for_select([priority_languages_divider], disabled: priority_languages_divider)

        option_tags_options[:selected] = [option_tags_options[:selected]] unless option_tags_options[:selected].kind_of?(Array)
        option_tags_options[:selected].delete_if{|selected| priority_languages_options.map(&:second).include?(selected)}

        option_tags += html_safe_newline + options_for_select(language_options, option_tags_options)
      else
        option_tags = options_for_select(language_options, option_tags_options)
      end
    end

    private
    def locale
      @options[:locale]
    end

    def priority_languages
      @options[:priority_languages]
    end

    def priority_languages_divider
      @options[:priority_languages_divider] || "-"*15
    end

    def only_language_codes
      @options[:only]
    end

    def except_language_codes
      @options[:except]
    end

    def format
      @options[:format] || :default
    end

    def language_options
      language_options_for(all_language_codes, true)
    end

    def all_language_codes
      codes = ISO_639::ISO_639_1.map{|lang| lang[2]}

      if only_language_codes.present?
        codes & only_language_codes
      elsif except_language_codes.present?
        codes - except_language_codes
      else
        codes
      end
    end

    def language_options_for(language_codes, sorted=true)
      language_list = language_codes.map do |code_or_name|
        if language = ISO_639.find_by_code(code_or_name)
          code = code_or_name
        elsif language = ISO_639.find_by_english_name(code_or_name) || language = ISO_639.find_by_french_name(code_or_name)
          code = language.alpha2
        end

        unless language.present?
          msg = "Could not find Language with string '#{code_or_name}'"
          raise LanguageNotFoundError.new(msg)
        end

        formatted_country = ::LanguageSelect::FORMATS[format].call(language)

        if formatted_country.is_a?(Array)
          formatted_country
        else
          [formatted_country, code]
        end
      end

      if sorted
        language_list.sort_alphabetical
      else
        language_list
      end
    end

    def html_safe_newline
      "\n".html_safe
    end
  end
end
