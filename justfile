project_name := `basename $(dirname $(realpath ./justfile))`

alias mm := mmigrate
alias sh := shell

# Run development server
runserver: database
    python manage.py runserver

# Run development server on all interfaces at port 80
runserver0: database
    python manage.py runserver 0.0.0.0:80

# Check whole project
check:
    python manage.py check

# Open python shell with django settings
shell: database
    python manage.py shell

# Clean all precompiled python files
clean:
    #!/usr/bin/env bash
    find . -name '__pycache__' -not -path "./.venv/*" -prune -exec rm -rf {} \;
    find . -name '*.pyc' -not -path "./.venv/*" -exec rm {} \;
    find . -name '.DS_Store' -not -path "./.venv/*" -exec rm {} \;
    rm -rf .mypy_cache

# Create database migrations for single app or whole project
makemigrations app="": database
    python manage.py makemigrations {{ app }}

# Run pending migrations for single app or whole project
migrate app="": database
    python manage.py migrate {{ app }}

# Run both makemigrations & migrate commands
mmigrate app="": database
    python manage.py makemigrations {{ app }} && python manage.py migrate {{ app }}

# Create a new app (also adding it to INSTALLED_APPS)
startapp app:
    #!/usr/bin/env bash
    python manage.py startapp {{ app }}
    APP_CLASS={{ app }}
    APP_CONFIG="{{ app }}.apps.${APP_CLASS^}Config"
    perl -0pi -e "s/(INSTALLED_APPS *= *\[)(.*?)(\])/\1\2    '$APP_CONFIG',\n\3/smg" $(find . -name settings.py)

zip: clean
    #!/usr/bin/env bash
    rm -f {{ project_name }}.zip
    zip -r {{ project_name }}.zip . -x .env .venv/**\*

# Install Python requirements
pipi: check-venv
    python -m pip install -r requirements.txt

# Launch project through Docker
dockup:
    docker compose up --build

# Make a Python virtualenv
mkvenv:
    python -m venv .venv --prompt {{ project_name }}

# Check if virtualenv is active
[private]
check-venv:
    #!/usr/bin/env bash
    if [ -z $VIRTUAL_ENV ] && [[ $(pyenv version-name) =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo You must activate a virtualenv!
        exit 1
    fi

# Start database server
[private]
database:
    #!/usr/bin/env bash
    if [[ $(grep -i postgres $(find . -name settings.py)) ]]; then
        if   [[ $OSTYPE == "linux-gnu"* ]]; then
            sudo service postgresql status &> /dev/null || sudo service postgresql start
        elif [[ $OSTYPE == "darwin"* ]]; then
            pgrep -x postgres || open /Applications/Postgres.app
        fi
    fi
