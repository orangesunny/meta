#!/bin/sh

set -u -e

REPOS="customize-example wlc scripts fedora_messaging weblate website weblate_schemas translation-finder munin fail2ban docker docker-compose hosted wllegal language-data graphics helm siphasc"

INITFILES="requirements-lint.txt .pre-commit-config.yaml .github/dependabot.yml"
COPYFILES=".github/stale.yml .github/labels.yml .github/workflows/closing.yml .github/workflows/labels.yml .github/workflows/label-sync.yml .github/workflows/pre-commit.yml .github/FUNDING.yml .github/.kodiak.toml .yamllint.yml"
PRESENTFILES=".github/matchers/sphinx-linkcheck.json .github/matchers/sphinx.json .github/matchers/flake8.json .github/matchers/eslint-compact.json .github/workflows/flake8.yml .github/workflows/eslint.yml .github/workflows/stylelint.yml .eslintrc.yml .stylelintrc"

. .venv/bin/activate

mkdir -p repos
cd repos

for repo in $REPOS ; do
    if [ ! -d $repo ] ; then
        git clone git@github.com:WeblateOrg/$repo.git
        cd $repo
    else
        cd $repo
        git reset --quiet --hard origin/master
        git pull --quiet
    fi
    echo "== $repo =="

    # Pre-commit update
    pre-commit autoupdate

    # Check README
    if ! grep -q Logo-Darktext-borders.png README.rst 2>/dev/null ; then
        echo "WARNING: README.rst not containing logo."
    fi

    # Update files
    mkdir -p .github/workflows/
    for file in $INITFILES ; do
        if [ ! -f $file ] ; then
            cp ../../$file $file
        fi
    done
    for file in $COPYFILES ; do
        cp ../../$file $file
    done
    for file in $PRESENTFILES ; do
        if [ -f $file ] ; then
            cp ../../$file $file
        fi
    done

    # Add and push
    git add .
    git commit -m 'Sync with WeblateOrg/meta'
    git push

    echo
    cd ..
done
