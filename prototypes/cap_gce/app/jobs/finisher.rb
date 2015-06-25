class Finisher
  @queue = :finish

  def self.perform(id)
    puts 'Working on finishing task:'
    todo = Todo.find(id)
    puts todo.name
    sleep(30)
    todo.finished = true
    todo.save
    puts 'finished task'
  end
end
