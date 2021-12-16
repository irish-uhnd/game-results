const {merge} = require('webpack-merge')
const baseConfig = require('./webpack.config.base.js')

module.exports = merge(baseConfig, {
  mode: 'development',
  devServer: {
    port: 9988,
  },
  devtool: 'source-map',
  // workaround for webpack 5 bug with browserlist config
  // https://github.com/pmmmwh/react-refresh-webpack-plugin/issues/235
  target: 'web',
})
