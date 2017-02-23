module LanguageSelect
  FORMATS = {}

  FORMATS[:default] = lambda do |language, code|
    language
  end
end