module CardExpectations
  def expect_content_of name
    expect(Card.fetch(name).content)
  end
end
