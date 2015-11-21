post '/feedbacks' do
  validate_access_token
  feedback_params = params.deep_symbolize_keys.slice(:contact, :content)
  feedback_params[:contact] ||= @user.username
  feedback_params[:user_id] = @user.id
  feedback = Feedback.new(feedback_params)
  halt 400, json(errors: feedback.errors) unless feedback.save
  status 201
  json(feedback)
end
