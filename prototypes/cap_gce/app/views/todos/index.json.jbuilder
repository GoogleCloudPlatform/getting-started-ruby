json.array!(@todos) do |todo|
  json.extract! todo, :id, :name, :finished
  json.url todo_url(todo, format: :json)
end
