module CardExpectations
  def expect_content_of name
    expect(Card.fetch(name))
  end
end