it_should "use global scope even if universal already exists" \
  'set -Ux __test a; fenv export __test=b; set -qgx __test; and test $__test = b'
set -eU __test
it_should "not change scope if variable equals and exported" \
  'set -Ux __test a; fenv export __test=a; not set -qgx __test; and test $__test = a'
set -eU __test
it_should "export global variable when same universal variable already defined" \
  'set -U __test a; fenv export __test=a; set -qgx __test; and test $__test = a'
set -eU __test
it_should "export variable when same variable already defined" \
  'set -g test a; fenv export test=a; set -qgx test; and test $test = a'
it_should "fail and not change any variables in case of error" \
  'fenv "export test=a; false"; test $status -eq 1; and not set -q test'
it_should "propagate exit code" 'fenv exit 10; test $status -eq 10'
it_should "return stdout and define variables" \
  'set out (fenv echo test\; export test=a); test $out = test; and test $test = a'
it_should "print errors to stderr" 'set -l stderr (fenv \'echo error >&2\' 2>&1); test $stderr = error'
it_should "return both stdout and stderr" \
  'set -l both (fenv \'echo test; echo error >&2; export test=a\' &| sort | string collect);' \
  'test $both = error\ntest; and test $test = a'
it_should "work with variables used by main function" \
  'fenv export env_var=a\; export kv=a; set -qgx env_var; and set -qgx kv; and test $env_var = a -a $kv = a'
