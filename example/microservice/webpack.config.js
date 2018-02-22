
var webpack = require('webpack');
// var webpackDevServer = require('webpack-dev-server');
//var fs = require('fs');
var path = require('path');
var Promise = require("bluebird");

var BUILD_DIR = path.resolve(__dirname, 'build');
var SRC_DIR = path.resolve(__dirname, 'src');

var config = {
  // resolve: {
  //   alias: {
  //     Common: path.resolve(__dirname, '../node/common/src/'),
  //     Drive: path.resolve(__dirname, '../node/drive/src/'),
  //     Edge: path.resolve(__dirname, '../node/edge/src/'),
  //     Beam: path.resolve(__dirname, '../node/beam/src/')
  //   }
  // },
  entry: SRC_DIR + '/index.js',
  output: {
    path: BUILD_DIR,
    filename: 'index.js'
  },
  // devServer: {
  //   contentBase: BUILD_DIR,
  //   hot: true,
  //   inline: true,
  //   host: '127.0.0.1',
  //   port: 8080
  // },
  plugins: [
    new webpack.optimize.ModuleConcatenationPlugin(),
    new webpack.optimize.UglifyJsPlugin({
        compress: {
            warnings: false,
            screw_ie8: true,
            conditionals: true,
            unused: true,
            comparisons: true,
            sequences: true,
            dead_code: true,
            evaluate: true,
            join_vars: true,
            if_return: true
        },
        output: {
            comments: false
        }

        //sourceMap: false,
        //mangle: false
    })
  ],
  module: {
    rules: [
      {
        enforce: "pre",
        test: /\.js$/,
        exclude: /node_modules/,
        loader: "eslint-loader",
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        query: {
            // plugins: ['transform-decorators-legacy',
            //           'transform-runtime',
            //           'transform-object-rest-spread',
            //           'transform-react-constant-elements',
            //           'transform-class-properties'],
            //           stage-0 can be upgrade to latest
            // presets: [['es2015', {modules: false}], 'stage-0', 'react']
            presets: ['es2015', 'stage-0']
        },
        loader: "babel-loader",
      },
    ]
  }
};

module.exports = config;
