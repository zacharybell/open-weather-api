const path = require('path');
const ZipPlugin = require('zip-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');

module.exports = {
  entry: './src/index.ts',
  target: 'node',
  output: {
    libraryTarget: 'commonjs',
    path: path.resolve(__dirname, 'dist'),
    filename: 'app.js',
  },
  module: {
    rules: [
      {
        test: /\.ts$/,
        use: 'ts-loader',
        exclude: /node_modules/,
      },
    ],
  },
  plugins: [
    new ZipPlugin({ filename: 'bundle.zip' }),
    new CleanWebpackPlugin(),
  ],
  resolve: {
    extensions: ['.ts', '.js'],
  },
};
