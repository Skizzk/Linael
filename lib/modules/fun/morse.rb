
linael :morse do
  help [
    t.morse.help.description,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.morse.help.function.morse
  ]

  on :cmd, :morse, /^!morse\s/ do |msg, options|
    answer(msg, options.all.split(//).map{ |c| MorseHash[c] }.join(" "))
  end

  # Morse alphabet
  MorseHash = { "a" => "·−",
                "b" => "−···",
                "c" => "−·−·",
                "d" => "−··",
                "e" => "·",
                "f" => "··−·",
                "g" => "−−·",
                "h" => "····",
                "i" => "··",
                "j" => "·−−−",
                "k" => "−·−",
                "l" => "·−··",
                "m" => "−−",
                "n" => "−·",
                "o" => "−−−",
                "p" => "·−−·",
                "q" => "−−·−",
                "r" => "·−·",
                "s" => "···",
                "t" => "−",
                "u" => "··−",
                "v" => "···−",
                "w" => "·−−",
                "x" => "−··−",
                "y" => "−·−−",
                "z" => "−−··",
                "é" => "··−··",
                "è" => "·−··−",
                "à" => "·−−·−",
                " " => " ",
                "ç" => "−·−··",
                "." => "·−·−·−",
                "," => "−−··−−",
                "?" => "··−−··",
                ";" => "−·−·−·",
                ":" => "−−−···",
                "!" => "−·−·−−",
                ")" => "−·−−·−",
                "(" => "−·−−·",
                "0" => "−−−−−",
                "1" => "·−−−−",
                "2" => "··−−−",
                "3" => "···−−",
                "4" => "····−",
                "5" => "·····",
                "6" => "−····",
                "7" => "−−···",
                "8" => "−−−··",
                "9" => "−−−−·" }.freeze
end
