#!/bin/bash
cd "${0%/*}"

## Install NodeJs Package Manager
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 12
nvm use 12

## Install local tunnel
npm install -g localtunnel

## Install Python dependencies (Fast API, PyTorch, ...)
pip install -r requirements.txt

## Run!!
python dreams.py & lt --port 8000 --subdomain novoda-dreams 

