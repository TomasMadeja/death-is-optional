set script-interpreter := ['uv', 'run', '--script']

[script]
update:
  from subprocess import run as _run
  from pathlib import Path
  from shutil import rmtree, copytree, copyfile

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

  source = Path(r"~\My Drive\Obsidian\Death is Optional").expanduser()
  wtree = Path(r"{{justfile_directory()}}") / "worktree" / "pages"
  quartz = Path(r"{{justfile_directory()}}") / "worktree" / "quartz"

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
  if quartz.is_dir():
    rmtree(quartz, onerror=onerror)
  run(
      "git worktree prune",
      cwd=Path(r"{{justfile_directory()}}"),
      input="",
  )

  run(
    "git worktree add worktree/pages pages",
    cwd=Path(r"{{justfile_directory()}}"),
  )
  for child in wtree.iterdir():
      if child.name.startswith("."):
         continue
      if child.is_file():
         child.unlink()
      if child.is_dir():
         rmtree(child, onerror=onerror)
  run(
    "git worktree list",
    cwd=Path(r"{{justfile_directory()}}"),
  )
  run(
    "git clone https://github.com/jackyzha0/quartz.git",
    cwd=quartz.parent,
  )
  run(
    "npm i",
    cwd=quartz,
    shell=True,
  )
  
  # run(
  #   'npx quartz create --template obsidian --strategy new --baseUrl "dio.adeom.dev"',
  #   input=b"\n",
  #   cwd=quartz,
  #   shell=True,
  # )
  copyfile(Path(r"{{justfile_directory()}}") / "quartz.config.yaml", quartz / "quartz.config.yaml")
  copytree(source / "Game Rules", quartz / "content" / "Game Rules")
  copyfile(source / "index.md", quartz / "content" / "index.md")
  run(
    "npx quartz plugin install --from-config",
    cwd=quartz,
    shell=True,
  )
  run(
    f'npx quartz build',
    cwd=quartz,
    shell=True,
  )
  copytree(quartz / "public", wtree, dirs_exist_ok=True)
  with open(wtree / "CNAME", "w") as fh:
    fh.write("dio.adeom.dev\n")
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
