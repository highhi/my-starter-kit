Bar = require './bar'

class Foo
    constructor : ->
        @lastName = '和弥'
        @bar = new Bar()

    say : ->
        console.log @bar.firstName + @lastName

module.exports = Foo