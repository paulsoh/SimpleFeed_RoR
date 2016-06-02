shared_examples 'renders template' do |name|
  it "renders #{name} template" do
    subject
    expect(response).to render_template(name)
  end
end
