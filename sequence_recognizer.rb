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
      recompose(hash)
    end 
    
    # '1234678' => ['1234','678']
    def multiplex_sequences_from(string)
      @cache ||= {}
      return @cache[string] if @cache[string]
      sequences_found = []
      ordered_sequences.each do |regexp|
	if string =~ regexp
	  sequences_found << $~[0] 
	end
      end
      # remove subsets
      redundant = []
      sequences_found.each do |s1|
        sequences_found.each do |s2|
          redundant << s2 if s1 != s2 && !s1.index(s2).nil?
        end
      end
      sequences_found.delete_if {|sequence| redundant.include? sequence}
      @cache[string] = sequences_found
      return sequences_found
    end 

    # [81602, 81702, 81802, 81902] #=> {'81x82' => "6789"}
    def decompose(shortcodes, n = 5)
      shortcodes.map! {|s| s.to_s}
      result = {} 
      n.times do |index|
        shortcodes.each do |shortcode|
          digit = shortcode[index].chr
          key = shortcode.dup
          key[index] = 'x' 
          result[key] ||= ''
          result[key] << digit
        end 
      end
      result
    end 
 
    # {'66x77' => ['123', 678]} #=> [['66177', '66277', '66377'], ['66677', 66777, 66877]]
    def recompose(hash)
      results = [] 
      hash.each do |key, sequences|
	results += sequences.map {|seq| seq.unpack('a'*seq.size).map {|digit| key.tr('x',digit)}}
      end 
      results
    end 

    private 

    def ordered_sequences 
      return @ordered_sequences if @ordered_sequences 
      @ordered_sequences = [
	      /0123456789/,
	      /012345678/,
	      /123456789/,
	      /01234567/,
	      /12345678/,
	      /23456789/,
	      /0123456/,
	      /1234567/,
	      /2345678/,
	      /3456789/,
	      /012345/,
	      /123456/,
	      /234567/,
	      /345678/,
	      /456789/,
	      /01234/,
	      /12345/,
	      /23456/,
	      /34567/,
	      /45678/,
	      /56789/,
	      /0123/,
	      /1234/,
	      /2345/,
	      /3456/,
	      /4567/,
	      /5678/,
	      /6789/,
	      /012/,
	      /123/,
	      /234/,
	      /345/,
	      /456/,
	      /567/,
	      /678/,
	      /789/]
      return @ordered_sequences
    end 
  end 
end 
