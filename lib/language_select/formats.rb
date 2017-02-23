module LanguageSelect
  FORMATS = {}

  FORMATS[:default] = lambda do |language|
    language.english_name
  end
  FORMATS[:french_name] = lambda do |language|
    language.french_name
  end
end