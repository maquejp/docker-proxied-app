export const testAccounts = {
  validAccount: {
    givenname: 'John',
    lastname: 'Doe',
    unikid: 'john.doe',
    email: 'john.doe@example.com',
  },
  
  adminAccount: {
    givenname: 'Admin',
    lastname: 'User',
    unikid: 'admin',
    email: 'admin@example.com',
  },
  
  invalidAccount: {
    givenname: '',
    lastname: 'Invalid',
    unikid: 'invalid',
    email: 'invalid-email',
  },
};

export const testFeatures = {
  readOnlyFeature: {
    feature_code: 'READ_ONLY',
    feature_name: 'Read Only Access',
  },
  
  fullAccessFeature: {
    feature_code: 'FULL_ACCESS',
    feature_name: 'Full Access',
  },
  
  adminFeature: {
    feature_code: 'ADMIN',
    feature_name: 'Administrator Access',
  },
};

export const testCredentials = {
  validUser: {
    username: 'john.doe',
    password: 'password123',
  },
  
  adminUser: {
    username: 'admin',
    password: 'admin123',
  },
  
  invalidUser: {
    username: 'invalid',
    password: 'wrong-password',
  },
};

export const testSessions = {
  validSession: {
    token: 'mock-jwt-token-here',
    expiresIn: '10h',
  },
  
  expiredSession: {
    token: 'expired-jwt-token',
    expiresIn: '0h',
  },
};