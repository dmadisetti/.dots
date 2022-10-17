function prs
  set -l gh (+ gh -- which gh)
  for patched in ($gh pr list --author "" --json url -q "(.[] | .url)");
    git apply --3way (curl -sL $patched.diff | psub);
  end
end
