#!/bin/sh -eux

devops='
This system was built with the Channel CNAO Workshop project by the Cisco/AppDynamics Cloud Channel Sales Team.
More information can be found at: https://github.com/ed-barberis/Channel-CNAO-Workshop.git'

if [ -d /etc/update-motd.d ]; then
    MOTD_CONFIG='/etc/update-motd.d/99-devops'

    cat >> "$MOTD_CONFIG" <<DEVOPS
#!/bin/sh

cat <<'EOF'
$devops
EOF
DEVOPS

    chmod 0755 "$MOTD_CONFIG"
else
    echo "$devops" >> /etc/motd
fi
