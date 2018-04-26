export function extractToken(authorization) {
  return (authorization && authorization.length && authorization.split(' ')[1]);
}

export function addAuthorizationHeader(token) {
  return `Bearer ${token}`;
}
