json.extract! selection, :id, :game_id, :user_id, :correct, :admin, :created_at, :updated_at
json.url selection_url(selection, format: :json)