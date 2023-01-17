function it_should
  switch "$argv[1]"
  case '-s' '--single'
  case '*'
    if not test (count $argv) -ge 2
      echo 'usage: it_should "do something" "commands"'
      echo '       it_should -s "commands"'
      return 1
    end
    set duty $argv[1]
  end

  set commands $argv[2..-1]
  set -l progress (set_color yellow)TEST(set_color normal)

  set -q duty; and printf '\n  x> It should %s: ' $duty
  isatty stdout; and printf "$progress"

  # Run in a separate shell to ensure that test variables are cleared after every test
  if fish -c "set fish_function_path -p ./functions; $commands" >/dev/null 2>/dev/null
    set_color green
    isatty stdout; and printf '\b\b\b\b'
    printf 'PASS'
    set_color normal
    set -g _tests_results (math $_tests_results[1] + 1) $_tests_results[2]
    return 0
  else
    set_color red
    isatty stdout; and printf '\b\b\b\b'
    printf 'FAIL'
    set_color normal
    set -g _tests_results $_tests_results[1] (math $_tests_results[2] + 1)
    return 1
  end
end

printf 'Running test suite...\n'

set -g _tests_results 0 0
for test in test/cases/*
  printf 'x> It should %s: ' (basename $test | sed 's/^[0-9]*_//;s/_/ /g;s/\.fish//g')
  source $test
  echo
end

if test $_tests_results[2] -gt 0
  set_color red
  printf 'Fail! %d passed, %d failed\n' $_tests_results[1] $_tests_results[2]
  set_color normal
  exit 1
else
  set_color green
  printf 'Success! All %d passed\n' $_tests_results[1]
  set_color normal
  exit 0
end
