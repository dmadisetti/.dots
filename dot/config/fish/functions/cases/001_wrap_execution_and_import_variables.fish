it_should 'import variable defined with export' 'fenv export foo=bar; test $foo = bar'
it_should 'import variable defined with source' 'fenv source test/test.sh; test $baz = qux'
it_should 'import variable defined with eval' 'fenv eval "export this=that"; test $this = that'

it_should 'import variables defined with export' 'fenv export foo=bar! bar=foo!; test $foo = bar! -a $bar = foo!'
it_should 'import variables defined with source' 'fenv source test/test.sh; test $baz = qux -a $qux = flob'
it_should 'import variables defined with eval' 'fenv eval "export this=that! that=this!"; test $this = that! -a $that = this!'
