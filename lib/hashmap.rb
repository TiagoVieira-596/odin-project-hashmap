require_relative 'node'
require 'pry-byebug'
class HashMap
  attr_accessor :buckets

  def initialize(capacity = 16)
    @load_factor = 0.75
    @capacity = capacity
    @buckets = Array.new(@capacity) { Node.new }
  end

  def hash(key)
    hash_code = 0
    prime_number = 31

    key.each_char { |char| hash_code = prime_number * hash_code + char.ord }

    hash_code
  end

  def set(key, value)
    resize(@capacity * 2) if @load_factor * @capacity <= length && !has?(key)

    # either append a new node for the bucket or set a new value to an existing node
    bucket_address = hash(key) % @capacity
    raise IndexError if bucket_address.negative? || bucket_address >= @buckets.length

    bucket = @buckets[bucket_address]
    until bucket.next_node.nil?
      if bucket.key == key
        bucket.value = value
        return
      end
      bucket = bucket.next_node
    end
    if bucket.key.nil? || bucket.key == key
      bucket.key = key
      bucket.value = value
      return
    end
    bucket.next_node = Node.new(key, value)
  end

  def get(key)
    bucket_address = hash(key) % @capacity
    bucket = @buckets[bucket_address]
    until bucket.nil?
      return bucket.value if bucket.key == key

      bucket = bucket.next_node
    end
    nil
  end

  def has?(key)
    key_found = false
    bucket_address = hash(key) % @capacity
    bucket = @buckets[bucket_address]
    until bucket.nil? || key_found
      key_found = true if bucket.key == key

      bucket = bucket.next_node
    end
    key_found
  end

  def remove(key)
    bucket_address = hash(key) % @capacity
    bucket = @buckets[bucket_address]
    previous_node = bucket unless bucket.next_node.nil?
    # set the pointer from the previous node to the next node and delete the current node
    until bucket.nil?
      if bucket.key == key
        if previous_node.nil?
          @buckets[bucket_address] = Node.new
        else
          previous_node.next_node = bucket.next_node
        end
        value = bucket.value
        bucket = nil
        return value
      end
      previous_node = bucket
      bucket = bucket.next_node
    end
    nil
  end

  def length
    length = 0
    @buckets.each do |bucket|
      until bucket.nil?
        length += 1 unless bucket.key.nil?
        bucket = bucket.next_node
      end
    end
    length
  end

  def clear
    @buckets.each do |bucket|
      bucket.key = nil
      bucket.next_node = nil
      bucket.value = nil
    end
  end

  def keys
    key_array = []
    @buckets.each do |bucket|
      until bucket.nil?
        key_array << bucket.key unless bucket.key.nil?
        bucket = bucket.next_node
      end
    end
    key_array
  end

  def values
    value_array = []
    @buckets.each do |bucket|
      until bucket.nil?
        value_array << bucket.value unless bucket.key.nil?
        bucket = bucket.next_node
      end
    end
    value_array
  end

  def entries
    entry_array = []
    @buckets.each do |bucket|
      until bucket.nil?
        key_value_pair = [bucket.key, bucket.value] unless bucket.key.nil?
        entry_array << key_value_pair unless bucket.key.nil?
        bucket = bucket.next_node
      end
    end
    entry_array
  end

  def resize(new_capacity)
    temp_hash = []
    @buckets.each do |temp_bucket|
      until temp_bucket.nil?
        temp_hash << [temp_bucket.key, temp_bucket.value]
        temp_bucket = temp_bucket.next_node
      end
    end
    (Array.new(@capacity) { Node.new }).each { |new_bucket| @buckets << new_bucket }
    @capacity = new_capacity
    clear
    temp_hash.each do |key_value_pair|
      set(key_value_pair[0], key_value_pair[1]) unless key_value_pair[0].nil?
    end
  end

  def to_s
    hash_string = ''
    @buckets.each_with_index do |bucket, index|
      hash_string << "bucket #{index}: "
      until bucket.nil?
        unless bucket.nil?
          hash_string << "[#{bucket.key}: #{bucket.value}] -> " unless bucket.key.nil?
          bucket = bucket.next_node
        end
      end
      hash_string << 'nil'
      hash_string << "\n"
    end
    hash_string
  end
end
