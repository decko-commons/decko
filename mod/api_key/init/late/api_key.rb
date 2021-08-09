# Adds {Card::Auth::ApiKey} methods to Card::Auth class

Card::Auth.extend Card::Auth::ApiKey

CardController.include CardController::ApiKey
