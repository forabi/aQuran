module.exports = (config) ->
  config.set
    frameworks: [ 'jasmine' ]
    browsers: [ 'Chrome' ]

    plugins: [
        'karma-coffee-preprocessor'
        'karma-chrome-launcher'
        'karma-jasmine'
    ]

    preprocessors:
      '**/*.coffee': ['coffee']

    coffeePreprocessor:
      # options passed to the coffee compiler
      options:
        bare: true,
        sourceMap: false

      # transforming the filenames
      transformPath: (path) -> path.replace /\.coffee$/, '.js'