#!/bin/bash
set -e
sudo pacman -Sy --needed --noconfirm base-devel git cmake python-pip python-pyqt6 python-pyyaml python-requests python-setuptools ydotool xclip wl-clipboard alsa-plugins pipewire-pulse pavucontrol pyenv openssl zlib xz tk sqlite ncurses bzip2 libffi

grep -q 'YDOTOOL_SOCKET' ~/.bashrc || cat >> ~/.bashrc <<'EOF'
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export YDOTOOL_SOCKET="$HOME/.ydotool_socket"
EOF

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export YDOTOOL_SOCKET="$HOME/.ydotool_socket"

pyenv install -s 3.9.18

cd "$HOME"
[ -d voxd ] || git clone --branch v1.7.0 https://github.com/jakovius/voxd.git
cd voxd

"$PYENV_ROOT/versions/3.9.18/bin/python" -m venv .venv
source .venv/bin/activate

sed -i 's/version = "mr.batman"/version = "0.1.0"/' pyproject.toml
pip install -e .

cat > "$HOME/start-voxd.sh" <<'EOF'
#!/bin/bash
export YDOTOOL_SOCKET="$HOME/.ydotool_socket"
cd "$HOME/voxd"
source .venv/bin/activate
voxd --tray
EOF
chmod +x "$HOME/start-voxd.sh"

mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/voxd.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=VOXD
Exec=$HOME/start-voxd.sh
Icon=audio-input-microphone
Terminal=false
Categories=AudioVideo;Utility;
EOF

echo "Install complete. Log out and back in, then run: cd ~/voxd && source .venv/bin/activate && voxd --setup"
read -rp "Log out now? [y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] && loginctl terminate-session "$XDG_SESSION_ID"
