#!/usr/bin/env ruby

# Taken from https://en.wikipedia.org/wiki/A*_search_algorithm
PathFinder = Struct.new(:dictionary, :start, :finish) do
  def call
    check_words_in_dictionary
    return false if errors.any?

    search_words << start
    while search_words.any? do
      current_word = pop_smallest_search_word
      remember(current_word)

      if current_word == finish
        puts reconstructed_path.join(" -> ")
        return true
      end

      neighbours_of(current_word).each do |neighbour|
        search_words << neighbour
        came_from[neighbour] = current_word
      end
    end

    errors << "Couldn't find a path from #{start} to #{finish}"
    return false
  end

  def errors
    @errors ||= []
  end

  private

  def reconstructed_path
    path = [finish]
    current = finish

    while current != start do
      back = came_from[current]
      path << back
      current = back
    end

    path
  end

  def pop_smallest_search_word
    smallest = search_words.first
    search_words.each do |word|
      if distance(word, finish) < distance(smallest, finish)
        smallest = word
      end
    end
    search_words.delete(smallest)
  end

  def neighbours_of(word)
    neighbours = []

    word.length.times.with_index do |i|
      ('a'..'z').each do |letter|
        first = word[0, i] || ""
        second = word[i+1, word.length] || ""
        candidate = "#{first}#{letter}#{second}"
        if !tried_already[candidate] && dictionary[candidate]
          neighbours << candidate
        end
      end
    end

    neighbours
  end

  def remember(word)
    tried_already[word] = true
  end

  def came_from
    @came_from ||= {}
  end

  def search_words
    @open ||= []
  end

  def tried_already
    @closed ||= {}
  end

  def distance(w1, w2)
    distance = 0

    w1.length.times.with_index do |i|
      if w1[i] != w2[i]
        distance += 1
      end
    end

    distance
  end

  def check_words_in_dictionary
    if !dictionary[start]
      errors << "#{start} not in dicitonary"
    end

    if !dictionary[finish]
      errors << "#{finish} not in dictionary"
    end

    if errors.none? && start.length != finish.length
      errors << "#{start} and #{finish} are different lengths"
    end

    if errors.none? && start == finish
      errors << "same word silly"
    end
  end
end


dictionary = {}
File.open('/usr/share/dict/words').each_line do |w|
  dictionary[w.strip.downcase] = true
end

start, finish = ARGV

finder = PathFinder.new(dictionary, start, finish)
if !finder.call
  puts "Problem? #{finder.errors.join(", ")}"
else
  puts "Yay!"
end
