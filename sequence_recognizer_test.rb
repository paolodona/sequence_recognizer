#!/usr/bin/env ruby
require 'test/unit'
require 'sequence_recognizer'
require 'yaml'
require 'benchmark'

class SequenceRecognizerTest < Test::Unit::TestCase
  include SequenceRecognizer
  
  def test_extract_sequences_one_digit
    assert_equal [%w{1 2 3}], extract_sequences_from(%w{1 2 3 5}, 1) 
    assert_equal [%w{1 2 3},%w{5 6 7}], extract_sequences_from(%w{1 2 3 5 6 7 9}, 1) 
    assert_equal [], extract_sequences_from(%w{1 3 5 7 9}, 1) 
  end 
  
  def test_extract_sequences_two_digits
    assert_equal [%w{11 12 13}], extract_sequences_from(%w{11 12 13 15}, 2) 
    assert_equal [%w{11 21 31}], extract_sequences_from(%w{11 33 21 31}, 2) 
    assert_equal [%w{11 21 31},%w{15 16 17}], extract_sequences_from(%w{11 21 31 15 16 17 99}, 2) 
    assert_equal [%w{11 21 31 41 51}], extract_sequences_from(%w{11 21 31 41 51 71 99}, 2) 
  end 
  
  def test_extract_sequences_three_digits
    assert_equal [%w{111 121 131}], extract_sequences_from(%w{111 121 131 151}, 3) 
  end 
  
  def test_extract_sequences_five_digits
    assert_equal [%w{81702 81802 81902}], extract_sequences_from(%w{81702 81802 81902 82702 82802}, 5) 
  end 


  def test_performance
    available_shortcodes = YAML.load_file('available.yml')
    expected_sequences = YAML.load_file('sequences.yml')
    sequences = []
    puts Benchmark.measure { 
      sequences = extract_sequences_from(available_shortcodes)
    }
    
    # test the result
    assert_equal expected_sequences.size, sequences.size
    expected_sequences.each do |sequence|
      assert sequences.include?(sequence)
    end 
  end
end
