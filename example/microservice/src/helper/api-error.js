export default class ApiError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code || 500;
  }
}
