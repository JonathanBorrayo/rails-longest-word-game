require "open-uri"
require "json"

class GamesController < ApplicationController
  VOWELS = %w[A E I O U].freeze

  def new
    @letters = Array.new(5) { VOWELS.sample }
    @letters += Array.new(5) { (('A'..'Z').to_a - VOWELS).sample }
    @letters.shuffle!
  end

  def score
    @word    = params[:word].to_s.upcase
    @letters = params[:letters].to_s.split
    session[:total] ||= 0

    if !included?(@word, @letters)
      @message = "Sorry, but #{@word} can't be built out of #{@letters.join(', ')}."
    elsif !english_word?(@word)
      @message = "Sorry, but #{@word} does not seem to be a valid English word."
    else
      @points = @word.length
      session[:total] += @points
      @message = "Congratulations! #{@word} is a valid English word! You scored #{@points} points."
    end
  end

  private

  def included?(word, letters)
    word.chars.all? { |char| word.count(char) <= letters.count(char) }
  end

  def english_word?(word)
    response = URI.open("https://dictionary.lewagon.com/#{word.downcase}")
    JSON.parse(response.read)["found"]
  end
end
