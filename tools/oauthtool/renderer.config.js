const webpackRenderer = require('electron-webpack/webpack.renderer.config.js')

module.exports = env => {
  return new Promise((resolve, reject) => {

    /* get provided config */
    webpackRenderer(env).then(rendererConfig => {

      /* add `raw-loader` */
      rendererConfig.module.rules.push({
        test: /\.css$/,
        use: [
          {
            loader: 'css-loader',
            options: {
              modules: true,
              sourceMap: true,
              localIdentName: '[path][name]__[local]--[hash:base64:5]'
            }
          }
        ]
      })

      /* return modified config to webpack */
      resolve(rendererConfig)
    })
  })
}