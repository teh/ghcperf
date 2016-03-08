# This is run by nix-build as well.
import shutil
import os
import subprocess
import json
import tempfile
import glob
import logging

TEMPLATE = """\
{{}}: {{
  rev = "{rev}";
  sha256 = "{sha256}";
}}
"""

os.environ['NIX_REMOTE'] = 'daemon'
subprocess.check_output(['nix-env', '--version'])


def collect_output():
    # We're still in the build directory and there will be a
    # unique-Quang3ua-result[-n] for each attribute in the default.nix
    #
    def extract_name(s):
        return s.split('/')[-1]

    for result in glob.glob('unique-Quang3ua-result'):
        for lib_path in subprocess.check_output(['nix-store', '--query', '--references', result]).decode('utf8').splitlines():
            shutil.copyfile(os.path.join(lib_path, 'perf.csv'), 'perf-{}.csv'.format(extract_name(lib_path)))


def main():
    logging.basicConfig(level=logging.INFO)

    # nix-prefetch-url doesn't work with submodules so we can't do this:
    #     real_sha256 = subprocess.check_output(['nix-prefetch-url', '-A', 'ghc.src']).strip().decode('utf8')

    # Instead of nix-prefetch-url use nix-prefetch-git to get the sha256:
    nix_prefetch_git = json.loads(subprocess.check_output(
        ['nix-prefetch-git', '--fetch-submodules', 'git://git.haskell.org/ghc.git']
    ).decode('utf8'))
    logging.info("nix_prefetch_git %r", nix_prefetch_git)
    rev, sha256 = nix_prefetch_git['rev'], nix_prefetch_git['sha256']
    logging.info("rev: %s, sha256: %s", rev, sha256)

    with open('ghc-latest.nix', 'w') as f:
        f.write(TEMPLATE.format(sha256=sha256, rev=rev))

    p = subprocess.Popen(['nix-build', 'default.nix', '-A', 'measure', '-j', '4', '--out-link', "unique-Quang3ua-result"])
    retcode = p.wait()
    if retcode == 0:
        collect_output()
    else:
        with open('./error', 'w') as f:
            f.write("program exited with code {}".format(retcode))


if __name__ == '__main__':
    main()
