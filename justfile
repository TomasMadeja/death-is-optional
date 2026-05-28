set script-interpreter := ['uv', 'run', '--script']

[script]
update:
  from subprocess import run as _run
  from pathlib import Path
  from shutil import rmtree, copytree

  def onerror(func, path, exc_info):
      import stat
      import os
      # Is the error an access error?
      if os.path.isdir(path):
          print("Removed dir")
          os.chmod(path, stat.S_IWRITE)
          os.rmdir(path)
      elif os.path.isfile(path):
          print("Removed file")
          os.chmod(path, stat.S_IWRITE)
          os.unlink(path)
      else:
          raise

  run = lambda *args, **kwargs: _run(*args, check=True, **kwargs)

  source = Path(r"C:\Users\adeom\My Drive\Obsidian\Death is Optional")
  wtree = Path(r"{{justfile_directory()}}") / "worktree" / "pages"
  quartz = wtree / "quartz"

  if wtree.is_dir():
    try:
        run(
            "git worktree remove --force pages",
            cwd=Path(r"{{justfile_directory()}}"),
            input="",
        )
    except Exception:
        pass
    if wtree.is_dir():
      rmtree(wtree, onerror=onerror)

  run(
    "git worktree add --track -B pages worktree/pages origin/pages",
    cwd=Path(r"{{justfile_directory()}}"),
  )
  run(
    "git clone https://github.com/jackyzha0/quartz.git",
    cwd=wtree,
  )
  run(
    "npm i",
    cwd=quartz,
    shell=True,
  )
  run(
    'npx quartz create -t obsidian -s copy -b "adeom.codeberg.page/death-is-optional/"',
    input=b"\n",
    cwd=quartz,
    shell=True,
  )
  copytree(source / "Game Rules", quartz / "content" / "Game Rules")
  run(
    "npx quartz plugin install --from-config",
    cwd=quartz,
    shell=True,
  )
  run(
    f'npx quartz build --output "{wtree}"',
    cwd=quartz,
    shell=True,
  )
  rmtree(quartz, onerror=onerror)
  (wtree / "README.md").unlink(missing_ok=True)
  (wtree / "LICENSE").unlink(missing_ok=True)
  (wtree / "justfile").unlink(missing_ok=True)
  run(
    "git add -A",
    cwd=wtree,
  )
  run(
    'git commit -S -m "updating page"',
    cwd=wtree,
  )
  run(
    'git push --force',
    cwd=wtree,
  )
