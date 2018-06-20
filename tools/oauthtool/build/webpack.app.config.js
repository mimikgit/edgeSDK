const path = require('path');
const merge = require('webpack-merge');
const base = require('./webpack.base.config');

module.exports = env => merge(base(env), {
  entry: {
    background: './src/main/index.js',
    app: './src/renderer/index.js',
  },
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, '../app'),
  },
});
