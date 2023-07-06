echo "白嫖 Tailscale + Github Action ≈ VPN(Azure)
速度很快，可以隐藏IP，上Google，看YouTube！
===============================
作者: HackPig520
版本: v0.0.1
==============================="

AUTH_KEY="tskey-auth-kBHiLs1CNTRL-GeVuYmWDMiczypohQj6NicMaPP3YhejG"
echo -e "Starting...
Tailscale Auth Key: $AUTH_KEY
"
VERSION="1.44.0"
sleep 3
if [ ${{ runner.arch }} = "ARM64" ]; then
  TS_ARCH="arm64"
elif [ ${{ runner.arch }} = "ARM" ]; then
  TS_ARCH="arm"
elif [ ${{ runner.arch }} = "X86" ]; then
  TS_ARCH="386"
elif [ ${{ runner.arch }} = "X64" ]; then
  TS_ARCH="amd64"
else
  TS_ARCH="amd64"
fi
MINOR=$(echo "$VERSION" | awk -F '.' {'print $2'})
if [ $((MINOR % 2)) -eq 0 ]; then
  URL="https://pkgs.tailscale.com/stable/tailscale_${VERSION}_${TS_ARCH}.tgz"
else
  URL="https://pkgs.tailscale.com/unstable/tailscale_${VERSION}_${TS_ARCH}.tgz"
fi
if ! [[ "$SHA256SUM" ]] ; then
  SHA256SUM="$(curl "${URL}.sha256")"
fi
curl "$URL" -o tailscale.tgz --max-time 300
echo "$SHA256SUM  tailscale.tgz" | sha256sum -c
tar -C /tmp -xzf tailscale.tgz
rm tailscale.tgz
TSPATH=/tmp/tailscale_${VERSION}_${TS_ARCH}
sudo mv "${TSPATH}/tailscale" "${TSPATH}/tailscaled" /usr/bin

# Pull up `tailscaled`
sudo -E tailscaled --state=.ts.state 2>~/tailscaled.log &
# Connect to Tailscale
if [ -z "${HOSTNAME}" ]; then
  HOSTNAME="ga-$(cat /etc/hostname)"
fi
sudo -E tailscale up --hostname=${HOSTNAME} --auth-key $AUTH_KEY --advertise-exit-node
sudo tailscale ip > IPS.txt
echo "==============================="
for (( i = 1; i < 7200; i++)); do echo $RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM && sleep 1; done; # 2h timeout
