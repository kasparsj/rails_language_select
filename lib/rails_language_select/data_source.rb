module RailsLanguageSelect
  DATA_SOURCE = {}

  DATA_SOURCE[:default] = lambda do |code_or_name = nil|
    languages = I18nData.languages(I18n.locale.to_s)
    if code_or_name.nil?
      languages.keys
    else
      if (language = languages[code_or_name.to_s.upcase])
        code = code_or_name
      elsif (code = I18nData.language_code(code_or_name))
        language = languages[code]
      end
      return language, code
    end
  end
end