shared_examples 'renders 200 http status code' do
  it "renders 200 http status code" do
    subject
    expect(response).to have_http_status(200)
  end
end

shared_examples 'renders 201 http status code' do
  it "renders 201 http status code" do
    subject
    expect(response).to have_http_status(201)
  end
end

shared_examples 'renders 204 http status code' do
  it "renders 204 http status code" do
    subject
    expect(response).to have_http_status(204)
  end
end

shared_examples 'renders 422 http status code' do
  it "renders 422 http status code" do
    subject
    expect(response).to have_http_status(422)
  end
end

shared_examples 'renders 404 http status code' do
  it "renders 404 http status code" do
    subject
    expect(response).to have_http_status(404)
  end
end

shared_examples 'renders 302 http status code' do
  it 'renders 302 http status code' do
    subject
    expect(response).to have_http_status(302)
  end
end
