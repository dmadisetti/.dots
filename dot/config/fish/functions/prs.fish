function prs
  set -l gh (+ gh -- which gh)
  for patched in ($gh pr list --author "" --json url -q "(.[] | .url)");
    git apply (curl -sL $patched.diff | psub);
  end
end
