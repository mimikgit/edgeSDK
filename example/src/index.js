import Router from 'router';

class ApiError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code || 500;
  }
}

const app = Router({
  mergeParams: true,
});

function toJson(obj) {
  return JSON.stringify(obj, null, 2);
}

mimikModule.exports = (context, req, res) => {
  req.mimikContext = context;
  res.writeError = (apiError) => {
    res.statusCode = apiError.code;
    const json = JSON.stringify({
      code: apiError.code,
      message: apiError.message,
    });
    res.end(json);
  };

  app(req, res, (e) => {
    const err = (e && new ApiError(400, e.message)) ||
      new ApiError(404, 'not found');
    res.writeError(err);
  });
};

app.get('/hello', (req, res) => {
  const json = toJson({
    JSONMessage: 'Hello wORLD!!!',
  });
  res.end(json);
});
