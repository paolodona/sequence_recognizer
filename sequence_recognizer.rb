module SequenceRecognizer
  def self.included(base)
    base.extend(Methods)
    base.class_eval do
      include Methods
    end 
  end 
  
  module Methods 
    def extract_sequences_from(array, n = 5)
      hash = decompose(array, n)
      hash.delete_if {|key, values| values.size < 3 } # remove if there aren't enough candidates 
      
      # extract the sequences form the candidates {'81x02' => ['678', '689', '6789']}
      hash.each do |key, values|
        hash[key] = multiplex_sequences_from(values)
      end
      # remove if there are no sequences for a key
      hash.delete_if {|key, sequences| sequences.empty? } 
     
      # reconstruct the shortcodes
      result = []
      hash.each do |key, sequences|
        sequences.each do |sequence|
          result << recompose( key => sequence )
       end 
      end
      result
    end 
    
    # '1234678' => ['1234','678']
    def multiplex_sequences_from(string)
      @cache ||= {}
      return @cache[string] if @cache[string]
      regexps = ordered_sequences.dup
      sequences_found = []
      regexps.each do |regexp|
	if string =~ regexp
	  sequences_found << $~[0] 
          remove_recursively(regexp, regexps)	
	end
      end
      @cache[string] = sequences_found
      return sequences_found
    end 

    def remove_recursively(regexp, regexps) 
      regexps.delete(regexp)
      dependent = hashed_sequences[regexp]
      dependent.each {|r| remove_recursively(r, regexps)} 
    end
    
    # [81602, 81702, 81802, 81902] #=> {'81x82' => "6789"}
    def decompose(shortcodes, n = 5)
      shortcodes.map! {|s| s.to_s}
      result = {} 
      n.times do |index|
        shortcodes.each do |shortcode|
          digit = shortcode[index].chr
          key = shortcode.to_s.dup
          key[index] = 'x' 
          result[key] ||= ''
          result[key] << digit
        end 
      end
      result
    end 
 
    # {'66x77' => '123'} #=> ['66177', '66277', '66377']
    def recompose(hash)
      result = [] 
      hash.each do |key, sequence|
	sequence.each_byte do |digit|
          result <<  key.sub('x', digit.chr)	
	end
      end 
      result.sort
    end 

    private 

    def hashed_sequences
      return @hashed_sequences if @hashed_sequences 
      @hashed_sequences = {
        /0123456789/ => [ /012345678/, /123456789/ ],
        /012345678/  => [ /01234567/, /12345678/ ],
        /123456789/  => [ /12345678/, /23456789/ ],
        /01234567/   => [ /0123456/, /1234567/ ],
        /12345678/   => [ /1234567/, /2345678/ ],
        /23456789/   => [ /2345678/, /3456789/ ],
        /0123456/    => [ /012345/, /123456/ ],
        /1234567/    => [ /123456/, /234567/ ],
        /2345678/    => [ /234567/, /345678/ ],
        /3456789/    => [ /345678/, /456789/ ],
        /012345/     => [ /01234/, /12345/ ],
        /123456/     => [ /12345/, /23456/ ],
        /234567/     => [ /23456/, /34567/ ],
        /345678/     => [ /34567/, /45678/ ],
        /456789/     => [ /45678/, /56789/ ],
        /01234/      => [ /0123/, /1234/ ],
        /12345/      => [ /1234/, /2345/ ],
        /23456/      => [ /2345/, /3456/ ],
        /34567/      => [ /3456/, /4567/ ],
        /45678/      => [ /4567/, /5678/ ],
        /56789/      => [ /5678/, /6789/ ],
        /0123/       => [ /012/, /123/ ],
        /1234/       => [ /123/, /234/ ],
        /2345/       => [ /234/, /345/ ],
        /3456/       => [ /345/, /456/ ],
        /4567/       => [ /456/, /567/ ],
        /5678/       => [ /567/, /678/ ],
        /6789/       => [ /678/, /789/ ],
        /012/        => [],
        /123/        => [],
        /234/        => [],
        /345/        => [],
        /456/        => [],
        /567/        => [],
        /678/        => [],
        /789/        => []
      }
      return @hashed_sequences
    end

    def ordered_sequences 
      return @ordered_sequences if @ordered_sequences 
      @ordered_sequences = [/0123456789/,/012345678/,/123456789/,/01234567/,/12345678/,/23456789/,/0123456/,/1234567/,/2345678/,
	/3456789/,/012345/,/123456/,/234567/,/345678/,/456789/,/01234/,/12345/,/23456/,/34567/,/45678/,/56789/,/0123/,/1234/,
	/2345/,/3456/,/4567/,/5678/,/6789/,/012/,/123/,/234/,/345/,/456/,/567/,/678/,/789/]
      return @ordered_sequences
    end 
  end 
end 
