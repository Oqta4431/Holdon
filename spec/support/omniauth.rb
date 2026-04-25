OmniAuth.config.test_mode = true

OmniAuth.config.mock_auth[:line] = OmniAuth::AuthHash.new({
  provider: 'line',
  uid: '000000',
  info: { email: 'test@example.com', name: 'test' },
  credentials: { token: 'line_auth_test' }
})
