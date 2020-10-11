class Card
  # override default methods to handle DelayedJob needs
  module DelayedJob
    def delaying! on=true
      super
      Delayed::Worker.delay_jobs = Card.config.delaying
    end
  end
end
