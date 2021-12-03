<!--
# @title README - mod: api key
-->
# API Key mod
Enable Decko users to perform authorized web requests associated with their account
without a session.

## Cards with codenames

| codename | default name | purpose |
|:--------:|:------------:|:-------:|
| :api_key | *api key | key for authenticating/authorizing API usage |

## Sets with code rules

### {Card::Set::Right::ApiKey [account card]+:api_key}
This is where the API key is stored. By default it is visible to and editable by 
the account holder and to users with the "Help Desk" role.  

#### Events

| event name | when | purpose |
|:---------:|:------:|:-------:|
| generate_api_key | triggered | creates a new, random key |
| validate_api_key | on save | ensures content is comprised of 20+ alphanumerics (only) |

#### Views

| view name | format | purpose |
|:---------:|:------:|:-------:|
| core | HTML | show key to permitted user and provide form to generate new one |
| generate_button | HTML | button for generating new API Key |
| token_link | HTML | links to json view returning a JWT token |
| token | JSON | return a JWT token for rapid authentication |

### {Card::Set::Right::Account [accounted card]+:account}

#### Views

| view name | format | purpose |
|:---------:|:------:|:-------:|
| api_key | HTML | nests api_key card |

## Card::Auth

Extends `Card::Auth.signin_with` to accept `api_key: myapikey`

## API Usage

API users can add the api_key param to query strings or to request headers. Or, for 
faster authentication, they can use their api key to get a JWT token. Card sharks can
provide a link for this token with the `token_link` view (see above). The token can
then be passed via the token param. By default tokens last for two days. This can be
configured in application.rb or environment config files using `config.token_expiry`.
