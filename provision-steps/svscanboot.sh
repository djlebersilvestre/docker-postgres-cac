#!/bin/bash

set -e

mkdir -p /etc/service/postgres
echo -e '#!/bin/bash\nsu postgres sh -lc "postgres"' > /etc/service/postgres/run
chmod +x /etc/service/postgres/run

if grep -q "svscanboot" /etc/inittab; then
  echo "Svscanboot already configured to be loaded on startup. Skipping this step."
else
  echo -e '\n# Svscanboot will load on startup and launch everyone under /etc/service' >> /etc/inittab
  echo -e 'SV:123456:respawn:/usr/bin/svscanboot' >> /etc/inittab
fi

exit 0
