#!/bin/bash

echo '{'
echo '  "status": 1,'
echo '  "username": "'$SFTPGO_LOGIND_USER'",'
echo '  "home_dir": "/var/www/dav/data/'$SFTPGO_LOGIND_USER'",'
echo '  "uid": 0,'
echo '  "gid": 0,'
echo '  "max_sessions": 0,'
echo '  "quota_size": 0,'
echo '  "quota_files": 0,'
echo '  "permissions": {'
echo '    "/": ['
echo '      "*"'
echo '    ]'
echo '  },'
echo '  "upload_data_transfer": 0,'
echo '  "download_data_transfer": 0,'
echo '  "total_data_transfer": 0,'
echo '  "filesystem": {'
echo '    "provider": 0,'
echo '    "osconfig": {},'
echo '  }'
echo '}'