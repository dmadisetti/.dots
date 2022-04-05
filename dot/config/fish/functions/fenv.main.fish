#The MIT License (MIT)

# Copyright (c) 2015 Derek Willian Stavis

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


function fenv.main
  set program $argv
  set divider (fenv.parse.divider)
  set previous_env (bash -c 'env')

  # Need to ensure that the two calls to env (here and above) have the same
  # nesting level within bash shells so that the SHLVL variable does not differ.
  set program_execution (bash -c "$program && echo && echo '$divider' && env" 2>&1)
  set program_status $status

  if not contains -- "$divider" $program_execution
    printf '%s\n' $program_execution
    return $program_status
  end

  set program_output (fenv.parse.before $program_execution)

  if test $program_status != 0
    printf "%s\n" $program_output
    return $program_status
  end

  set new_env (fenv.parse.after $program_execution)

  fenv.apply (fenv.parse.diff $previous_env $divider $new_env)

  test (count $program_output) -gt 1
    and printf "%s\n" $program_output[1..-2]
    or  printf $program_output
  return $program_status
end
