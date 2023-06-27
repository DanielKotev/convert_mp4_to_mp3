resource "aws_cognito_user_pool" "myPool" {
  name = "user-pool"

  # Sign-in options
  username_attributes = ["email"]

  # MFA enforcement
  mfa_configuration = "OFF"

  # Additional required attributes
  schema {
    name                = "phone_number"
    attribute_data_type = "String"
    required            = true
  }


  # Email provider
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Hosted authentication pages
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  auto_verified_attributes = ["email"]
}

# Cognito domain
resource "aws_cognito_user_pool_domain" "myPoolDomain" {
  domain       = "daguaniko"
  user_pool_id = aws_cognito_user_pool.myPool.id
}

resource "aws_cognito_user_pool_client" "myApp" {
  name         = "my-app"
  user_pool_id = aws_cognito_user_pool.myPool.id

  # App client settings
  generate_secret                      = false
  explicit_auth_flows                  = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_CUSTOM_AUTH"]
  prevent_user_existence_errors        = "LEGACY"
  refresh_token_validity               = 30
  allowed_oauth_flows                  = ["code"]
  callback_urls                        = ["https://daguaniko.com"]
  allowed_oauth_scopes                 = ["openid", "email", "phone"]
  supported_identity_providers         = ["COGNITO"]
  allowed_oauth_flows_user_pool_client = true
}

data "aws_cognito_user_pool_client" "clientidname" {
  user_pool_id = aws_cognito_user_pool.myPool.id
  client_id    = aws_cognito_user_pool_client.myApp.id
}

output "clientidnameOutput" {
  value = data.aws_cognito_user_pool_client.clientidname.client_id
}

output "userPoolId" {
  value = aws_cognito_user_pool.myPool.id
}

output "clientId" {
  value = aws_cognito_user_pool_client.myApp.id
}
