
def count_stones(num, depth, cache, lengths)
  return 1 if depth == 0
  return cache[num][depth] if cache[num] &&  cache[num][depth]
  if lengths[num].nil?
    lengths[num] = num_length(num)
  end
  queue = []
  if num == 0
   queue << 1
  elsif lengths[num].even?
    f_half, s_half = split_num(num, lengths[num])
    queue << f_half
    queue << s_half
  else 
    queue << num * 2024
  end

  count = 0
  queue.each { |num|
    count += count_stones(num, depth - 1, cache, lengths)
  }

  cache[num] ||= {}
  cache[num][depth] = count
  count
end

def num_length(num)
  if num < 10
    return 1
  end
  count = 0
  n = num
  while n > 0
    n /= 10
    count += 1
  end
  count
end

def split_num(num, length)
  return num / 10**(length/2), num % 10**(length/2)
end

def main(filename, iterations)
  file = File.open(filename)
  contents = file.read.split(" ")
  file.close

  cache = {}
  lengths = {}

  result = 0
  contents.each do | value |
    num = value.to_i
    count = count_stones(num, iterations, cache, lengths)
    cache[num][iterations] = count
    result += count
  end
  result
end

puts main "input.txt", 75