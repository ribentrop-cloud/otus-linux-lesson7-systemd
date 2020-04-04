#!/bin/bash
cd /opt
wget https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-7.3.0-x64.bin
chmod +x atlassian-jira-software-7.3.0-x64.bin
echo -e "o\n1\ni\nn\n" | ./atlassian-jira-software-7.3.0-x64.bin
echo -e '#!/bin/bash'"\n"'# --- ignore java version check ---' > atlassian/jira/bin/check-java.sh
systemctl daemon-reload
systemctl enable jira.service
systemctl start jira.service

