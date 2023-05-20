import { join } from 'path';
import { CleanPlugin } from 'webpack';
const TerserPlugin = require('terser-webpack-plugin');
import BundleDeclarationsWebpackPlugin from 'bundle-declarations-webpack-plugin';
import type { Configuration } from 'webpack';

const entryPoint: string = join(__dirname, 'src', 'index.js');

export default <Configuration>{
  mode: 'production',
  entry: entryPoint,
  target: ['node', 'es5'],
  output: {
    filename: 'index.js',
    path: join(__dirname, 'dist'),
  },
  module: {
    rules: [
      {
        test: /\.ts$/i,
        loader: 'ts-loader',
        exclude: ['/node_modules/'],
      },
    ],
  },
  plugins: [
    new CleanPlugin(),
    new BundleDeclarationsWebpackPlugin({
      entry: entryPoint,
      outFile: 'index.d.ts',
    }),
  ],
  resolve: {
    extensions: ['.ts'],
  },
  performance: {
    hints: 'warning',
    maxAssetSize: 1000000000,
    maxEntrypointSize: 1000000000,
  },
  optimization: {
    minimizer: [new TerserPlugin()],
  },
};
