jQuery = require 'jquery'
Bar = require './bar'
Foo = require './foo'

bar = new Bar()
foo = new Foo()

(($) ->
    console.log bar.firstName + foo.lastName
) jQuery